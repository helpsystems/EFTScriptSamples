-- For reports Activity-AS2 Transfers (Detailed) and Activity-AS2 Transfers (Summary)
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_tbl_AS2Transactions_StartTime' AND object_id = OBJECT_ID('tbl_AS2Transactions'))
  DROP INDEX IX_tbl_AS2Transactions_StartTime ON tbl_AS2Transactions
GO
CREATE INDEX IX_tbl_AS2Transactions_StartTime ON tbl_AS2Transactions (StartTime)
GO
UPDATE STATISTICS tbl_AS2Transactions; 
GO

-- For reports Activity-by Permissions Group, Activity-by Users (Detailed), 
-- Activity-by Users (Summary), Exec Summary, Traffic-Average Transfer Rates by User,
-- WebServiceInvokeEventRules-Activity(Detailed)
-- Remove IX_tbl_ProtocolCommands_Time_stamp since won't be necessary
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_tbl_ProtocolCommands_Time_stamp' AND object_id = OBJECT_ID('tbl_ProtocolCommands'))
	DROP INDEX IX_tbl_ProtocolCommands_Time_stamp ON tbl_ProtocolCommands
GO
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_tbl_ProtocolCommands_Time_stamp_Command_FileName' AND object_id = OBJECT_ID('tbl_ProtocolCommands'))
	DROP INDEX IX_tbl_ProtocolCommands_Time_stamp_Command_FileName ON tbl_ProtocolCommands
GO
CREATE INDEX IX_tbl_ProtocolCommands_Time_stamp_Command_FileName ON tbl_ProtocolCommands (Time_stamp, Command, FileName)
GO
UPDATE STATISTICS tbl_ProtocolCommands; 
GO

-- For reports Traffic - Connections Summary, Traffic-Datewise-hourly Bytes Transferred,
-- Traffic-Datewise-IPwiseBytesTransferred, Traffic-Monthwise-IPWise Bytes Transferred,
-- Traffic-Protocolwise Connections
-- Remove IX_tbl_ProtocolCommands_Site_Name since won't be necessary
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_tbl_ProtocolCommands_Site_Name' AND object_id = OBJECT_ID('tbl_ProtocolCommands'))
	DROP INDEX IX_tbl_ProtocolCommands_Site_Name ON tbl_ProtocolCommands
GO
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_tbl_ProtocolCommands_Site_Name_Time_stamp' AND object_id = OBJECT_ID('tbl_ProtocolCommands'))
	DROP INDEX IX_tbl_ProtocolCommands_Site_Name_Time_stamp ON tbl_ProtocolCommands
GO
CREATE INDEX IX_tbl_ProtocolCommands_Site_Name_Time_stamp ON tbl_ProtocolCommands (SiteName, Time_stamp)
GO
UPDATE STATISTICS tbl_ProtocolCommands; 
GO

-- For reports Traffic-Most Active IP Connections, Traffic-Most Active IP - Data Transferred
-- Remove IX_tbl_ProtocolCommands_TransactionID since won't be necessary
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_tbl_ProtocolCommands_TransactionID' AND object_id = OBJECT_ID('tbl_ProtocolCommands'))
	DROP INDEX IX_tbl_ProtocolCommands_TransactionID ON tbl_ProtocolCommands
GO
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_tbl_ProtocolCommands_TransactionID_Time_Stamp_ResultID' AND object_id = OBJECT_ID('tbl_ProtocolCommands'))
	DROP INDEX IX_tbl_ProtocolCommands_TransactionID_Time_Stamp_ResultID ON tbl_ProtocolCommands
GO
CREATE INDEX IX_tbl_ProtocolCommands_TransactionID_Time_Stamp_ResultID ON tbl_ProtocolCommands (TransactionID, Time_stamp, ResultID)
GO
UPDATE STATISTICS tbl_ProtocolCommands; 
GO

-- For Admin-Audit Log
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_tbl_AdminActions_Time_stamp' AND object_id = OBJECT_ID('tbl_AdminActions'))
	DROP INDEX IX_tbl_AdminActions_Time_stamp ON tbl_AdminActions
GO
CREATE INDEX IX_tbl_AdminActions_Time_stamp ON tbl_AdminActions (Timestamp)
GO
UPDATE STATISTICS tbl_AdminActions; 
GO

-- For Admin-Authentications
-- Remove IX_tbl_Authentications_Time_stamp since won't be necessary
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_tbl_Authentications_Time_stamp' AND object_id = OBJECT_ID('tbl_Authentications'))
	DROP INDEX IX_tbl_Authentications_Time_stamp ON tbl_Authentications
GO
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_tbl_Authentications_Time_stamp_Protocol' AND object_id = OBJECT_ID('tbl_Authentications'))
	DROP INDEX IX_tbl_Authentications_Time_stamp_Protocol ON tbl_Authentications
GO
CREATE INDEX IX_tbl_Authentications_Time_stamp_Protocol ON tbl_Authentications (Time_stamp, Protocol)
GO
UPDATE STATISTICS tbl_Authentications; 
GO

-- For Troubleshooting-Failed Logins
-- Remove IX_tbl_Authentications_Time_stamp since won't be necessary
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_tbl_Authentications_Time_stamp' AND object_id = OBJECT_ID('tbl_Authentications'))
	DROP INDEX IX_tbl_Authentications_Time_stamp ON tbl_Authentications
GO
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_tbl_Authentications_Time_stamp_SiteName_ResultID' AND object_id = OBJECT_ID('tbl_Authentications'))
	DROP INDEX IX_tbl_Authentications_Time_stamp_SiteName_ResultID ON tbl_Authentications
GO
CREATE INDEX IX_tbl_Authentications_Time_stamp_SiteName_ResultID ON tbl_Authentications (Time_stamp, SiteName, ResultID)
GO
UPDATE STATISTICS tbl_Authentications; 
GO

-- Content Integrity Control
-- [Nothing]

-- Reports: Event Rules (all), Troubleshooting-Event Rules Failuer 
-- Remove IX_tbl_Actions_Time_stamp since won't be necessary
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_tbl_Actions_Time_stamp' AND object_id = OBJECT_ID('tbl_Actions'))
	DROP INDEX IX_tbl_Actions_Time_stamp ON tbl_Actions
GO
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_tbl_Actions_Time_stamp_EventID_TransactionID' AND object_id = OBJECT_ID('tbl_Actions'))
	DROP INDEX IX_tbl_Actions_Time_stamp_EventID_TransactionID ON tbl_Actions
GO
CREATE INDEX IX_tbl_Actions_Time_stamp_EventID_TransactionID ON tbl_Actions (Time_stamp, EventID, TransactionID)
GO
UPDATE STATISTICS tbl_Actions; 
GO

-- Event Rules - Just Transfers
-- Remove IX_tbl_EventRules_Time_stamp since won't be necessary
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_tbl_EventRules_Time_stamp' AND object_id = OBJECT_ID('tbl_EventRules'))
	DROP INDEX IX_tbl_EventRules_Time_stamp ON tbl_EventRules
GO
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_tbl_EventRules_Time_stamp_TransactionID' AND object_id = OBJECT_ID('tbl_EventRules'))
	DROP INDEX IX_tbl_EventRules_Time_stamp_TransactionID ON tbl_EventRules
GO
CREATE INDEX IX_tbl_EventRules_Time_stamp_TransactionID ON tbl_EventRules (Time_stamp, TransactionID)
GO
UPDATE STATISTICS tbl_EventRules; 
GO

-- For Troubleshooting-Socket Connection Errors
-- Remove IX_tbl_SocketConnections_Time_stamp since won't be necessary
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_tbl_SocketConnections_Time_stamp' AND object_id = OBJECT_ID('tbl_SocketConnections'))
	DROP INDEX IX_tbl_SocketConnections_Time_stamp ON tbl_SocketConnections
GO
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_tbl_SocketConnections_Time_stamp_ResultID' AND object_id = OBJECT_ID('tbl_SocketConnections'))
	DROP INDEX IX_tbl_SocketConnections_Time_stamp_ResultID ON tbl_SocketConnections
GO
CREATE INDEX IX_tbl_SocketConnections_Time_stamp_ResultID ON tbl_SocketConnections (Time_stamp, ResultID)
GO
UPDATE STATISTICS tbl_SocketConnections; 
GO

-- For Workspaces-Files Picked Up
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_tbl_OutlookReport_Type_TransactionDate' AND object_id = OBJECT_ID('tbl_OutlookReport'))
	DROP INDEX IX_tbl_OutlookReport_Type_TransactionDate ON tbl_OutlookReport
GO
CREATE INDEX IX_tbl_OutlookReport_Type_TransactionDate ON tbl_OutlookReport (Type, TransactionDate)
GO
-- For Workspaces-Folders Shared, Unshared reports
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_tbl_OutlookReport_WorkspaceID' AND object_id = OBJECT_ID('tbl_OutlookReport'))
	DROP INDEX IX_tbl_OutlookReport_WorkspaceID ON tbl_OutlookReport
GO
CREATE INDEX IX_tbl_OutlookReport_WorkspaceID ON tbl_OutlookReport (WorkspaceID)
GO
UPDATE STATISTICS tbl_OutlookReport; 
GO

-- For Workspaces-Folders Shared, Unshared reports
-- Remove IX_tbl_WorkspaceActions_Time_stamp since won't be necessary
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_tbl_WorkspaceActions_Time_stamp' AND object_id = OBJECT_ID('tbl_WorkspaceActions'))
	DROP INDEX IX_tbl_WorkspaceActions_Time_stamp ON tbl_WorkspaceActions
GO
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_tbl_WorkspaceActions_Time_stamp_Action' AND object_id = OBJECT_ID('tbl_WorkspaceActions'))
	DROP INDEX IX_tbl_WorkspaceActions_Time_stamp_Action ON tbl_WorkspaceActions
GO
CREATE INDEX IX_tbl_WorkspaceActions_Time_stamp_Action ON tbl_WorkspaceActions (Time_stamp, Action)
GO
UPDATE STATISTICS tbl_WorkspaceActions; 
GO