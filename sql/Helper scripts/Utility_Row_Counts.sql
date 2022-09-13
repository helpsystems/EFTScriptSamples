/*

WHAT: 
Records the number of rows in each table

WHY:
Can be useful to count rows before and after a purge.

WHEN:
Created in April of 2019

WHO:
Created by Globalscape, Inc.

HOW:
Row count can take several minutes depending on the size of the database

*/


declare @count int
select @count =  count(*) from tbl_Actions
print 'tbl_Actions count = ' +CAST(@count AS NVARCHAR)

select @count =  count(*) from tbl_AdminActions
print 'tbl_AdminActions count = ' +CAST(@count AS NVARCHAR)

select @count =  count(*) from tbl_AS2Actions
print 'tbl_AS2Actions count = ' +CAST(@count AS NVARCHAR)

select @count =  count(*) from tbl_AS2Transactions
print 'tbl_AS2Transactions count = ' +CAST(@count AS NVARCHAR)

select @count =  count(*) from tbl_Authentications
print 'tbl_Authentications count = ' +CAST(@count AS NVARCHAR)

select @count =  count(*) from tbl_AuthenticationsExpired
print 'tbl_AuthenticationsExpired count = ' +CAST(@count AS NVARCHAR)

select @count =  count(*) from tbl_AWESteps
print 'tbl_AWESteps count = ' +CAST(@count AS NVARCHAR)

select @count =  count(*) from tbl_ClientOperations
print 'tbl_ClientOperations count = ' +CAST(@count AS NVARCHAR)

select @count =  count(*) from tbl_CustomCommands
print 'tbl_CustomCommands count = ' +CAST(@count AS NVARCHAR)

select @count =  count(*) from tbl_EventRules
print 'tbl_EventRules count = ' +CAST(@count AS NVARCHAR)

select @count =  count(*) from tbl_EventRuleTransfers
print 'tbl_EventRuleTransfers count = ' +CAST(@count AS NVARCHAR)

select @count =  count(*) from tbl_Groups
print 'tbl_Groups count = ' +CAST(@count AS NVARCHAR)

select @count =  count(*) from tbl_NegotiatedCiphersSSH
print 'tbl_NegotiatedCiphersSSH count = ' +CAST(@count AS NVARCHAR)

select @count =  count(*) from tbl_NegotiatedCiphersSSL
print 'tbl_NegotiatedCiphersSSL count = ' +CAST(@count AS NVARCHAR)

select @count =  count(*) from tbl_OutlookReport
print 'tbl_OutlookReport count = ' +CAST(@count AS NVARCHAR)

select @count =  count(*) from tbl_PCIViolations
print 'tbl_PCIViolations count = ' +CAST(@count AS NVARCHAR)

select @count =  count(*) from tbl_PersonalDataActions
print 'tbl_PersonalDataActions count = ' +CAST(@count AS NVARCHAR)

select @count =  count(*) from tbl_PrivacyTermsEUStatus
print 'tbl_PrivacyTermsEUStatus count = ' +CAST(@count AS NVARCHAR)

select @count =  count(*) from tbl_ProtocolCommands
print 'tbl_ProtocolCommands count = ' +CAST(@count AS NVARCHAR)

select @count =  count(*) from tbl_PrivacyRightExercised
print 'tbl_PrivacyRightExercised count = ' +CAST(@count AS NVARCHAR)

select @count =  count(*) from tbl_ScanDataActions
print 'tbl_ScanDataActions count = ' +CAST(@count AS NVARCHAR)

select @count =  count(*) from tbl_ServerInternalEvents
print 'tbl_ServerInternalEvents count = ' +CAST(@count AS NVARCHAR)

select @count =  count(*) from tbl_SocketConnections
print 'tbl_SocketConnections count = ' +CAST(@count AS NVARCHAR)

select @count =  count(*) from tbl_Transactions
print 'tbl_Transactions count = ' +CAST(@count AS NVARCHAR)

select @count =  count(*) from tbl_WorkspaceActions
print 'tbl_WorkspaceActions count = ' +CAST(@count AS NVARCHAR)

select @count =  count(*) from tbl_WorkspaceParticipants
print 'tbl_WorkspaceParticipants count = ' +CAST(@count AS NVARCHAR)