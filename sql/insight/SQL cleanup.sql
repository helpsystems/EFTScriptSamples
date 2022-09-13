-- ******************** WARNING ********************
-- EFT is about to upgrade your database! If necessary please check with your database administrator before proceeding.
--
-- This script will add 3 stored procedures, you will have to call the procedures manually
-- Samples of how to run the stored procedures is located at the end of this script

-- USE EFTInsight

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- sp_countEFTInsightRows
-- This stored procedure will count the number of rows.
-- 
-- Parameters
-- @DaystoKeep - default is 0, if set to a value greater than 0 the procedure will also show how many rows will be deleted
CREATE PROCEDURE sp_countEFTInsightRows		@DaystoKeep	int = 0
AS

DECLARE @DateToPurgeTo DATETIME
-- If @DaystoKeep = 0, then keep everything
IF @DaystoKeep = 0 OR @DaystoKeep IS NULL
BEGIN
	SELECT 'Action' as tableName, count(1) AS rows, MIN([timestamp]) as oldestRow FROM Action
	UNION ALL
	SELECT 'Authentication', count(1), MIN([timestamp]) FROM Authentication
	UNION ALL
	SELECT 'AweTask', count(1), MIN([started]) FROM AweTask
	UNION ALL
	SELECT 'EventRule', count(1), MIN([timestamp]) FROM EventRule
	UNION ALL
	SELECT 'Evaluation', count(1), MIN([EvaluateeStartDate]) FROM Evaluation
	UNION ALL
	SELECT 'LogEntry', count(1), MIN([entrytime]) FROM LogEntry
	UNION ALL
	SELECT 'Message', count(1), MIN([created]) FROM Message
	UNION ALL
	SELECT 'Transfer', count(1), MIN([timestamp]) FROM Transfer
	ORDER BY rows DESC
END
ELSE
BEGIN
	SET @DaystoKeep = @DaystoKeep * -1;  -- e.g. 60 becomes -60

	SET @DateToPurgeTo = DATEADD(day,@DaystoKeep,GetDate())

	SELECT 'Action' as tableName, count(1) AS rows, MIN([timestamp]) as oldestRow, sum(CASE WHEN [timestamp] < @DateToPurgeTo THEN 1 ELSE 0 END ) as rowsOlderThanCutOff FROM Action
	UNION ALL
	SELECT 'Authentication', count(1), MIN([timestamp]), sum(CASE WHEN [timestamp] < @DateToPurgeTo THEN 1 ELSE 0 END ) FROM Authentication
	UNION ALL
	SELECT 'AweTask', count(1), MIN([started]), sum(CASE WHEN [started] < @DateToPurgeTo THEN 1 ELSE 0 END ) FROM AweTask
	UNION ALL
	SELECT 'EventRule', count(1), MIN([timestamp]), sum(CASE WHEN [timestamp] < @DateToPurgeTo THEN 1 ELSE 0 END ) FROM EventRule
	UNION ALL
	SELECT 'Evaluation', count(1), MIN([EvaluateeStartDate]), sum(CASE WHEN [EvaluateeStartDate] < @DateToPurgeTo THEN 1 ELSE 0 END ) FROM Evaluation
	UNION ALL
	SELECT 'LogEntry', count(1), MIN([entrytime]), sum(CASE WHEN [entrytime] < @DateToPurgeTo THEN 1 ELSE 0 END ) FROM LogEntry
	UNION ALL
	SELECT 'Message', count(1), MIN([created]), sum(CASE WHEN [created] < @DateToPurgeTo THEN 1 ELSE 0 END ) FROM Message
	UNION ALL
	SELECT 'Transfer', count(1), MIN([timestamp]), sum(CASE WHEN [timestamp] < @DateToPurgeTo THEN 1 ELSE 0 END ) FROM Transfer
	ORDER BY rows DESC
END

GO

-- sp_purgeMarkedForDeletion
-- This stored procedure will purge all rows that have the column MarkedForDeletion set to 1
create Procedure [dbo].[sp_purgeMarkedForDeletion]
AS
BEGIN

	DELETE FROM [dbo].[Action] WHERE [MarkedForDeletion] = 1
	DELETE FROM [dbo].[Authentication] WHERE [MarkedForDeletion] = 1
	DELETE FROM [dbo].[AweTask] WHERE [MarkedForDeletion] = 1
	DELETE FROM [dbo].[Configuration] WHERE [MarkedForDeletion] = 1
	DELETE FROM [dbo].[Evaluation] WHERE [MarkedForDeletion] = 1
	DELETE FROM [dbo].[Expectation] WHERE [MarkedForDeletion] = 1
	DELETE FROM [dbo].[ExpectationDashboard] WHERE [MarkedForDeletion] = 1
	DELETE FROM [dbo].[License] WHERE [MarkedForDeletion] = 1
	DELETE FROM [dbo].[LogEntry] WHERE [MarkedForDeletion] = 1
	DELETE FROM [dbo].[Message] WHERE [MarkedForDeletion] = 1
	DELETE FROM [dbo].[Queue] WHERE [MarkedForDeletion] = 1
	DELETE FROM [dbo].[SecurityPrincipal] WHERE [MarkedForDeletion] = 1
	DELETE FROM [dbo].[Server] WHERE [MarkedForDeletion] = 1
	DELETE FROM [dbo].[Session] WHERE [MarkedForDeletion] = 1
	DELETE FROM [dbo].[Site] WHERE [MarkedForDeletion] = 1
	DELETE FROM [dbo].[TableSyncStatus] WHERE [MarkedForDeletion] = 1
	DELETE FROM [dbo].[Transfer] WHERE [MarkedForDeletion] = 1

END;
GO

-- sp_purgeEFTInsight
-- This stored procedure will delete rows older than number of days specified by @DaystoKeep
-- 
-- Parameters
-- @DaystoKeep - default is 180, the procedure will purge all rows older than @DaystoKeep old
-- @debug - default is 0, if set to 1 the procedure will show some debug functions while running
CREATE PROCEDURE sp_purgeEFTInsight		@DaystoKeep	int = 180,
										@debug			bit = 0
AS

	DECLARE @DateToPurgeTo DATETIME

	IF @debug = 1 PRINT CONVERT(varchar(30),CURRENT_TIMESTAMP,8) + ' sp_PurgeEFTInsight started';

	-- If @DaystoKeep = 0, then purge only older than 40 years
	IF @DaystoKeep = 0 OR @DaystoKeep IS NULL
		SET @DaystoKeep = -15000;  -- Go back 40 years
	ELSE
		SET @DaystoKeep = @DaystoKeep * -1;  -- e.g. 60 becomes -60

	SET @DateToPurgeTo = DATEADD(day,@DaystoKeep,GetDate())

	BEGIN TRY

		BEGIN TRANSACTION
			IF @debug = 1 PRINT CONVERT(varchar(30),CURRENT_TIMESTAMP,8) + ' transactions for Action about to be purged';
			DELETE FROM [Action] WHERE [Timestamp] <= @DateToPurgeTo
		COMMIT TRANSACTION

		BEGIN TRANSACTION
			IF @debug = 1 PRINT CONVERT(varchar(30),CURRENT_TIMESTAMP,8) + ' transactions for Authentication about to be purged';
			DELETE FROM [Authentication] WHERE [Timestamp] <= @DateToPurgeTo
		COMMIT TRANSACTION

		BEGIN TRANSACTION
			IF @debug = 1 PRINT CONVERT(varchar(30),CURRENT_TIMESTAMP,8) + ' transactions for AweTask about to be purged';
			DELETE FROM [AweTask] WHERE [started] <= @DateToPurgeTo
		COMMIT TRANSACTION

		BEGIN TRANSACTION
			IF @debug = 1 PRINT CONVERT(varchar(30),CURRENT_TIMESTAMP,8) + ' transactions for EventRule about to be purged';
			DELETE FROM [EventRule] WHERE [Timestamp] <= @DateToPurgeTo
		COMMIT TRANSACTION

		BEGIN TRANSACTION
			IF @debug = 1 PRINT CONVERT(varchar(30),CURRENT_TIMESTAMP,8) + ' transactions for Evaluation about to be purged';
			DELETE FROM [Evaluation] WHERE [EvaluateeStartDate] <= @DateToPurgeTo
		COMMIT TRANSACTION

		BEGIN TRANSACTION
			IF @debug = 1 PRINT CONVERT(varchar(30),CURRENT_TIMESTAMP,8) + ' transactions for LogEntry about to be purged';
			DELETE FROM [LogEntry] WHERE [entrytime] <= @DateToPurgeTo
		COMMIT TRANSACTION

		BEGIN TRANSACTION
			IF @debug = 1 PRINT CONVERT(varchar(30),CURRENT_TIMESTAMP,8) + ' transactions for Message about to be purged';
			DELETE FROM [Message] WHERE [created] <= @DateToPurgeTo
		COMMIT TRANSACTION

		BEGIN TRANSACTION
			IF @debug = 1 PRINT CONVERT(varchar(30),CURRENT_TIMESTAMP,8) + ' transactions for Transfer about to be purged';
			DELETE FROM [Transfer] WHERE [timestamp] <= @DateToPurgeTo
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
	IF @debug = 1 PRINT CONVERT(varchar(30),CURRENT_TIMESTAMP,8) + ' sp_PurgeEFTInsight ended';
GO

--EXEC sp_countEFTInsightRows NULL
--GO
--EXEC sp_purgeMarkedForDeletion
--GO
--EXEC sp_countEFTInsightRows 180
--GO
--EXEC sp_purgeEFTInsight 180, 1
--GO
--EXEC sp_countEFTInsightRows
--GO