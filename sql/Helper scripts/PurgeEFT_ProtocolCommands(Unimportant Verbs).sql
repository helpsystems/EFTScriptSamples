-- EFT Purging Script - tbl_ProtocolCommands
-- Goal:	Special script to purge data from tbl_ProtocolCommands with unimportant verbs

-- USAGE

-- 1. Run this script, then 
-- to purge all ProtocolCommands which are not relevant to main operations (upload, download, rename, delete, mkd)
-- EXEC sp_PurgeEFT_ProtocolCommands NULL, NULL 
-- to purge date range:
-- EXEC sp_PurgeEFT_ProtocolCommands '2019-01-01', '2019-05-18'
--
-- leaving begin date as NULL will default to earliest date
-- leaving end date as NULL will default to current date

-- Change Log:
--	0.1:	Original version
--	0.2: 	Changed to remove based on certain commands. the is internal flag wasn't a sufficient qualifier.

-- USE EFTDB

-- This procedure will print the version of this script
IF OBJECT_ID('dbo.sp_PurgeEFT_ProtocolCommands2Version') IS NOT NULL
	DROP PROC dbo.sp_PurgeEFT_ProtocolCommands2Version
GO

CREATE PROCEDURE sp_PurgeEFT_ProtocolCommands2Version
AS
	PRINT 'GlobalSCAPE, Inc. Purge Protocol Commands Script 2 Version 0.2'
GO

-- This procedure will delete EFT transactions from a all tables.
IF OBJECT_ID('dbo.sp_PurgeEFT_ProtocolCommands2') IS NOT NULL BEGIN
	DROP PROC dbo.sp_PurgeEFT_ProtocolCommands2
END
GO

-- By default, with no parameters, this procedure will purge all Protocol connections
CREATE PROCEDURE sp_PurgeEFT_ProtocolCommands2
@startTime	datetime = NULL, 
@stopTime	datetime = NULL,
@debug		bit = 0
AS
BEGIN
	DECLARE @ErrMsg nvarchar(4000);
	DECLARE @ErrSeverity int;

	EXEC dbo.sp_PurgeEFT_ProtocolCommands2Version

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
		DELETE FROM tbl_ProtocolCommands 
		WHERE Time_stamp >= @startTime AND Time_stamp < @stopTime AND
			Command NOT IN ('sent', 'created', 'mkd', 'rmd', 'dele', 'rnfr', 'rnto', 'DELETE', 'retr', 'POST', 'patch', 'copy')
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


SET STATISTICS TIME OFF
/* EXEC sp_PurgeEFT_ProtocolCommands2 NULL, NULL -- Default to purge entire table */
EXEC sp_PurgeEFT_ProtocolCommands2 '2018-01-01', '2018-12-31', 1




