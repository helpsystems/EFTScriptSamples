
declare @count int
print 'Row counts before purge'
select @count =  count(*) from [dbo].[tbl_AdminActions] print 'tbl_AdminActions count = ' +CAST(@count AS NVARCHAR)
select @count =  count(*) from tbl_ProtocolCommands print 'tbl_ProtocolCommands count = ' +CAST(@count AS NVARCHAR)
select @count =  count(*) from tbl_Actions print 'tbl_Actions count = ' +CAST(@count AS NVARCHAR)
select @count =  count(*) from tbl_ClientOperations print 'tbl_ClientOperations count = ' +CAST(@count AS NVARCHAR)
select @count =  count(*) from tbl_SocketConnections print 'tbl_SocketConnections count = ' +CAST(@count AS NVARCHAR)
select @count =  count(*) from tbl_Authentications print 'tbl_Authentications count = ' +CAST(@count AS NVARCHAR)
select @count =  count(*) from tbl_CustomCommands print 'tbl_CustomCommands count = ' +CAST(@count AS NVARCHAR)
select @count =  count(*) from tbl_EventRules print 'tbl_EventRules count = ' +CAST(@count AS NVARCHAR)
select @count =  count(*) from tbl_Transactions print 'tbl_Transactions count = ' +CAST(@count AS NVARCHAR)