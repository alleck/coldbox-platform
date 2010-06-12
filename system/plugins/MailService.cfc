<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Date        :	May 8, 2009
Description :
	The ColdBox Mail Service used to send emails in an oo fashion


----------------------------------------------------------------------->
<cfcomponent output="false" 
			 hint="The ColdBox Mail Service used to send emails in an oo fashion"
			 extends="coldbox.system.Plugin">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" output="false" returntype="MailService" hint="Constructor">
		<cfargument name="controller" type="any" required="true">
		<cfscript>
			super.init(argumentCollection=arguments);
			
			// Plugin Properties
			setPluginName("MailService");
			setPluginDescription("This is a mail service used to send mails in an OO fashion");
			setPluginVersion("1.0");
			setPluginAuthor("Luis Majano");
			setPluginAuthorURL("http://www.coldbox.org");
			
			// Mail Token Symbol
			setTokenMarker("@");
			
			// Setting Override
			if( settingExists("mailservice_tokenMarker") ){
				setTokenMarker( getSetting("mailservice_tokenMarker") ); 
			}
			
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- Get/Set Token Marker --->
	<cffunction name="getTokenMarker" access="public" returntype="string" output="false" hint="Get the token marker">
    	<cfreturn instance.TokenMarker>
    </cffunction>
    <cffunction name="setTokenMarker" access="public" returntype="void" output="false" hint="Set the token marker">
    	<cfargument name="TokenMarker" type="string" required="true">
    	<cfset instance.TokenMarker = arguments.TokenMarker>
    </cffunction>

	<!--- newMail --->
	<cffunction name="newMail" access="public" returntype="coldbox.system.beans.Mail" output="false" hint="Get a new Mail payload object, just use config() on it to prepare it.">
		<cfscript>
			return createObject("component","coldbox.system.beans.Mail").init();
		</cfscript>
	</cffunction>
	
	<cffunction name="send" access="public" returntype="struct" output="false" hint="Send an email payload. Returns a struct: [error:boolean,errorArray:array]">
		<cfargument name="mail" required="true" type="coldbox.system.beans.Mail" hint="The mail payload to send." />
		<cfscript>
		var rtnStruct = structnew();
		var payload = arguments.mail;
		
		// The return structure
		rtnStruct.error = true;
		rtnStruct.errorArray = ArrayNew(1);
			
		// Validate Basic Mail Fields
		if( NOT payload.validate() ){
			arrayAppend(rtnStruct.errorArray,"Please check the basic mail fields of To, From and Body as they are empty. To: #payload.getTo()#, From: #payload.getFrom()#, Body Len = #payload.getBody().length()#.");
		}
		// Check server info on mail object, if not, populate with settings, eventhough they can be blank also.
		if( arguments.mail.propertyExists("server") 
		    AND NOT len(arguments.mail.getServer())
		    AND NOT len(getSetting("MailServer")) ){ 
			mail.setServer(getSetting("MailServer")); 
		}
		if( arguments.mail.propertyExists("username") 
		    AND NOT len(arguments.mail.getUsername())
		    AND NOT len(getSetting("MailUsername")) ){ 
			mail.setUsername(getSetting("MailUsername")); 
		}
		if( arguments.mail.propertyExists("password") 
		    AND NOT len(arguments.mail.getpassword())
		    AND NOT len(getSetting("MailPassword")) ){ 
			mail.setpassword(getSetting("MailPassword")); 
		}
		if( arguments.mail.propertyExists("port") 
		    AND NOT len(arguments.mail.getport())
		    AND NOT len(getSetting("MailPort")) ){ 
			mail.setport(getSetting("MailPort")); 
		}
		// Parse Tokens
		parseTokens(payload);
				
		//Just mail the darned thing!!
		try{
			mailIt(payload);
			rtnStruct.error = false;
		}
		catch(Any e){
			ArrayAppend(rtnStruct.errorArray,"Error sending mail. #e.message# : #e.detail# : #e.stackTrace#");
			// log it
			log.error("Error sending mail. #e.message# : #e.detail# : #e.stackTrace#",payload.getMemento());
		}			

		//return
		return rtnStruct;
		</cfscript>
	</cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------->
	
	<cffunction name="mailIt" output="false" access="private" returntype="void" hint="Mail a payload">
		<cfargument name="mail" required="true" type="coldbox.system.beans.Mail" hint="The mail payload" />
		<cfscript>
			// Determine Mail Type?
			if( arrayLen(arguments.mail.getMailParts()) ){
				mailMultiPart(arguments.mail);
			}
			else{
				mailNormal(arguments.mail);
			}		
		</cfscript>
	</cffunction>


	<cffunction name="mailNormal" output="false" access="private" returntype="void" hint="Mail a payload">
		<cfargument name="mail" required="true" type="coldbox.system.beans.Mail" hint="The mail payload" />
		<cfset var payload = arguments.mail>
		<cfset var mailParam = 0>
		
		<cfsetting enablecfoutputonly="true">
		
		<!--- I HATE FREAKING CF WHITESPACE, LOOK HOW UGLY THIS IS --->
		<cfmail attributeCollection="#payload.getMemento()#"><cfoutput>#payload.getBody()#</cfoutput><cfsilent>
			<cfloop array="#payload.getMailParams()#" index="mailparam">
				<cfif structKeyExists(mailParam,"name")>
					<cfmailparam name="#mailparam.name#" attributeCollection="#mailParam#">
				<cfelseif structKeyExists(mailparam,"file")>
					<cfmailparam file="#mailparam.file#" attributeCollection="#mailParam#">
				</cfif>
			</cfloop></cfsilent></cfmail>
		
		<cfsetting enablecfoutputonly="false">
	</cffunction>

	<cffunction name="mailMultiPart" output="false" access="private" returntype="any" hint="Mail a payload using multi part objects">
		<cfargument name="mail" required="true" type="coldbox.system.beans.Mail" hint="The mail payload" />
		<cfset var payload = arguments.mail>
		<cfset var mailParam = 0>
		<cfset var mailPart = 0>
		
		<cfsetting enablecfoutputonly="true">

		<!--- I HATE FREAKING CF WHITESPACE, LOOK HOW UGLY THIS IS --->
		<cfmail attributeCollection="#payload.getMemento()#">
		<!--- Mail Params --->
		<cfloop array="#payload.getMailParams()#" index="mailparam">
			<cfif structKeyExists(mailParam,"name")>
				<cfmailparam name="#mailparam.name#" attributeCollection="#mailParam#">
			<cfelseif structKeyExists(mailparam,"file")>
				<cfmailparam file="#mailparam.file#" attributeCollection="#mailParam#">
			</cfif>
		</cfloop>
		<!--- Mail Parts --->
		<cfloop array="#payload.getMailParts()#" index="mailPart">
			<cfmailpart attributeCollection="#mailpart#"><cfoutput>#mailpart.body#</cfoutput></cfmailpart>
		</cfloop>
		</cfmail>

		<cfsetting enablecfoutputonly="false">
	
	</cffunction>
	
	<cffunction name="parseTokens" access="private" returntype="void" output="false" hint="Parse the tokens and do body replacements.">
		<cfargument name="Mail" required="true" type="coldbox.system.beans.Mail" hint="The mail payload" />
		<cfscript>
			var tokens 		= arguments.Mail.getBodyTokens();
			var body 		= arguments.Mail.getBody();
			var mailParts	= arguments.Mail.getMailParts();
      		var key 		= 0;
			var tokenMarker = getTokenMarker();
			var mailPart 	= 1;
			
			//Check mail parts for content
			if( arrayLen(mailparts) ){
				// Loop over mail parts
				for(mailPart=1; mailPart lte arrayLen(mailParts); mailPart++){
					body = mailParts[mailPart].body;
					for(key in tokens){
						body = replaceNoCase(body,"#tokenMarker##key##tokenMarker#", tokens[key],"all");
					}
					mailParts[mailPart].body = body;
				}
			}
			
			// Do token replacement on the body text
			for(key in tokens){
				body = replaceNoCase(body,"#tokenMarker##key##tokenMarker#", tokens[key],"all");
			}
			// replace back the body
			arguments.Mail.setBody(body);
		</cfscript>
	</cffunction>

</cfcomponent>