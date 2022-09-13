-- EFT Purging Script - tbl_ProtocolCommands
-- Goal:	Special script to purge internal transaction data from tbl_ProtocolCommands

-- USAGE

-- 1. Configure (bottom of script) then run. 
-- to purge all ProtocolCommands with IsInternal = 1:
-- EXEC sp_PurgeEFT_ProtocolCommands NULL, NULL 
-- to purge date range ProtocolCommands with IsInternal = 1 - e.g.:
-- EXEC sp_PurgeEFT_ProtocolCommands '2019-01-01', '2019-05-18'
--
-- leaving begin date as NULL will default to earliest date
-- leaving end date as NULL will default to current date


-- Change Log:
--	0.1:	Original version

-- USE EFTDB

-- This procedure will print the version of this script
IF OBJECT_ID('dbo.sp_PurgeEFT_ProtocolCommandsVersion') IS NOT NULL
	DROP PROC dbo.sp_PurgeEFT_ProtocolCommandsVersion
GO

CREATE PROCEDURE sp_PurgeEFT_ProtocolCommandsVersion
AS
	PRINT 'GlobalSCAPE, Inc. Purge Protocol Commands Script Version 0.1'
GO

-- This procedure will delete EFT transactions from a all tables.
IF OBJECT_ID('dbo.sp_PurgeEFT_ProtocolCommands') IS NOT NULL BEGIN
	DROP PROC dbo.sp_PurgeEFT_ProtocolCommands
END
GO

-- By default, with no parameters, this procedure will purge all Protocol connections
CREATE PROCEDURE sp_PurgeEFT_ProtocolCommands
@startTime	datetime = NULL, 
@stopTime	datetime = NULL,
@debug		bit = 0
AS
BEGIN
	DECLARE @ErrMsg nvarchar(4000);
	DECLARE @ErrSeverity int;

	EXEC dbo.sp_PurgeEFT_ProtocolCommandsVersion

	SET NOCOUNT ON

	IF @startTime IS NULL
	BEGIN
		SET @startTime = '1970-01-01 00:00:00'
	END

	IF @stopTime IS NULL 
	BEGIN
		SET @stopTime = DATEADD(DAY, 1, GETDATE())
	END
	ELSE
	BEGIN
		SET @stopTime = DATEADD(DAY, 1, @stopTime) -- Add 1 to selected date to get all records before that
	END

	IF @debug=1 PRINT CONVERT(varchar(30), CURRENT_TIMESTAMP, 8) + ' Deleting from tbl_ProtocolCommands';

	BEGIN TRY
		DELETE FROM tbl_ProtocolCommands WHERE IsInternal=1 AND Time_stamp >= @startTime AND Time_stamp < @stopTime
	END TRY
	BEGIN CATCH
		-- There was an error
		IF @@TRANCOUNT > 0 ROLLBACK
		-- Raise an error with the details of the exception
		SELECT	@ErrMsg = ERROR_MESSAGE(), @ErrSeverity = ERROR_SEVERITY()
		RAISERROR(@ErrMsg, @ErrSeverity, 1)
	END CATCH

	DBCC SHRINKFILE (2) WITH NO_INFOMSGS; -- Truncate the log to its original creation size

	IF @debug=1 PRINT CONVERT(varchar(30),CURRENT_TIMESTAMP, 8) + ' Done deleting from tbl_ProtocolCommands';

	PRINT 'Procedure Complete'
END
GO

-- Default to purge entire table
-- SET STATISTICS TIME OFF
-- EXEC sp_PurgeEFT_ProtocolCommands NULL, NULL, 1
EXEC sp_PurgeEFT_ProtocolCommands '2018-01-01', '2018-12-31', 1
-- SET STATISTICS TIME OFF



