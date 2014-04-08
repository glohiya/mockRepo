<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
		exclude-result-prefixes="cache translator java"
		version="1.0"
		xmlns:java="http://xml.apache.org/xalan/java"
		xmlns:cache="http://xml.apache.org/xalan/java/com.syntegra.spine.csf.wrapper.xslt.CSFCache"
		xmlns:translator="http://xml.apache.org/xalan/java/com.syntegra.spine.csf.wrapper.xslt.CSFTranslator"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output method="xml" encoding="UTF-8" indent="yes"/>

	<xsl:variable name="response" select="cache:getResponseMessage()" />

	<xsl:template match="/">

		<!-- required CSF Request elements -->

		<!-- interactionId has multiplicity of 1 -->	
		<xsl:variable name="interactionId" select="java:getInteractionId($response)"/>
		<xsl:variable name="validInteractionId" select="translator:isDefined($interactionId) and string-length($interactionId)>0"/>

		<!-- messageId has multiplicity of 1 -->
		<xsl:variable name="messageId" select="java:getMessageId($response)"/>
		<xsl:variable name="validMessageId" select="translator:isDefined($messageId) and string-length($messageId)>0"/>

		<!-- creationTime has multiplicity of 1 -->
		<xsl:variable name="creationTime" select="translator:formatDate(java:getCreationTime($response))"/>
		<xsl:variable name="validCreationTime" select="translator:isDefined($creationTime) and string-length($creationTime)>0"/>

		<!-- hl7:ControlActEvent/hl7:author has muliplicity 0..1. All 3 elements (roleProfileId, userId and jobRoleId) must be present to create a valid hl7:ControlActEvent/hl7:author element. If no roleProfileId exists the CSF message is valid but no hl7:ControlActEvent/hl7:author is created -->
		<xsl:variable name="authors" select="java:getAuthors($response)"/>
		<xsl:variable name="roleProfileId" select="translator:getFirstIdByType($authors,'1.2.826.0.1285.0.2.0.67')"/>
		<xsl:variable name="userId" select="translator:getFirstIdByType($authors,'1.2.826.0.1285.0.2.0.65')"/>
		<xsl:variable name="jobRoleId" select="translator:getFirstIdByType($authors,'1.2.826.0.1285.0.2.1.104')"/>
		<xsl:variable name="validAuthor" select="(translator:isDefined($roleProfileId) and translator:isDefined($userId) and translator:isDefined($jobRoleId)) or not(translator:isDefined($roleProfileId))"/>

		<!-- author1 has multiplicity of 1..2 -->
		<!--
		<xsl:variable name="validAuthor1" select="count($header/authorId[@root='1.2.826.0.1285.0.2.0.107'])=1 or count($header/authorId[@root='1.2.826.0.1285.0.2.0.107'])=2"/>
		-->

		<!-- required CSF Response elements -->
		<!-- refToMessageId has a multiplicity of 1 -->
		<xsl:variable name="refToMessageId" select="java:getRefToMessageId($response)"/>
		<xsl:variable name="validRefToMessageId" select="translator:isDefined($refToMessageId) and string-length($refToMessageId)>0"/>

		<!-- refToInteractionId has a multiplicity of 1 -->
		<xsl:variable name="refToInteractionId" select="java:getRefToInteractionId($response)"/>
		<xsl:variable name="validRefToInteractionId" select="translator:isDefined($refToInteractionId) and string-length($refToInteractionId)>0"/>

		<!-- messageCode has a multiplicity of 1 -->
		<xsl:variable name="messageCode" select="java:getMessageCode($response)"/>
		<xsl:variable name="validMessageCode" select="translator:isDefined($messageCode) and string-length($messageCode)>0"/>

		<xsl:variable name="messageError" select="not(boolean($messageCode='AA'))"/>

		<!-- validate CSF -->
		<xsl:variable name="validCSF" select="$validInteractionId and $validMessageId and $validCreationTime and $validRefToInteractionId and $validRefToMessageId and $validMessageCode and $validAuthor"/>
		<xsl:if test="not($validCSF)">
			<xsl:message terminate="yes">Invalid Message</xsl:message>
		</xsl:if>

		<!-- optional CSF Request elements -->
		<xsl:variable name="versionCode" select="java:getVersion($response)"/>
<!--		<xsl:variable name="versionCode" select="V3NPfIT3.1.09"/>
-->		<xsl:variable name="validVersion" select="string-length($versionCode)>0"/>
		<xsl:variable name="servicePayload" select="java:getPayload($response)"/>

		<xsl:text disable-output-escaping="yes">&lt;</xsl:text><xsl:value-of select="$interactionId"/> xmlns="urn:hl7-org:v3"<xsl:text disable-output-escaping="yes">&gt;</xsl:text>
			<id>
				<xsl:attribute name="root">
					<xsl:value-of select="$messageId"/>
				</xsl:attribute>
			</id>
			<creationTime>
				<xsl:attribute name="value">
					<xsl:value-of select="$creationTime"/>
				</xsl:attribute>
			</creationTime>
			<versionCode>
				<xsl:choose>
					<xsl:when test="$validVersion">
						<xsl:attribute name="code">
							<xsl:value-of select="$versionCode"/>
						</xsl:attribute>				
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="code">V3NPfIT3.1.09</xsl:attribute>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:attribute name="code">
					<xsl:value-of select="$versionCode"/>
				</xsl:attribute>		
			</versionCode>
			<interactionId>
				<xsl:attribute name="root">2.16.840.1.113883.2.1.3.2.4.12</xsl:attribute>
				<xsl:attribute name="extension">
					<xsl:value-of select="$interactionId"/>
				</xsl:attribute>
			</interactionId>
			 <processingCode>
				<xsl:attribute name="code">P</xsl:attribute>
			 </processingCode>
			 <processingModeCode>
				<xsl:attribute name="code">T</xsl:attribute>
			 </processingModeCode>
			 <acceptAckCode>
				<xsl:attribute name="code">NE</xsl:attribute>
			 </acceptAckCode>
			<acknowledgement>
				<xsl:attribute name="typeCode">
					<xsl:value-of select="$messageCode"/>
				</xsl:attribute>
				<xsl:if test="$messageError">
					<xsl:value-of select="cache:iterate(java:getErrors($response),'ERRORS')"/>
					<xsl:if test="cache:hasMore('ERRORS')">
						<xsl:call-template name="iterateTMSErrors"/>
					</xsl:if>
				</xsl:if>
				<messageRef>
					<id>
						<xsl:attribute name="root">
							<xsl:value-of select="$refToMessageId"/>
						</xsl:attribute>
					</id>
				</messageRef>
			</acknowledgement>
			<xsl:value-of select="cache:iterate(java:getDestinations($response),'DESTINATIONS')"/>
			<xsl:if test="cache:hasMore('DESTINATIONS')">
				<xsl:call-template name="iterateDestinations"/>
			</xsl:if>
			<!-- One sender only so use the first one -->
			<xsl:value-of select="cache:iterate(java:getSources($response),'SOURCES')"/>
			<xsl:if test="cache:hasMore('SOURCES')">
				<xsl:variable name="device" select="cache:getNextId('SOURCES')"/>
				<communicationFunctionSnd typeCode="SND">
					<device>
						<id>
							<xsl:attribute name="root"><xsl:value-of select="java:getRoot($device)"/></xsl:attribute>
							<xsl:attribute name="extension"><xsl:value-of select="java:getExtension($device)"/></xsl:attribute>
						</id>
					</device>
				</communicationFunctionSnd>
			</xsl:if>
			<ControlActEvent classCode="CACT" moodCode="EVN">
				<xsl:call-template name="renderRoleProfile"/>
				<xsl:value-of select="cache:iterate(java:getAuthors($response),'AUTHORS')"/>
				<xsl:if test="cache:hasMore('AUTHORS')">
					<xsl:call-template name="iterateSystemIds"/>
				</xsl:if>
				<xsl:value-of select="cache:iterate(java:getErrors($response),'ERRORS')"/>
				<xsl:if test="cache:hasMore('ERRORS')">
					<xsl:call-template name="iterateDomainErrors"/>
				</xsl:if>
				<xsl:if test="translator:isDefined($servicePayload)">
					<subject typeCode="SUBJ">
						<xsl:value-of disable-output-escaping="yes" select="$servicePayload"/>
					</subject>
				</xsl:if>
				<!-- Generate queryAck element only for query interactions used by CSA -->
				<xsl:if test="$refToInteractionId='QUPC_IN010000UK15' or $refToInteractionId='QUPA_IN020000UK14' or $refToInteractionId='QUPA_IN040000UK14' or $refToInteractionId='QUPA_IN060000UK13' or $refToInteractionId='QUPC_IN100000UK05' or $refToInteractionId='QUPC_IN110000UK04' or $refToInteractionId='QUPC_IN180000UK03' or $refToInteractionId='QUPC_IN190000UK03'">
					<xsl:variable name="selector" select="java:com.syntegra.spine.csf.wrapper.xslt.ErrorCodeSystemExcluder.new('2.16.840.1.113883.2.1.3.2.4.17.32')"/>
					<xsl:value-of select="cache:iterate(java:getErrors($response),$selector,'DOMAINERRORS')"/>
					<xsl:variable name="domainError" select="cache:hasMore('DOMAINERRORS')"/>
					<xsl:value-of select="cache:remove('DOMAINERRORS')"/>
					<queryAck>
						<queryResponseCode>
							<xsl:if test="$domainError">
								<xsl:attribute name="code">ID</xsl:attribute>
							</xsl:if>
							<xsl:if test="not($domainError)">
								<xsl:attribute name="code">OK</xsl:attribute>
							</xsl:if>
						</queryResponseCode>
					</queryAck>
				</xsl:if>
			</ControlActEvent>
		<xsl:text disable-output-escaping="yes">&lt;/</xsl:text><xsl:value-of select="$interactionId"/><xsl:text disable-output-escaping="yes">&gt;</xsl:text>
	</xsl:template>

	<xsl:template name="renderRoleProfile">
		<xsl:variable name="authors" select="java:getAuthors($response)"/>
		<xsl:variable name="roleProfileId" select="translator:getFirstIdByType($authors,'1.2.826.0.1285.0.2.0.67')"/>
		<xsl:variable name="userId" select="translator:getFirstIdByType($authors,'1.2.826.0.1285.0.2.0.65')"/>
		<xsl:variable name="jobRoleId" select="translator:getFirstIdByType($authors,'1.2.826.0.1285.0.2.1.104')"/>
		<xsl:if test="translator:isDefined($roleProfileId)">
			<author typeCode="AUT">
				<AgentPersonSDS classCode="AGNT">
					<id>
						<xsl:attribute name="root"><xsl:value-of select="java:getRoot($roleProfileId)"/></xsl:attribute>
						<xsl:attribute name="extension"><xsl:value-of select="java:getExtension($roleProfileId)"/></xsl:attribute>
					</id>
					<agentPersonSDS classCode="PSN" determinerCode="INSTANCE">
						<id>
							<xsl:attribute name="root"><xsl:value-of select="java:getRoot($userId)"/></xsl:attribute>
							<xsl:attribute name="extension"><xsl:value-of select="java:getExtension($userId)"/></xsl:attribute>
						</id>
					</agentPersonSDS>
					<part typeCode="PART">
						<partSDSRole classCode="ROL">
							<id>
								<xsl:attribute name="root"><xsl:value-of select="java:getRoot($jobRoleId)"/></xsl:attribute>
								<xsl:attribute name="extension"><xsl:value-of select="java:getExtension($jobRoleId)"/></xsl:attribute>
							</id>
						</partSDSRole>
					</part>
				</AgentPersonSDS>
			</author>
		</xsl:if>
	</xsl:template>

	<xsl:template name="iterateSystemIds">
		<xsl:call-template name="renderSystemId"/>
		<xsl:if test="cache:hasMore('AUTHORS')">
			<xsl:call-template name="iterateSystemIds"/>
		</xsl:if>
	</xsl:template>

	<xsl:template name="renderSystemId">
		<xsl:variable name="systemId" select="cache:getNextId('AUTHORS')"/>
		<xsl:variable name="root" select="java:getRoot($systemId)"/>
		<xsl:if test="$root='1.2.826.0.1285.0.2.0.107' or $root='urn:spine:types:workstationId'"> <!-- URN for workstationId is a placeholder - awaiting OID -->
			<author1 typeCode="AUT">
				<AgentSystemSDS classCode="AGNT">
					<agentSystemSDS classCode="DEV" determinerCode="INSTANCE">
						<id>
							<xsl:attribute name="root"><xsl:value-of select="$root"/></xsl:attribute>
							<xsl:attribute name="extension"><xsl:value-of select="java:getExtension($systemId)"/></xsl:attribute>
						</id>
					</agentSystemSDS>
				</AgentSystemSDS>
			</author1>
		</xsl:if>
	</xsl:template>

	<xsl:template name="iterateDestinations">
		<xsl:call-template name="renderDestination"/>
		<xsl:if test="cache:hasMore('DESTINATIONS')">
			<xsl:call-template name="iterateDestinations"/>
		</xsl:if>
	</xsl:template>

	<xsl:template name="renderDestination">
		<xsl:variable name="device" select="cache:getNextId('DESTINATIONS')"/>
		<communicationFunctionRcv typeCode="RCV">
			<device>
				<id>
					<xsl:attribute name="root"><xsl:value-of select="java:getRoot($device)"/></xsl:attribute>
					<xsl:attribute name="extension"><xsl:value-of select="java:getExtension($device)"/></xsl:attribute>
				</id>
			</device>
		</communicationFunctionRcv>
	</xsl:template>

	<xsl:template name="iterateTMSErrors">
		<xsl:call-template name="renderTMSError"/>
		<xsl:if test="cache:hasMore('ERRORS')">
			<xsl:call-template name="iterateTMSErrors"/>
		</xsl:if>
	</xsl:template>

	<xsl:template name="renderTMSError">
		<xsl:variable name="error" select="cache:getNextError('ERRORS')"/>
		<xsl:if test="java:getCodeSystem($error)='2.16.840.1.113883.2.1.3.2.4.17.32'">	<!-- TMS namespace -->
			<acknowledgementDetail>
				<xsl:attribute name="typeCode">
					<xsl:value-of select="java:getSeverity($error)"/>
				</xsl:attribute>
				<code>
					<xsl:attribute name="code"><xsl:value-of select="java:getMessageCodeDetail($error)"/></xsl:attribute>
					<xsl:attribute name="displayName"><xsl:value-of select="java:getDescription($error)"/></xsl:attribute>
					<xsl:attribute name="codeSystem"><xsl:value-of select="java:getCodeSystem($error)"/></xsl:attribute>
				</code>
			</acknowledgementDetail>
		</xsl:if>
	</xsl:template>

	<xsl:template name="iterateDomainErrors">
		<xsl:call-template name="renderDomainError"/>
		<xsl:if test="cache:hasMore('ERRORS')">
			<xsl:call-template name="iterateDomainErrors"/>
		</xsl:if>
	</xsl:template>

	<xsl:template name="renderDomainError">
		<xsl:variable name="error" select="cache:getNextError('ERRORS')"/>
		<xsl:if test="java:getCodeSystem($error)!='2.16.840.1.113883.2.1.3.2.4.17.32'">	<!-- Domain namespace (i.e. not TMS) -->
			<reason typeCode="RSON">
				<justifyingDetectedIssueEvent classCode="ALRT" moodCode="EVN">
					<code>
						<xsl:attribute name="code">
							<xsl:value-of select="java:getMessageCodeDetail($error)"/>
						</xsl:attribute>								
						<xsl:attribute name="codeSystem">
							<xsl:value-of select="java:getCodeSystem($error)"/>
						</xsl:attribute>								
						<xsl:attribute name="displayName">
							<xsl:value-of select="java:getDescription($error)"/>
						</xsl:attribute>											
						<qualifier>
							<xsl:attribute name="code">
								<xsl:value-of select="java:getSeverity($error)"/>
							</xsl:attribute>
						</qualifier>						
					</code>
				</justifyingDetectedIssueEvent>
			</reason>	
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>