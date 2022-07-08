component {
	/* Available application.cfc variable refernce --> https://helpx.adobe.com/coldfusion/cfml-reference/application-cfc-reference/application-variables.html */
	this.version = "beta v0.001";
	this.name = 'DEVTOOLS' & ' ' & this.version;
	this.sitename = 'DEV Toolbox';
	this.companyname = 'WilsonStudioWeb';
	obj.Datasources = CreateObject("java", "coldfusion.server.ServiceFactory").DataSourceService.getNames()
	this.datasource = obj.Datasources[1]; 
	this.layout = 'main';
	/*
		this.datasources = { 
			mydatasourcename: { database: "dbname",  host: "hostaddress", port: "1433",  driver: "MSSQLServer", username: "user", password: "XXXXXXXXXXXX" }  
			// Additional Protection against SQL Injection by mapping DSN with specific DB Server Login privledges (Create, Read, Update, Delete).. 
				R: { database: "<DBName>",  host: "<HostNameOrIP>", port: "<portNumber>",  driver: "MSSQLServer", username: "username", password: "password" },  
				CRU: { database: "<DBName>",  host: "<HostNameOrIP>", port: "<portNumber>",  driver: "MSSQLServer", username: "username", password: "password" },  
				CRUD: { database: "<DBName>",  host: "<HostNameOrIP>", port: "<portNumber>",  driver: "MSSQLServer", username: "username", password: "password" }
		};
		this.smtpserversettings   = {
			server="mail13.ezhostingserver.com",
			username="",
			password="",
			port="465",
			UseSSL = '1'
		};
	*/
	// this.applicationtimeout = createTimeSpan(0,2,0,0);	
	this.sessionManagement = true;
	this.sessionTimeout = CreateTimeSpan(0,0,90,0);
	this.setClientCookies = "Yes";
	this.serialization.preservecaseforstructkey = true;
	this.serialization.preserveCaseForQueryColumn 	= true;
	this.compression = true; // Enables Gzip compression on the HTTP response when true
 	this.appBasePath = getDirectoryFromPath(getCurrentTemplatePath());	
	this.blockedExtForFileUpload="cfm, cfc, jsp, exe, asp, aspx, php"; /* Setting is site wide on all uploads */
	// this.timeout = "60";
	// this.debuggingipaddress = "127.0.0.1";
	// this.enablerobustexception  = "yes";
    // this.mappings["/com"] = this.appBasePath & "com";
    this.mappings["/cfc"] = this.appBasePath & "cfcs";
	this.javaSettings = {
        loadPaths = ["#this.appBasePath#../java/jSoup/jsoup-1.14.3.jar"]
    };
	// this.mappings["/customtags"] = this.appBasePath & "customtags";

	private function sessionLogin(){
		if(IsDefined("Cookie.REMEMBERME") is "True" AND !structKeyExists(session,'user')){
			q.auth = queryExecute(" SELECT * FROM users WHERE auth_token = :auth_token ", { 
				auth_token = { value=Cookie.REMEMBERME, cfsqltype="cf_sql_varchar" }
			});
			if(q.auth.RecordCount GT 0){
				q.updateLoginAttempts = queryExecute(" UPDATE users SET  invalid_login_attempts = 0,  invalid_login_dt = NULL, account_locked = 0 WHERE email = :email ", { 
					email = { value=q.auth.email, cfsqltype="cf_sql_varchar" }
				});
				session.user = {
					isAuthenticated: 1,
					user_id: q.auth.user_id, 
					user_name: q.auth.user_name, 
					email: q.auth.email, 
					first_name: q.auth.first_name, 
					last_name: q.auth.last_name, 
					full_name: '#q.auth.first_name# #q.auth.last_name#'
				};
				location("profile.cfm", "false", "301");
			}
		}
	}

	public void function onSessionStart(){
		session.layout = this.layout;
		session.hitCount = 0;
		session.dbTool = createObject("component", "cfcs.dbtool");
		// sessionLogin();
	}

	public boolean function onApplicationStart(){
		application.adminIPArray = ['127.0.0.1'];
		return true;
	}

	public void function onApplicationEnd(ApplicationScope){
 
	}

	/** @hint A request starts */
	public boolean function onRequestStart(String targetPage){
		var local = {};
		// include 'includes/blockip.cfm';

		if(!isDefined('session.layout')) { session.layout = this.layout; }
 
		if (IsDefined("url.reinit")) { onApplicationStart(); }
		if(StructKeyExists(URL, "reload")){
			ApplicationStop();
			location(url=arguments.targetPage, addtoken = false);
			return false;
		};

		if(StructKeyExists(URL, "layout")) session.layout = url.layout;

		if(structKeyExists(url, "logout")) { 
			if(isDefined('session')) { 
				for(skey in session) { 
					if(!listFindNoCase("cfid,cftoken,sessionid,urltoken", skey));
					structDelete(session, skey); 
					cookie[ "REMEMBERME" ] = {
                        value: '',
                        expires: now(),
                        domain: "mydomian.com",
                        httpOnly: false
                    };
					StructDelete(cookie,"REMEMBERME");
					this.sessionTimeout = createTimeSpan( 0, 0, 0, 1 ); 
				}
			}
			onSessionStart();
			location("/login.cfm", "false"); abort;
			// onRequest('/login.cfm'); abort; 
		}
		
		// if(CGI.HTTPS != "on") location(url="https://#CGI.SERVER_NAME#/#CGI.SCRIPT_NAME#?#CGI.QUERY_STRING#", addtoken="false");
		return true;
	}

	public function onCFCRequest(String cfcname,String method,Struct args){
		return invoke(ARGUMENTS.cfcname, ARGUMENTS.method, ARGUMENTS.args);
   	}

	public void function onRequest(String targetPage, String head){	
		include '/templates/#session.layout#/template.cfm'; /* Inject the design template which should output the page content somewhere */
		//if(structKeyExists(request, "footertext")) { footercontent = replacenocase(footercontent, "</body>", "#request.footertext#</body>"); writeoutput(trim(footercontent)); }
	}
 
	public void function onRequestEnd(String targetPage){
 
	}

	public void function onSessionEnd(SessionScope,ApplicationScope){ }
	
	public void function onAbort(required string targetPage) { return; } 

	public boolean function OnMissingTemplate(required string TargetPage){ 
		request.content = 'File does not exist';
		include '/templates/#session.layout#/template.cfm';
		return true;
	}

	public function onMissingMethod(missingMethodName, missingMethodArguments) {
		throw (message="Method #encodeForHTML(arguments.missingMethodName)# was not found in the component #encodeForHTML(GetMetaData(this).name)#");
	}
	
	public function onError(required any exception, required string eventName) { 
		writeDump(var:exception,label:eventName); 
        /*
		if(arrayFind(application.adminIPArray,cgi.REMOTE_ADDR)) {
			savecontent variable='request.content' { writeDump(var:exception,label:eventName) } 
		} else {
			request.content = 'An error has occured';
		}
		include '/templates/#session.layout#/template.cfm';
        */
		return true;
		/*
			savecontent variable='LOCAL.output' { writeDump(var:exception,label:eventName) } 
			param string REQUEST.content = LOCAL.output; 
			include '/templates/#session.layout#/template.cfm'; 
		*/
	} 

	// cferror(type="exception", template="/templates/#session.layout#/includes/error.cfm");
	// cferror(type="request", template="/templates/#session.layout#/includes/error_request.cfm");

    
 }