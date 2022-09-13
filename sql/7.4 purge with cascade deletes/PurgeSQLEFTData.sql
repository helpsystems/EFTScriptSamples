-- EFT Purging Script
-- Goal:	Allow customers to purge data from EFT's ARM database

--USAGE
/*
1. Run recreate_foreign_keys.sql next, as it will fix any problems if present (see notes in that script)
2. Run index_foreign_keys_and_time_stamps.sql first, as that will improve purge performance
3. Modify the purge date if desired. -30 means purge all records older than 30 days
	3a. To change: search for "SET @stopTime = DATEADD(DAY, -30, GETDATE())"
	3b. A value of -0 means ALL records
	3c. Alternatively, you can pass in an exact date range:
		3ci. Search for EXEC sp_PurgeEFTTransactions NULL, NULL, 1000000, 1 
		3cii. Enter date and times in quotes as such: EXEC sp_PurgeEFTTransactions '2019-01-20 18:11:00', '2019-04-01 07:50:00', 1000000, 1 
4. Modify "USE EFTDB" below if your database name is different
5. Make sure you database isn't actively recording data (disable ARM reporting in EFT temporarily)
6. Execute the script (it can take several hours for databases with hundreds of millions of records)
*/

-- Change Log:
--	0.1:	Set batch size at 100,000
--			Removed SELECT and extra PRINT statements.
--	0.2:	Changed to purge up to records greater than 30 days old 
--	0.3:	Modified script to not assume cascading deletes and to
--			explicitly delete from all tables
--			Modified script to default 'purgesize' to 10,000
--			instead of 1,000
--	0.4		Added AS2 and SAT purging
--  0.5     Subset table wasn't being dropped.
--  0.6     Changed to all static calls instead of dynamic.  
--  0.7		Changed purge size to 1,000,000
--  0.8		Brought back cascade deletes to speed up performance

--USE EFTDB

-- Include minutes/seconds
PRINT 'Script started at: ' + CONVERT(varchar(30),CURRENT_TIMESTAMP,109) 
-- PRINT 'Script started at: ' + CAST(CURRENT_TIMESTAMP AS NVARCHAR)
-- USE EFTDB741315

-- This procedure will print the version of this script
IF OBJECT_ID('dbo.sp_PurgeEFTTransactionsVersion') IS NOT NULL
	DROP PROC dbo.sp_PurgeEFTTransactionsVersion
GO

CREATE PROCEDURE sp_PurgeEFTTransactionsVersion
AS
	PRINT 'GlobalSCAPE, Inc. Purge Script Version 0.6'
GO

-- This procedure will delete EFT transactions from a all tables.
IF OBJECT_ID('dbo.sp_PurgeEFTTransactions') IS NOT NULL BEGIN
	DROP PROC dbo.sp_PurgeEFTTransactions
END
GO

-- By default, this procedure will purge data from 1970 to 60 days ago.
CREATE PROCEDURE sp_PurgeEFTTransactions	@startTime	datetime = NULL,
											@stopTime	datetime = NULL,
											@purgeSize	int = NULL,
											@debug		bit = 0
AS
BEGIN
	DECLARE @r INT;
	DECLARE @ErrMsg nvarchar(4000);
	DECLARE @ErrSeverity int;
	DECLARE @deletedTransactions TABLE(ParentTransactionID numeric(18,0));

	EXEC sp_PurgeEFTTransactionsVersion

	-- Delete tblTransactions records and sub-tables
	SET NOCOUNT ON

	IF @startTime IS NULL BEGIN
		set @startTime = '19700101 00:00:00'
	END

	IF @stopTime IS NULL BEGIN
		SET @stopTime = DATEADD(DAY, -60, GETDATE())
	END

	IF @purgeSize IS NULL BEGIN
		set @purgeSize = 1000000
	END

	-- Temporarily remove the ParentTransactionID -> TransactionID constraint
	ALTER TABLE tbl_Transactions DROP CONSTRAINT FK_tbl_Transactions_ParentTransID;

		-- First, delete from tbl_Actions separately since potential circular cascade delete with tbl_EventRules
IF @debug=1 PRINT 'Deleting from tbl_Actions: ' + CONVERT(varchar(30),CURRENT_TIMESTAMP,109);
	BEGIN TRY		
		BEGIN TRANSACTION
		
		-- Clear the temp table
		DELETE @deletedTransactions		
			
		-- First, drop constraint
		ALTER TABLE tbl_Actions DROP CONSTRAINT FK_tbl_Actions_TransID;

		-- First delete the related transactions
		DELETE FROM tbl_Transactions 
		OUTPUT deleted.ParentTransactionID INTO @deletedTransactions
		WHERE transactionID IN 
			(SELECT transactionID FROM tbl_Actions WHERE Time_stamp BETWEEN @startTime AND @stopTime)
		-- Now delete the Actions
		DELETE FROM tbl_Actions WHERE Time_stamp BETWEEN @startTime AND @stopTime

		-- Make sure no orphans remaining
		DELETE FROM tbl_Actions WHERE transactionID NOT IN 
			(SELECT transactionID FROM tbl_Transactions);
		-- Now, add it back with cascade delete enabled
		ALTER TABLE tbl_Actions ADD CONSTRAINT FK_tbl_Actions_TransID
		FOREIGN KEY (TransactionID)
		REFERENCES tbl_Transactions (TransactionID)
		ON DELETE NO ACTION;

		-- Delete any parent transactions
		DELETE FROM tbl_Transactions WHERE transactionID IN (SELECT ParentTransactionID FROM @deletedTransactions WHERE ParentTransactionID IS NOT NULL)

		COMMIT TRANSACTION;

	END TRY

	BEGIN CATCH
		-- Whoops, there was an error
		IF @@TRANCOUNT > 0 ROLLBACK			
		-- Raise an error with the details of the exception
		SELECT	@ErrMsg = ERROR_MESSAGE(), @ErrSeverity = ERROR_SEVERITY()
		RAISERROR(@ErrMsg, @ErrSeverity, 1)
	END CATCH

	BEGIN TRY		
		

		SET @r = 1;
		WHILE @r > 0
		BEGIN       
			IF @debug=1 PRINT 'Deleting from tbl_Transactions: ' + CONVERT(varchar(30),CURRENT_TIMESTAMP,109);
			BEGIN TRANSACTION
		
			-- Clear the temp table
			DELETE @deletedTransactions

			-- Delete from tbl_Transactions and cascade delete of multiple tables,
			--  copy deleted transactions' ParentTransactionIDs so can delete any parents after
			DELETE TOP (@purgeSize) FROM tbl_Transactions 
			OUTPUT deleted.ParentTransactionID INTO @deletedTransactions
			WHERE 
	-- See code above to delete tbl_Actions separately
	--			TransactionID IN (SELECT transactionID FROM tbl_Actions WHERE Time_stamp BETWEEN @startTime AND @stopTime) OR
			TransactionID IN (SELECT transactionID FROM tbl_AdminActions WHERE Timestamp BETWEEN @startTime AND @stopTime) OR
			TransactionID IN (SELECT transactionID FROM tbl_Authentications WHERE Time_stamp BETWEEN @startTime AND @stopTime) OR
			TransactionID IN (SELECT transactionID FROM tbl_ClientOperations WHERE Time_stamp BETWEEN @startTime AND @stopTime) OR
			TransactionID IN (SELECT transactionID FROM tbl_CustomCommands WHERE Time_stamp BETWEEN @startTime AND @stopTime) OR
			TransactionID IN (SELECT transactionID FROM tbl_EventRules WHERE Time_stamp BETWEEN @startTime AND @stopTime) OR
-- EventRuleTransfers do not contain a time_stamp, but will cascade delete from Transactions
--			TransactionID IN (SELECT transactionID FROM tbl_EventRuleTransfers WHERE Time_stamp BETWEEN @startTime AND @stopTime) OR
			TransactionID IN (SELECT transactionID FROM tbl_ProtocolCommands WHERE Time_stamp BETWEEN @startTime AND @stopTime) OR
			TransactionID IN (SELECT transactionID FROM tbl_SocketConnections WHERE Time_stamp BETWEEN @startTime AND @stopTime) OR
			TransactionID IN (SELECT transactionID FROM tbl_WorkspaceActions WHERE Time_stamp BETWEEN @startTime AND @stopTime)

			SET @r = @@ROWCOUNT

			-- Now delete the parents
			DELETE FROM tbl_Transactions WHERE transactionID IN (SELECT ParentTransactionID FROM @deletedTransactions WHERE ParentTransactionID IS NOT NULL)

			COMMIT TRANSACTION;

			DBCC SHRINKFILE (2) WITH NO_INFOMSGS; -- Truncate the log after each iteration to its original creation size
		END

	END TRY

	BEGIN CATCH
		-- Whoops, there was an error
		IF @@TRANCOUNT > 0 ROLLBACK			
		-- Raise an error with the details of the exception
		SELECT	@ErrMsg = ERROR_MESSAGE(), @ErrSeverity = ERROR_SEVERITY()
		RAISERROR(@ErrMsg, @ErrSeverity, 1)
	END CATCH

	-- Delete SAT Transactions and sub-tables tbl_SAT_Files, tbl_SAT_Emails (Cascading Delete)
	IF @debug=1 PRINT 'Deleting from tbl_SAT_Transactions: ' + CONVERT(varchar(30),CURRENT_TIMESTAMP,109);
	BEGIN TRY		
		BEGIN TRANSACTION
			
		DELETE FROM tbl_SAT_Transactions
		WHERE time_stamp BETWEEN @startTime AND @stopTime

		COMMIT TRANSACTION;

	END TRY

	BEGIN CATCH
		-- Whoops, there was an error
		IF @@TRANCOUNT > 0 ROLLBACK			
		-- Raise an error with the details of the exception
		SELECT	@ErrMsg = ERROR_MESSAGE(), @ErrSeverity = ERROR_SEVERITY()
		RAISERROR(@ErrMsg, @ErrSeverity, 1)
	END CATCH

	-- Delete AS2 Transactions and sub-tables tbl_AS2Actions, tbl_AS2Files (non-Cascading Delete)
	IF @debug=1 PRINT 'Deleting from tbl_AS2Transactions: ' + CONVERT(varchar(30),CURRENT_TIMESTAMP,109);
	BEGIN TRY		
		BEGIN TRANSACTION
			
		-- First delete records in sub-tables
		-- tbl_AS2Actions
		DELETE FROM tbl_AS2Actions WHERE transactionID IN
			(SELECT transactionID FROM tbl_AS2Transactions
				WHERE CompleteTime BETWEEN @startTime AND @stopTime) OR
				FileID IN (SELECT FileID FROM tbl_AS2Files WHERE transactionID IN
			(SELECT transactionID FROM tbl_AS2Transactions
				WHERE CompleteTime BETWEEN @startTime AND @stopTime))						
		-- tbl_AS2Files
		DELETE FROM tbl_AS2Files WHERE transactionID IN
			(SELECT transactionID FROM tbl_AS2Transactions
				WHERE CompleteTime BETWEEN @startTime AND @stopTime)
		-- tbl_AS2Transactions 
		DELETE FROM tbl_AS2Transactions 
		WHERE CompleteTime BETWEEN @startTime AND @stopTime							

		COMMIT TRANSACTION;

	END TRY

	BEGIN CATCH
		-- Whoops, there was an error
		IF @@TRANCOUNT > 0 ROLLBACK			
		-- Raise an error with the details of the exception
		SELECT	@ErrMsg = ERROR_MESSAGE(), @ErrSeverity = ERROR_SEVERITY()
		RAISERROR(@ErrMsg, @ErrSeverity, 1)
	END CATCH

	-- Delete from remaining tables (stand-alone)
	/*
	IF @debug=1 PRINT 'Deleting from tbl_ScanDataActions, etc.: ' + CONVERT(varchar(30),CURRENT_TIMESTAMP,109);
	BEGIN TRY		
		BEGIN TRANSACTION
			DELETE FROM tbl_ScanDataActions WHERE Time_stamp BETWEEN @startTime AND @stopTime
			DELETE FROM tbl_PrivacyTermsEUStatus WHERE Setdate BETWEEN @startTime AND @stopTime
			DELETE FROM tbl_PersonalDataActions WHERE Setdate BETWEEN @startTime AND @stopTime
		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		-- Whoops, there was an error
		IF @@TRANCOUNT > 0 ROLLBACK			
		-- Raise an error with the details of the exception
		SELECT	@ErrMsg = ERROR_MESSAGE(), @ErrSeverity = ERROR_SEVERITY()
		RAISERROR(@ErrMsg, @ErrSeverity, 1)
	END CATCH
	*/

	-- Re-establish the ParentTransactionID -> TransactionID constraint
	-- Make sure no orphans remaining
	DELETE FROM tbl_Transactions WHERE ParentTransactionID IS NOT NULL AND ParentTransactionID NOT IN 
		(SELECT transactionID FROM tbl_Transactions);
	-- Now, add it back without cascade delete enabled
	ALTER TABLE tbl_Transactions ADD CONSTRAINT FK_tbl_Transactions_ParentTransID
	FOREIGN KEY (ParentTransactionID)
	REFERENCES tbl_Transactions (TransactionID)
	ON DELETE NO ACTION;

	DBCC SHRINKFILE (2) WITH NO_INFOMSGS; -- Truncate the log to its original creation size
END
GO

-- Using 1,000,000 batch for now.  Creates larger log, but moves quicker.
SET STATISTICS TIME OFF
EXEC sp_PurgeEFTTransactions NULL, NULL, 10000000, 1
SET STATISTICS TIME OFF


PRINT ''
-- PRINT 'Script completed at: ' + CAST(CURRENT_TIMESTAMP AS NVARCHAR)
PRINT 'Script completed at: ' + CONVERT(varchar(30),CURRENT_TIMESTAMP,109) 


GO
