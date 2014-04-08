<?xml version="1.0" encoding="UTF-8"?>
<!-- HL7 to CSF Transformation Specification -->
<xsl:stylesheet
		version="1.0"
		exclude-result-prefixes="cache translator java"
		xmlns:hl7="urn:hl7-org:v3"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:java="http://xml.apache.org/xalan/java"
		xmlns:cache="http://xml.apache.org/xalan/java/com.syntegra.spine.csf.wrapper.xslt.CSFCache"
		xmlns:translator="http://xml.apache.org/xalan/java/com.syntegra.spine.csf.wrapper.xslt.CSFTranslator"
		xmlns:id="http://xml.apache.org/xalan/java/com.syntegra.spine.csf.CSFIdentifier">

	<xsl:output method="xml" indent="yes" encoding="UTF-8"/>

	<xsl:template match="/">

		<xsl:variable name="request" select="cache:getRequestMessage()" />

		<!-- Select the first element in the document. The element name is the interaction id -->
		<xsl:variable name="message" select="*[1]"/>

		<!-- hl7 message validation rules -->

		<!-- hl7:interactionId has multiplicity of 1 -->
		<xsl:variable name="interactionId" select="$message/hl7:interactionId/@extension"/>
		<xsl:variable name="validInteractionId" select="count($interactionId)=1 and string-length($interactionId)>0"/>

		<!-- hl7:messageId has multiplicity of 1 -->
		<xsl:variable name="messageId" select="$message/hl7:id/@root"/>
		<xsl:variable name="validMessageId" select="count($messageId)=1 and string-length($messageId)>0"/>

		<!-- hl7:creationTime has multiplicity of 1 -->
		<xsl:variable name="creationTime" select="$message/hl7:creationTime/@value"/>
<!--		<xsl:variable name="validCreationTime" select="count($creationTime)=1 and string-length($creationTime)>0"/>
-->
		<!-- hl7:versionCode has multiplicity of 1 -->
		<xsl:variable name="versionCode" select="$message/hl7:versionCode/@code"/>
		<xsl:variable name="validVersionCode" select="count($versionCode)=1 and string-length($versionCode)>0"/>

		<!-- hl7:ControlActEvent/hl7:author has multiplicity 0..1 -->
		<xsl:variable name="author" select="$message/hl7:ControlActEvent/hl7:author"/>
		<xsl:variable name="roleProfileId" select="$author/hl7:AgentPersonSDS/hl7:id"/>
		<xsl:variable name="userId" select="$author/hl7:AgentPersonSDS/hl7:agentPersonSDS/hl7:id"/>
		<xsl:variable name="jobRoleId" select="$author/hl7:AgentPersonSDS/hl7:part/hl7:partSDSRole/hl7:id"/>

		<!-- Author is optional, but if it is present roleProfileId, userId and jobRoleId must ALL be present and has non-zero values -->
		<xsl:variable name="validRoleProfileId" select="string-length($roleProfileId/@root)>0 and string-length($roleProfileId/@extension)>0"/>
		<xsl:variable name="validUserId" select="string-length($userId/@root)>0 and string-length($userId/@extension)>0"/>
		<xsl:variable name="validJobRoleId" select="string-length($jobRoleId/@root)>0 and string-length($jobRoleId/@extension)>0"/>
		<xsl:variable name="validAuthor" select="count($author)=0 or ($validRoleProfileId and $validUserId and $jobRoleId)"/>

		<!-- hl7:ControlActEvent/hl7:author1 has multiplicity 1..2 -->
		<xsl:variable name="author1.1" select="$message/hl7:ControlActEvent/hl7:author1[1]"/>
		<xsl:variable name="author1.2" select="$message/hl7:ControlActEvent/hl7:author1[2]"/>
		<!-- hl7:ControlActEvent/hl7:author1[1] must be valid AND either hl7:ControlActEvent/hl7:author1[2] is valid OR is not present -->
		<xsl:variable name="validAuthor1.1" select="string-length($author1.1/hl7:AgentSystemSDS/hl7:agentSystemSDS/hl7:id/@root)>0 and string-length($author1.1/hl7:AgentSystemSDS/hl7:agentSystemSDS/hl7:id/@extension)>0"/>
		<xsl:variable name="validAuthor1.2" select="string-length($author1.2/hl7:AgentSystemSDS/hl7:agentSystemSDS/hl7:id/@root)>0 and string-length($author1.2/hl7:AgentSystemSDS/hl7:agentSystemSDS/hl7:id/@extension)>0"/>
		<xsl:variable name="validAuthor1" select="$validAuthor1.1 and ($validAuthor1.2 or count($author1.2)=0)"/>

		<!-- 
			hl7:communicationFunctionRcv has multiplicity of 1..* (Only one CommunicationFunctionRcv is currently supported)
			hl7:communicationFunctionRcv/hl7:device/hl7:id has multiplicity of 1..* 
			hl7:communicationFunctionRcv[n]/hl7:device/hl7:id[@root='1.2.826.0.1285.0.2.0.107'] has implicit multiplicity of 1
		-->
		<xsl:variable name="communicationFunctionRcv" select="$message/hl7:communicationFunctionRcv[1]/hl7:device/hl7:id[@root='1.2.826.0.1285.0.2.0.107']"/>
		<xsl:variable name="validCommunicationFunctionRcv" select="count($communicationFunctionRcv)=1 and string-length($communicationFunctionRcv/@extension)>0"/>

		<!--
			hl7:communicationFunctionSnd has multiplicity of 1. 
			hl7:communicationFunctionSnd/hl7:device/hl7:id has multiplicity of 1..* 
			hl7:communicationFunctionSnd/hl7:device/hl7:id[@root='1.2.826.0.1285.0.2.0.107'] has implicit multiplicity of 1 
		-->
		<xsl:variable name="communicationFunctionSnd" select="$message/hl7:communicationFunctionSnd/hl7:device/hl7:id[@root='1.2.826.0.1285.0.2.0.107']"/>
		<xsl:variable name="validCommunicationFunctionSnd" select="count($communicationFunctionSnd)=1 and string-length($communicationFunctionSnd/@extension)>0"/>
		
		<!-- hl7:ControlActEvent cannot contain both hl7:subject and hl7:query -->
		<xsl:variable name="subject" select="$message/hl7:ControlActEvent/hl7:subject"/>
		<xsl:variable name="query" select="$message/hl7:ControlActEvent/hl7:query"/>
		<xsl:variable name="validPayload" select="count($subject)+count($query)&lt;2"/>

		<!-- validate hl7 -->
<!--		<xsl:variable name="validHL7" select="$validInteractionId and $validMessageId and $validCreationTime and $validVersionCode and $validAuthor and $validAuthor1 and $validCommunicationFunctionSnd and $validCommunicationFunctionRcv and $validPayload"/>
		<xsl:if test="not($validHL7)">
			<xsl:message terminate="yes">Invalid Message</xsl:message>
		</xsl:if>
-->
		<xsl:value-of select="java:setClientId($request,'urn:spine:tmsclient:CSA')"/>
		<xsl:value-of select="java:setInteractionId($request,$interactionId)"/>
		<xsl:value-of select="java:setMessageId($request,$messageId)"/>
		<xsl:value-of select="java:setCreationTime($request,translator:parseDate($creationTime))"/>
		<xsl:value-of select="java:setVersion($request,$versionCode)"/>
		<!-- doRBAC - set to true for HL7 requests - assume CSA is the client -->
		<xsl:value-of select="java:setDoRBAC($request,1=1)"/>
		<!-- payload -->
		<xsl:if test="count($subject)>0">
			<xsl:value-of select="java:setPayload($request,translator:nodesetToString($subject/*[1]))"/>
		</xsl:if>
		<xsl:if test="count($query)>0">
			<xsl:value-of select="java:setPayload($request,translator:nodesetToString($query))"/>
		</xsl:if>
		<!-- authors -->
		<xsl:if test="$validAuthor">
			<xsl:value-of select="java:addAuthor($request,id:new($roleProfileId/@root,$roleProfileId/@extension))"/>
			<xsl:value-of select="java:addAuthor($request,id:new($userId/@root,$userId/@extension))"/>
			<xsl:value-of select="java:addAuthor($request,id:new($jobRoleId/@root,$jobRoleId/@extension))"/>
		</xsl:if>
		<xsl:if test="$validAuthor1.1">
			<xsl:variable name="author" select="id:new($author1.1/hl7:AgentSystemSDS/hl7:agentSystemSDS/hl7:id/@root,$author1.1/hl7:AgentSystemSDS/hl7:agentSystemSDS/hl7:id/@extension)" />
			<xsl:value-of select="java:addAuthor($request,$author)"/>
		</xsl:if>
		<xsl:if test="$validAuthor1.2 and count($author1.2)>0">
			<xsl:variable name="author" select="id:new($author1.2/hl7:AgentSystemSDS/hl7:agentSystemSDS/hl7:id/@root,$author1.2/hl7:AgentSystemSDS/hl7:agentSystemSDS/hl7:id/@extension)" />
			<xsl:value-of select="java:addAuthor($request,$author)"/>
		</xsl:if>
		<!-- source -->
		<xsl:variable name="source" select="id:new($communicationFunctionSnd/@root,$communicationFunctionSnd/@extension)" />
		<xsl:value-of select="java:addSource($request,$source)"/>
		<!-- destination -->
		<xsl:variable name="destination" select="id:new($communicationFunctionRcv/@root,$communicationFunctionRcv/@extension)" />
		<xsl:value-of select="java:addDestination($request,$destination)"/>
	</xsl:template>
</xsl:stylesheet>