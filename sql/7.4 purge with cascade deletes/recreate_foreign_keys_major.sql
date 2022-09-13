-- recreate_foreign_keys.sql
-- Delete orphan records for any cascade delete foreign key constraints
-- 1. Test to see if any orphan records in sub-tables
-- 2. If orphan records exist
--    a. Drop the constraint between the table and parent table
--    b. Delete the orphan records
--    c. Recreate the constraint with the cascade delete

-- ****************************
-- tbl_Transactions constraints
-- ****************************

-- tbl_AdminActions
-- IF EXISTS (SELECT * FROM tbl_AdminActions WHERE transactionID NOT IN (SELECT transactionID FROM tbl_Transactions))
BEGIN
	-- Drop constraint
	IF EXISTS (SELECT * FROM sys.foreign_keys 
		WHERE object_id = OBJECT_ID(N'FK_tbl_AdminActions_TransID') AND parent_object_id = OBJECT_ID(N'tbl_AdminActions'))
		ALTER TABLE tbl_AdminActions DROP CONSTRAINT FK_tbl_AdminActions_TransID;
	-- Make sure no orphans remaining
	DELETE FROM tbl_AdminActions WHERE transactionID NOT IN 
		(SELECT transactionID FROM tbl_Transactions);
	-- Now, add it back with cascade delete enabled
	ALTER TABLE tbl_AdminActions ADD CONSTRAINT FK_tbl_AdminActions_TransID
	FOREIGN KEY (TransactionID)
	REFERENCES tbl_Transactions (TransactionID)
	ON DELETE CASCADE;
END
-- tbl_Authentications
-- IF EXISTS (SELECT * FROM tbl_Authentications WHERE transactionID NOT IN (SELECT transactionID FROM tbl_Transactions))
BEGIN
	-- Drop constraint
	IF EXISTS (SELECT * FROM sys.foreign_keys 
		WHERE object_id = OBJECT_ID(N'FK_tbl_Auth_TransID') AND parent_object_id = OBJECT_ID(N'tbl_Authentications'))
		ALTER TABLE tbl_Authentications DROP CONSTRAINT FK_tbl_Auth_TransID;
	-- Make sure no orphans remaining
	DELETE FROM tbl_Authentications WHERE transactionID NOT IN 
		(SELECT transactionID FROM tbl_Transactions);
	-- Now, add it back with cascade delete enabled
	ALTER TABLE tbl_Authentications ADD CONSTRAINT FK_tbl_Auth_TransID
	FOREIGN KEY (TransactionID)
	REFERENCES tbl_Transactions (TransactionID)
	ON DELETE CASCADE;
END
-- tbl_ClientOperations
-- IF EXISTS (SELECT * FROM tbl_ClientOperations WHERE transactionID NOT IN (SELECT transactionID FROM tbl_Transactions))
BEGIN
	-- Drop constraint
	IF EXISTS (SELECT * FROM sys.foreign_keys 
		WHERE object_id = OBJECT_ID(N'FK_tbl_ClientOperations_TransID') AND parent_object_id = OBJECT_ID(N'tbl_ClientOperations'))
		ALTER TABLE tbl_ClientOperations DROP CONSTRAINT FK_tbl_ClientOperations_TransID;
	-- Make sure no orphans remaining
	DELETE FROM tbl_ClientOperations WHERE transactionID NOT IN 
		(SELECT transactionID FROM tbl_Transactions);
	-- Now, add it back with cascade delete enabled
	ALTER TABLE tbl_ClientOperations ADD CONSTRAINT FK_tbl_ClientOperations_TransID
	FOREIGN KEY (TransactionID)
	REFERENCES tbl_Transactions (TransactionID)
	ON DELETE CASCADE;
END
-- tbl_CustomCommands
-- IF EXISTS (SELECT * FROM tbl_CustomCommands WHERE transactionID NOT IN (SELECT transactionID FROM tbl_Transactions))
BEGIN
	-- Drop constraint
	IF EXISTS (SELECT * FROM sys.foreign_keys 
		WHERE object_id = OBJECT_ID(N'FK_tbl_CustomCommands_TransID') AND parent_object_id = OBJECT_ID(N'tbl_CustomCommands'))
		ALTER TABLE tbl_CustomCommands DROP CONSTRAINT FK_tbl_CustomCommands_TransID;
	-- Make sure no orphans remaining
	DELETE FROM tbl_CustomCommands WHERE transactionID NOT IN 
		(SELECT transactionID FROM tbl_Transactions);
	-- Now, add it back with cascade delete enabled
	ALTER TABLE tbl_CustomCommands ADD CONSTRAINT FK_tbl_CustomCommands_TransID
	FOREIGN KEY (TransactionID)
	REFERENCES tbl_Transactions (TransactionID)
	ON DELETE CASCADE;
END
-- tbl_EventRules
-- IF EXISTS (SELECT * FROM tbl_EventRules WHERE transactionID NOT IN (SELECT transactionID FROM tbl_Transactions))
BEGIN
	-- Drop constraint
	IF EXISTS (SELECT * FROM sys.foreign_keys 
		WHERE object_id = OBJECT_ID(N'FK_tbl_EventRules_TransID') AND parent_object_id = OBJECT_ID(N'tbl_EventRules'))
		ALTER TABLE tbl_EventRules DROP CONSTRAINT FK_tbl_EventRules_TransID;
	-- Make sure no orphans remaining
	DELETE FROM tbl_EventRules WHERE transactionID NOT IN 
		(SELECT transactionID FROM tbl_Transactions);
	-- Now, add it back with cascade delete enabled
	ALTER TABLE tbl_EventRules ADD CONSTRAINT FK_tbl_EventRules_TransID
	FOREIGN KEY (TransactionID)
	REFERENCES tbl_Transactions (TransactionID)
	ON DELETE CASCADE;
END
-- tbl_EventRuleTransfers
/*
-- IF EXISTS (SELECT * FROM tbl_EventRuleTransfers WHERE transactionID NOT IN (SELECT transactionID FROM tbl_Transactions))
BEGIN
	-- Drop constraint
	IF EXISTS (SELECT * FROM sys.foreign_keys 
		WHERE object_id = OBJECT_ID(N'FK_tbl_EventRuleTransfers_TransactionID') AND parent_object_id = OBJECT_ID(N'tbl_EventRuleTransfers'))
		ALTER TABLE tbl_EventRuleTransfers DROP CONSTRAINT FK_tbl_EventRuleTransfers_TransactionID;
	-- Make sure no orphans remaining
	DELETE FROM tbl_EventRuleTransfers WHERE transactionID NOT IN 
		(SELECT transactionID FROM tbl_Transactions);
	-- Now, add it back with cascade delete enabled
	ALTER TABLE tbl_EventRuleTransfers ADD CONSTRAINT FK_tbl_EventRuleTransfers_TransactionID
	FOREIGN KEY (TransactionID)
	REFERENCES tbl_Transactions (TransactionID)
	ON DELETE CASCADE;
END
*/
-- tbl_ProtocolCommands
-- IF EXISTS (SELECT * FROM tbl_ProtocolCommands WHERE transactionID NOT IN (SELECT transactionID FROM tbl_Transactions))
BEGIN
	-- Drop constraint
	IF EXISTS (SELECT * FROM sys.foreign_keys 
		WHERE object_id = OBJECT_ID(N'FK_tbl_ProtocolCommands_TransID') AND parent_object_id = OBJECT_ID(N'tbl_ProtocolCommands'))
		ALTER TABLE tbl_ProtocolCommands DROP CONSTRAINT FK_tbl_ProtocolCommands_TransID;
	-- Make sure no orphans remaining
	DELETE FROM tbl_ProtocolCommands WHERE transactionID NOT IN 
		(SELECT transactionID FROM tbl_Transactions);
	-- Now, add it back with cascade delete enabled
	ALTER TABLE tbl_ProtocolCommands ADD CONSTRAINT FK_tbl_ProtocolCommands_TransID
	FOREIGN KEY (TransactionID)
	REFERENCES tbl_Transactions (TransactionID)
	ON DELETE CASCADE;
END
-- tbl_SocketConnections
-- IF EXISTS (SELECT * FROM tbl_SocketConnections WHERE transactionID NOT IN (SELECT transactionID FROM tbl_Transactions))
BEGIN
	-- Drop constraint
	IF EXISTS (SELECT * FROM sys.foreign_keys 
		WHERE object_id = OBJECT_ID(N'FK_tbl_SocketConnections_TransID') AND parent_object_id = OBJECT_ID(N'tbl_SocketConnections'))
		ALTER TABLE tbl_SocketConnections DROP CONSTRAINT FK_tbl_SocketConnections_TransID;
	-- Make sure no orphans remaining
	DELETE FROM tbl_SocketConnections WHERE transactionID NOT IN 
		(SELECT transactionID FROM tbl_Transactions);
	-- Now, add it back with cascade delete enabled
	ALTER TABLE tbl_SocketConnections ADD CONSTRAINT FK_tbl_SocketConnections_TransID
	FOREIGN KEY (TransactionID)
	REFERENCES tbl_Transactions (TransactionID)
	ON DELETE CASCADE;
END
-- tbl_WorkspaceActions
/*
-- IF EXISTS (SELECT * FROM tbl_WorkspaceActions WHERE transactionID NOT IN (SELECT transactionID FROM tbl_Transactions))
BEGIN
	-- Drop constraint
	IF EXISTS (SELECT * FROM sys.foreign_keys 
		WHERE object_id = OBJECT_ID(N'FK_tbl_WorkspaceActions_TransID') AND parent_object_id = OBJECT_ID(N'tbl_WorkspaceActions'))
		ALTER TABLE tbl_WorkspaceActions DROP CONSTRAINT FK_tbl_WorkspaceActions_TransID;
	-- Make sure no orphans remaining
	DELETE FROM tbl_WorkspaceActions WHERE transactionID NOT IN 
		(SELECT transactionID FROM tbl_Transactions);
	-- Now, add it back with cascade delete enabled
	ALTER TABLE tbl_WorkspaceActions ADD CONSTRAINT FK_tbl_WorkspaceActions_TransID
	FOREIGN KEY (TransactionID)
	REFERENCES tbl_Transactions (TransactionID)
	ON DELETE CASCADE;
END
*/
-- *****************
-- Other constraints
-- *****************

-- tbl_ScanDataActions -> tbl_Actions
/*
IF EXISTS (SELECT * FROM tbl_ScanDataActions WHERE ActionID NOT IN 
		(SELECT ActionID FROM tbl_Actions))
BEGIN
	-- Drop constraint
	IF EXISTS (SELECT * FROM sys.foreign_keys 
		WHERE object_id = OBJECT_ID(N'FK_tbl_ScanDataActions_ActionID') AND parent_object_id = OBJECT_ID(N'tbl_ScanDataActions'))
		ALTER TABLE tbl_ScanDataActions DROP CONSTRAINT FK_tbl_ScanDataActions_ActionID;
	-- Make sure no orphans remaining
	DELETE FROM tbl_ScanDataActions WHERE ActionID NOT IN 
		(SELECT ActionID FROM tbl_Actions);
	-- Now, add it back with cascade delete enabled
	ALTER TABLE tbl_ScanDataActions ADD CONSTRAINT FK_tbl_ScanDataActions_ActionID
	FOREIGN KEY (ActionID)
	REFERENCES tbl_Actions (ActionID)
	ON DELETE CASCADE;
END
*/
-- tbl_Groups -> tbl_Authentications
-- IF EXISTS (SELECT * FROM tbl_Groups WHERE AuthenticationID NOT IN (SELECT AuthenticationID FROM tbl_Authentications))
BEGIN
	-- Drop constraint
	IF EXISTS (SELECT * FROM sys.foreign_keys 
		WHERE object_id = OBJECT_ID(N'FK_tbl_Groups_AuthID') AND parent_object_id = OBJECT_ID(N'tbl_Groups'))
		ALTER TABLE tbl_Groups DROP CONSTRAINT FK_tbl_Groups_AuthID;
	-- Make sure no orphans remaining
	DELETE FROM tbl_Groups WHERE AuthenticationID NOT IN 
		(SELECT AuthenticationID FROM tbl_Authentications);
	-- Now, add it back with cascade delete enabled
	ALTER TABLE tbl_Groups ADD CONSTRAINT FK_tbl_Groups_AuthID
	FOREIGN KEY (AuthenticationID)
	REFERENCES tbl_Authentications (AuthenticationID)
	ON DELETE CASCADE;
END
-- tbl_Actions -> tbl_EventRules
-- IF EXISTS (SELECT * FROM tbl_Actions WHERE EventID NOT IN (SELECT EventID FROM tbl_EventRules))
BEGIN
	-- Drop constraint
	IF EXISTS (SELECT * FROM sys.foreign_keys 
		WHERE object_id = OBJECT_ID(N'FK_tbl_Actions_EventId') AND parent_object_id = OBJECT_ID(N'tbl_Actions'))
		ALTER TABLE tbl_Actions DROP CONSTRAINT FK_tbl_Actions_EventId;
	-- Make sure no orphans remaining
	DELETE FROM tbl_Actions WHERE EventID NOT IN 
		(SELECT EventID FROM tbl_EventRules);
	-- Now, add it back with cascade delete enabled
	ALTER TABLE tbl_Actions ADD CONSTRAINT FK_tbl_Actions_EventId
	FOREIGN KEY (EventID)
	REFERENCES tbl_EventRules (EventID)
	ON DELETE CASCADE;
END
-- tbl_Groups -> tbl_Authentications
-- IF EXISTS (SELECT * FROM tbl_Groups WHERE AuthenticationID NOT IN (SELECT AuthenticationID FROM tbl_Authentications))
BEGIN
	-- Drop constraint
	IF EXISTS (SELECT * FROM sys.foreign_keys 
		WHERE object_id = OBJECT_ID(N'FK_tbl_Groups_AuthID') AND parent_object_id = OBJECT_ID(N'tbl_Groups'))
		ALTER TABLE tbl_Groups DROP CONSTRAINT FK_tbl_Groups_AuthID;
	-- Make sure no orphans remaining
	DELETE FROM tbl_Groups WHERE AuthenticationID NOT IN 
		(SELECT AuthenticationID FROM tbl_Authentications);
	-- Now, add it back with cascade delete enabled
	ALTER TABLE tbl_Groups ADD CONSTRAINT FK_tbl_Groups_AuthID
	FOREIGN KEY (AuthenticationID)
	REFERENCES tbl_Authentications (AuthenticationID)
	ON DELETE CASCADE;
END
-- tbl_SAT_Emails -> tbl_SAT_Transactions
-- IF EXISTS (SELECT * FROM tbl_SAT_Emails WHERE txid NOT IN (SELECT ID FROM tbl_SAT_Transactions))
BEGIN
	-- Drop constraint
	IF EXISTS (SELECT * FROM sys.foreign_keys 
		WHERE object_id = OBJECT_ID(N'FK_tbl_SAT_Emails_TxID') AND parent_object_id = OBJECT_ID(N'tbl_SAT_Emails'))
		ALTER TABLE tbl_SAT_Emails DROP CONSTRAINT FK_tbl_SAT_Emails_TxID;
	-- Make sure no orphans remaining
	DELETE FROM tbl_SAT_Emails WHERE txid NOT IN 
		(SELECT ID FROM tbl_SAT_Transactions);
	-- Now, add it back with cascade delete enabled
	ALTER TABLE tbl_SAT_Emails ADD CONSTRAINT FK_tbl_SAT_Emails_TxID
	FOREIGN KEY (txid)
	REFERENCES tbl_SAT_Transactions (ID)
	ON DELETE CASCADE;
END
-- tbl_SAT_Files -> tbl_SAT_Transactions
-- IF EXISTS (SELECT * FROM tbl_SAT_Files WHERE txid NOT IN (SELECT ID FROM tbl_SAT_Transactions))
BEGIN
	-- Drop constraint
	IF EXISTS (SELECT * FROM sys.foreign_keys 
		WHERE object_id = OBJECT_ID(N'FK_tbl_SAT_Files_TxID') AND parent_object_id = OBJECT_ID(N'tbl_SAT_Files'))
		ALTER TABLE tbl_SAT_Files DROP CONSTRAINT FK_tbl_SAT_Files_TxID;
	-- Make sure no orphans remaining
	DELETE FROM tbl_SAT_Files WHERE txid NOT IN 
		(SELECT ID FROM tbl_SAT_Transactions);
	-- Now, add it back with cascade delete enabled
	ALTER TABLE tbl_SAT_Files ADD CONSTRAINT FK_tbl_SAT_Files_TxID
	FOREIGN KEY (txid)
	REFERENCES tbl_SAT_Transactions (ID)
	ON DELETE CASCADE;
END
-- tbl_WorkspaceParticipants -> tbl_WorkspaceActions
-- IF EXISTS (SELECT * FROM tbl_WorkspaceParticipants WHERE WorkspaceActionID NOT IN (SELECT ID FROM tbl_WorkspaceActions))
/*
BEGIN
	-- Drop constraint
IF EXISTS (SELECT * FROM sys.foreign_keys 
   WHERE object_id = OBJECT_ID(N'FK_tbl_WorkspaceParticipants_WorkspaceActionID') AND parent_object_id = OBJECT_ID(N'tbl_WorkspaceParticipants'))
	ALTER TABLE tbl_WorkspaceParticipants DROP CONSTRAINT FK_tbl_WorkspaceParticipants_WorkspaceActionID;
	-- Make sure no orphans remaining
	DELETE FROM tbl_WorkspaceParticipants WHERE WorkspaceActionID NOT IN 
		(SELECT ID FROM tbl_WorkspaceActions);
	-- Now, add it back with cascade delete enabled
	ALTER TABLE tbl_WorkspaceParticipants ADD CONSTRAINT FK_tbl_WorkspaceParticipants_WorkspaceActionID
	FOREIGN KEY (WorkspaceActionID)
	REFERENCES tbl_WorkspaceActions (ID)
	ON DELETE CASCADE;
END
*/

-- Re-create FK constraint between ParentTransactionID and TransactionID 
-- Drop constraint
IF EXISTS (SELECT * FROM sys.foreign_keys 
   WHERE object_id = OBJECT_ID(N'FK_tbl_Transactions_ParentTransID') AND parent_object_id = OBJECT_ID(N'tbl_Transactions'))
	ALTER TABLE tbl_Transactions DROP CONSTRAINT FK_tbl_Transactions_ParentTransID;
-- Make sure no orphans remaining
DELETE FROM tbl_Transactions WHERE ParentTransactionID IS NOT NULL AND ParentTransactionID NOT IN 
	(SELECT transactionID FROM tbl_Transactions);
-- Now, add it back without cascade delete enabled
ALTER TABLE tbl_Transactions ADD CONSTRAINT FK_tbl_Transactions_ParentTransID
FOREIGN KEY (ParentTransactionID)
REFERENCES tbl_Transactions (TransactionID)
ON DELETE NO ACTION;
