-- EFT Purging Script - tbl_SocketConnections
-- Goal:	Special script to purge data from tbl_SocketConnections by date

-- USAGE

-- 1. Configure the purge (bottom of script)
-- To perform a complete purge, just run the command at the bottom of the script: EXEC sp_PurgeEFT_SocketConnections NULL, NULL, NULL
-- If you want to purge a specific date range, then specify a start and end date: EXEC sp_PurgeEFT_SocketConnections '2019-01-01', '2019-05-18', NULL
-- If you want to purge a specific error code, for example error code 0: EXEC sp_PurgeEFT_SocketConnections '2019-01-01', '2019-05-18', 0
-- Note: Leaving begin date as NULL will default to earliest date.
--       Leaving end date as NULL will default to current date.
--       Leaving errorCode as NULL will purge all error codes.

-- Change Log:
--  0.1:	Original version
--  0.2:	Updated comments

-- USE EFTDB

-- This procedure will print the version of this script
IF OBJECT_ID('dbo.sp_PurgeEFT_SocketConnectionsVersion') IS NOT NULL
	DROP PROC dbo.sp_PurgeEFT_SocketConnectionsVersion
GO

CREATE PROCEDURE sp_PurgeEFT_SocketConnectionsVersion
AS
	PRINT 'GlobalSCAPE, Inc. Purge Script Version 0.2'
GO

-- This procedure will delete EFT transactions from a all tables.
IF OBJECT_ID('dbo.sp_PurgeEFT_SocketConnections') IS NOT NULL BEGIN
	DROP PROC dbo.sp_PurgeEFT_SocketConnections
END
GO

-- By default, with no parameters, this procedure will purge all socket connections
CREATE PROCEDURE sp_PurgeEFT_SocketConnections
@startTime	datetime = NULL, 
@stopTime	datetime = NULL,
@errorCode	int = NULL,
@debug		bit = 0
AS
BEGIN
	DECLARE @ErrMsg nvarchar(4000);
	DECLARE @ErrSeverity int;

	EXEC dbo.sp_PurgeEFT_SocketConnectionsVersion

	SET NOCOUNT ON

	IF @startTime IS NULL AND @stopTime IS NULL AND @errorCode IS NULL
	BEGIN
		--This will remove everything, regardless of ResultID code
		TRUNCATE TABLE tbl_SocketConnections
	END
	ELSE
	BEGIN
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
			SET @stopTime = DATEADD(DAY, 1, @stopTime)
		END

		IF @debug=1 PRINT CONVERT(varchar(30),CURRENT_TIMESTAMP, 8) + ' Deleting from tbl_SocketConnections';

		BEGIN TRY
			IF @errorCode IS NULL
			BEGIN
				DELETE FROM tbl_SocketConnections WHERE Time_stamp >= @startTime AND Time_stamp < @stopTime
			END
			ELSE
			BEGIN
				DELETE FROM tbl_SocketConnections WHERE Time_stamp >= @startTime AND Time_stamp < @stopTime AND ResultID = @errorCode
			END
		END TRY
		BEGIN CATCH
			-- There was an error
			IF @@TRANCOUNT > 0 ROLLBACK
			-- Raise an error with the details of the exception
			SELECT	@ErrMsg = ERROR_MESSAGE(), @ErrSeverity = ERROR_SEVERITY()
			RAISERROR(@ErrMsg, @ErrSeverity, 1)
		END CATCH

		DBCC SHRINKFILE (2) WITH NO_INFOMSGS; -- Truncate the log to its original creation size

		IF @debug=1 PRINT CONVERT(varchar(30),CURRENT_TIMESTAMP, 8) + ' Done deleting from tbl_SocketConnections';
	END
	PRINT 'Procedure Complete'
END
GO

-- sp_PurgeEFT_SocketConnections parameters
--
-- startTime: set the time to purge from. If set to NULL it will default to January 1970.
-- stopTime : set the time to purge to. If set to NULL it will default to todays date.
-- errorCode: set the resultID to purge. If set to NULL it will purge all resultIDs.
--            The errorCodes are as follows:
--             - TOO_MANY_CONNECTIONS_PER_SITE = 8
--             - TOO_MANY_CONNECTIONS_PER_IP = 9
--             - RESTRICTED_IP = 10
--             - BANNED_IP = 11
--             - EFT_IN_DEV_MODE = 12
--             - INTERNAL_SERVER_ERROR = 13
--             - OK = 0

-- Default to purge entire table

-- SET STATISTICS TIME OFF
	EXEC sp_PurgeEFT_SocketConnections NULL, NULL, NULL, 1
--	EXEC sp_PurgeEFT_SocketConnections '2018-01-01', '2018-12-31', NULL, 1
-- SET STATISTICS TIME OFF
