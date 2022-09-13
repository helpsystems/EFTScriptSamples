
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_tbl_Actions_TransactionID' AND object_id = OBJECT_ID('tbl_Actions'))
	CREATE NONCLUSTERED INDEX [IX_tbl_Actions_TransactionID] ON [tbl_Actions] ([TransactionID] ASC) WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_tbl_AdminActions_TransactionID' AND object_id = OBJECT_ID('tbl_AdminActions'))
	CREATE NONCLUSTERED INDEX [IX_tbl_AdminActions_TransactionID] ON [tbl_AdminActions] ([TransactionID] ASC) WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_tbl_AS2Actions_TransactionID' AND object_id = OBJECT_ID('tbl_AS2Actions'))
	CREATE NONCLUSTERED INDEX [IX_tbl_AS2Actions_TransactionID] ON [tbl_AS2Actions] ([TransactionID] ASC) WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_tbl_CustomCommands_TransactionID' AND object_id = OBJECT_ID('tbl_CustomCommands'))
	CREATE NONCLUSTERED INDEX [IX_tbl_CustomCommands_TransactionID] ON [tbl_CustomCommands] ([TransactionID] ASC) WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_tbl_Groups_AuthenticationID' AND object_id = OBJECT_ID('tbl_Groups'))
	CREATE NONCLUSTERED INDEX [IX_tbl_Groups_AuthenticationID] ON [tbl_Groups] ([AuthenticationID] ASC) WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_tbl_ProtocolCommands_TransactionID' AND object_id = OBJECT_ID('tbl_ProtocolCommands'))
	CREATE NONCLUSTERED INDEX [IX_tbl_ProtocolCommands_TransactionID] ON [tbl_ProtocolCommands] ([TransactionID] ASC) WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_tbl_SAT_Emails_txid' AND object_id = OBJECT_ID('tbl_SAT_Emails'))
	CREATE NONCLUSTERED INDEX [IX_tbl_SAT_Emails_txid] ON [tbl_SAT_Emails] ([txid] ASC) WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_tbl_SAT_Files_txid' AND object_id = OBJECT_ID('tbl_SAT_Files'))
	CREATE NONCLUSTERED INDEX [IX_tbl_SAT_Files_txid] ON [tbl_SAT_Files] ([txid] ASC) WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_tbl_SocketConnections_TransactionID' AND object_id = OBJECT_ID('tbl_SocketConnections'))
	CREATE NONCLUSTERED INDEX [IX_tbl_SocketConnections_TransactionID] ON [tbl_SocketConnections] ([TransactionID] ASC) WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_tbl_Transactions_ParentTransactionID' AND object_id = OBJECT_ID('tbl_Transactions'))
	CREATE NONCLUSTERED INDEX [IX_tbl_Transactions_ParentTransactionID] ON [tbl_Transactions] ([ParentTransactionID] ASC) WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_tbl_WorkspaceActions_TransactionID' AND object_id = OBJECT_ID('tbl_WorkspaceActions'))
	CREATE NONCLUSTERED INDEX [IX_tbl_WorkspaceActions_TransactionID] ON [tbl_WorkspaceActions] ([TransactionID] ASC) WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_tbl_WorkspaceActions_TransactionID' AND object_id = OBJECT_ID('tbl_WorkspaceParticipants'))
	CREATE NONCLUSTERED INDEX [IX_tbl_WorkspaceActions_TransactionID] ON [tbl_WorkspaceParticipants] ([WorkspaceActionID] ASC) WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO

-- Add indexes on time_stamps

-- tbl_SAT_Transactions
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_tbl_SAT_Transactions_Time_Stamp' AND object_id = OBJECT_ID('tbl_SAT_Transactions'))
	CREATE NONCLUSTERED INDEX [IX_tbl_SAT_Transactions_Time_Stamp] ON [tbl_SAT_Transactions] ([time_stamp] ASC) WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO

-- tbl_ProtocolCommands (index existed, but adding INCLUDE TransactionID)
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_tbl_ProtocolCommands_Time_stamp' AND object_id = OBJECT_ID('tbl_ProtocolCommands'))	
	DROP INDEX [IX_tbl_ProtocolCommands_Time_stamp] ON [tbl_ProtocolCommands]
GO
	CREATE NONCLUSTERED INDEX [IX_tbl_ProtocolCommands_Time_stamp] ON [tbl_ProtocolCommands] ([time_stamp]) INCLUDE ([TransactionID]) WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO

-- tbl_SocketConnections (index existed, but adding INCLUDE TransactionID)
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_tbl_SocketConnections_Time_stamp' AND object_id = OBJECT_ID('tbl_SocketConnections'))	
	DROP INDEX [IX_tbl_SocketConnections_Time_stamp] ON [tbl_SocketConnections]
GO
	CREATE NONCLUSTERED INDEX [IX_tbl_SocketConnections_Time_stamp] ON [tbl_SocketConnections] ([Time_stamp]) INCLUDE ([TransactionID]) WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO

-- tbl_Authentications (index existed, but adding Time_stamp)
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_tbl_Authentications_User_Name' AND object_id = OBJECT_ID('tbl_Authentications'))	
	DROP INDEX [IX_tbl_Authentications_User_Name] ON [tbl_Authentications]
GO
	CREATE NONCLUSTERED INDEX [IX_tbl_Authentications_User_Name] ON [tbl_Authentications] ([UserName],[Time_stamp]) INCLUDE ([TransactionID]) WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO

-- tbl_ScanDataActions
/*
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_tbl_ScanDataActions_Time_Stamp' AND object_id = OBJECT_ID('tbl_ScanDataActions'))	
	DROP INDEX [IX_tbl_ScanDataActions_Time_Stamp] ON [tbl_ScanDataActions]
GO
	CREATE NONCLUSTERED INDEX [IX_tbl_ScanDataActions_Time_Stamp] ON [tbl_ScanDataActions] ([Time_stamp]) INCLUDE ([ActionID]) WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO
*/

