-- EFT Purging script: tbl_Authentications
-- Goal: Purge tbl_Authentications table of garbage logon attempts using non-existing usernames.

-- USAGE
-- Config: By default, the script will search for user account authentications attempts using 'root' or 'administrator' 
-- You can edit those terms or add your own by modifying the appropriate areas of this script (search for root or administrator)
-- You can also specify a start and end range or use NULL, NULL which will dafault to deleting records back 60 days

-- Change Log:
--	0.1:	Initial version

-- [NOTE: Added to upgrade_17.0.0.0-18.0.0.0 script to modify tbl_Authentications index IX_tbl_Authentications_User_Name to include Time_stamp]

PRINT CONVERT(varchar(30), CURRENT_TIMESTAMP, 8) + ' Script started'
-- USE EFTDB

-- This procedure will print the version of this script
IF OBJECT_ID('dbo.sp_PurgeEFT_AuthenticationsVersion') IS NOT NULL
	DROP PROC dbo.sp_PurgeEFT_AuthenticationsVersion
GO

CREATE PROCEDURE sp_PurgeEFT_AuthenticationsVersion
AS
	PRINT 'GlobalSCAPE, Inc. Purge Authentication Script Version 0.1'
GO

-- This procedure deletes Authentications based on username and date range
IF OBJECT_ID('dbo.sp_PurgeEFT_Authentications') IS NOT NULL
	DROP PROC dbo.sp_PurgeEFT_Authentications
GO

CREATE PROCEDURE sp_PurgeEFT_Authentications
											@startTime	datetime = NULL,
											@stopTime	datetime = NULL,
											@UserName	nvarchar(50) = NULL,
											@debug		bit = 0
AS

	EXEC dbo.sp_PurgeEFT_AuthenticationsVersion

	SET NOCOUNT ON

	IF @startTime IS NULL BEGIN
		set @startTime = '19700101 00:00:00'
	END

	IF @stopTime IS NULL BEGIN
		SET @stopTime = DATEADD(DAY, -60, GETDATE())
	END

	-- Temporarily remove the ParentTransactionID -> TransactionID constraint
	ALTER TABLE tbl_Transactions DROP CONSTRAINT FK_tbl_Transactions_ParentTransID;

	BEGIN TRY
		BEGIN TRANSACTION

			IF @debug = 1 PRINT CONVERT(varchar(30), CURRENT_TIMESTAMP, 8) + ' Deleting transactions for authentications';
			-- Deleting the transactions should cascade delete to other tables if any associated transactions exist
			IF @UserName IS NULL  -- Use default usernames
				DELETE FROM tbl_Transactions WHERE TransactionID IN 
					(SELECT transactionID FROM tbl_Authentications WHERE (UserName = 'Administrator' OR UserName = 'root') AND Time_stamp BETWEEN @startTime AND @stopTime)
			ELSE
				DELETE FROM tbl_Transactions WHERE TransactionID IN 
					(SELECT transactionID FROM tbl_Authentications WHERE UserName = @UserName AND Time_stamp BETWEEN @startTime AND @stopTime)

			-- Should be zero transactions to purge here, since cascade delete above should have handled them
			IF @debug = 1 PRINT CONVERT(varchar(30), CURRENT_TIMESTAMP, 8) + ' Deleting rows from tbl_Authentications with UserNames: ' + ISNULL(@UserName, 'Adminitrator, root');
			IF @UserName IS NULL  -- Use default usernames
				DELETE FROM tbl_Authentications WHERE (UserName = 'Administrator' OR UserName = 'root') AND Time_stamp BETWEEN @startTime AND @stopTime
			ELSE
				DELETE FROM tbl_Authentications WHERE UserName = @UserName AND Time_stamp BETWEEN @startTime AND @stopTime

		COMMIT TRANSACTION
	END TRY

	BEGIN CATCH
		-- If error, roll back
		IF @@TRANCOUNT > 0
			ROLLBACK

		-- Raise an error with the details of the exception
		DECLARE @ErrMsg nvarchar(4000),
				@ErrSeverity int
		SELECT	@ErrMsg = ERROR_MESSAGE(),
				@ErrSeverity = ERROR_SEVERITY()

		RAISERROR(@ErrMsg, @ErrSeverity, 1)
	END CATCH

	-- Re-establish the ParentTransactionID -> TransactionID constraint
	-- Make sure no orphans remaining
	DELETE FROM tbl_Transactions WHERE ParentTransactionID IS NOT NULL AND ParentTransactionID NOT IN
		(SELECT transactionID FROM tbl_Transactions);
	-- Now, add it back without cascade delete enabled
	ALTER TABLE tbl_Transactions ADD CONSTRAINT FK_tbl_Transactions_ParentTransID
	FOREIGN KEY (ParentTransactionID)
	REFERENCES tbl_Transactions (TransactionID)
	ON DELETE NO ACTION;
GO


EXEC sp_PurgeEFT_Authentications NULL, NULL, NULL, 1
-- EXEC sp_PurgeEFT_Authentications '2018-01-01', '2018-12-31', NULL, 1


PRINT ''
PRINT CONVERT(varchar(30), CURRENT_TIMESTAMP, 8) + ' Script completed'