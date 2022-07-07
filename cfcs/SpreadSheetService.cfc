<cfcomponent output="false" displayname="Spreadsheet Service">
	<cffunction name="init" access="public" output="false" returntype="SpreadsheetService">
		<cfreturn this />
	</cffunction>

	<cffunction name="createFromQuery" access="public" output="false" returntype="void">
		<cfargument name="data" type="query" required="true" />
		<cfargument name="xlsx" type="boolean" required="false" default="false" hint="File extension is xlsx (true) or xls (false)." />
		<cfargument name="fileName" type="string" required="false" default="" hint="Final file name sent to the browser." />
		<cfset var config = {
			extension = "xls"
			, temp_path = getTempDirectory()
			, temp_name = createUUID()
			, full_temp_name = ""
			, file_name = arguments.fileName
			, q = arguments.data
		} />

		<cfif arguments.xlsx>
			<cfset config.extension = "xlsx" />
		</cfif>

		<cfset config.full_temp_name = config.temp_path & config.temp_name & "." & config.extension />

		<cftry>
			<cfspreadsheet action="write" filename="#config.full_temp_name#" query="config.q" />
			<cfspreadsheet action="read" src="#config.full_temp_name#" name="local.xls" />
			<cffile action="delete" file="#config.full_temp_name#" />

			<cfif len(arguments.fileName) GT 0>
				<cfheader name="content-disposition" value="attachment; filename=#arguments.fileName#.#config.extension#" />
			<cfelse>
				<cfheader name="content-disposition" value="attachment; filename=#config.temp_name#.#config.extension#" />
			</cfif>
			<cfcontent type="application/msexcel" variable="#spreadsheetReadBinary(local.xls)#" reset="true" />
			<cfcatch type="any">
				<cfdump var="#cfcatch#" output="console" />
			</cfcatch>
		</cftry>
	</cffunction>
</cfcomponent>