-- EFT Purging Script
-- Goal:	Allow customers to purge data from EFT
-- Change Log:
--	0.1:	Set batch size at 100,000
--			Removed SELECT and extra PRINTT statements.
--	0.2:	Changed to purge up to 60 days per customer request
--	0.3:	Modified script to not assume cascading deletes and to
--			explicitly delete from all tables
--			Modified script to default 'purgesize' to 10,000
--			instead of 1,000
--	0.4		Added AS2 and SAT purging
--  0.5     Subset table wasn't being dropped.
PRINT 'Script started at: ' + CAST(CURRENT_TIMESTAMP AS NVARCHAR)
USE EFTDB

-- This procedure will print the version of this script
IF OBJECT_ID('dbo.sp_PurgeEFTTransactionsVersion') IS NOT NULL
	DROP PROC dbo.sp_PurgeEFTTransactionsVersion
GO

CREATE PROCEDURE sp_PurgeEFTTransactionsVersion
AS
	PRINT 'GlobalSCAPE, Inc. Purge Script Version 0.5'
GO

-- This procedure delete EFT transactions from a given table.
IF OBJECT_ID('dbo.sp_RemoveTxnsFromTable') IS NOT NULL
	DROP PROC dbo.sp_RemoveTxnsFromTable
GO

CREATE PROCEDURE sp_RemoveTxnsFromTable	@txns_id_table_name	nvarchar(200),
										@tblname			nvarchar(200),
										@debug				bit = 0
AS
	DECLARE	@sql				nvarchar(4000),
			@activeTableName	nvarchar(220)

	BEGIN TRY
		BEGIN TRANSACTION
			SET @activeTableName  = quotename(N'tbl_' + @tblname)

			IF @debug = 1 BEGIN
				PRINT 'Deleting Transactions from Table: ' + @activeTableName
			END

			-- Delete the data from the active table
			SET @sql =
			'DELETE FROM ' + @activeTableName + ' ' +
			'WHERE TransactionID IN ' +
			'(' +
				'SELECT TransactionID ' +
				'FROM ' + @txns_id_table_name +
			')'

			IF @debug = 1 PRINT @sql
			EXEC sp_executesql @sql

		COMMIT TRANSACTION
	END TRY

	BEGIN CATCH
		-- Whoops, there was an error
		IF @@TRANCOUNT > 0
			ROLLBACK

		-- Raise an error with the details of the exception
		DECLARE @ErrMsg nvarchar(4000),
				@ErrSeverity int
		SELECT	@ErrMsg = ERROR_MESSAGE(),
				@ErrSeverity = ERROR_SEVERITY()

		RAISERROR(@ErrMsg, @ErrSeverity, 1)
	END CATCH
GO

-- This procedure delete EFT transactions from a all tables.
IF OBJECT_ID('dbo.sp_RemoveTxns') IS NOT NULL
	DROP PROC dbo.sp_RemoveTxns
GO

CREATE PROCEDURE sp_RemoveTxns	@txns_id_table_name	nvarchar(200),
								@debug				bit = 0
AS

	-- We want to wrap these deletes in a transactions so that we don't end
	-- up with orphaned rows.
	BEGIN TRY
		BEGIN TRANSACTION

			-- To verify that all children were truly deleted, also explicitly
			-- delete from their tables.
			EXEC sp_RemoveTxnsFromTable @txns_id_table_name, N'AdminActions', @debug
			EXEC sp_RemoveTxnsFromTable @txns_id_table_name, N'ProtocolCommands', @debug
			EXEC sp_RemoveTxnsFromTable @txns_id_table_name, N'Actions', @debug
			EXEC sp_RemoveTxnsFromTable @txns_id_table_name, N'EventRules', @debug
			EXEC sp_RemoveTxnsFromTable @txns_id_table_name, N'ClientOperations', @debug
			EXEC sp_RemoveTxnsFromTable @txns_id_table_name, N'SocketConnections', @debug
			EXEC sp_RemoveTxnsFromTable @txns_id_table_name, N'Authentications', @debug
			EXEC sp_RemoveTxnsFromTable @txns_id_table_name, N'CustomCommands', @debug
			EXEC sp_RemoveTxnsFromTable @txns_id_table_name, N'OutlookReport', @debug

			-- Remove from the transactions table
			EXEC sp_RemoveTxnsFromTable @txns_id_table_name, N'Transactions', @debug

		COMMIT TRANSACTION
	END TRY

	BEGIN CATCH
		-- Whoops, there was an error
		IF @@TRANCOUNT > 0
			ROLLBACK

		-- Raise an error with the details of the exception
		DECLARE @ErrMsg nvarchar(4000),
				@ErrSeverity int
		SELECT	@ErrMsg = ERROR_MESSAGE(),
				@ErrSeverity = ERROR_SEVERITY()

		RAISERROR(@ErrMsg, @ErrSeverity, 1)
	END CATCH
GO


-- This procedure will delete AS2 transactions.
IF OBJECT_ID('dbo.sp_RemoveAS2Txns') IS NOT NULL
	DROP PROC dbo.sp_RemoveAS2Txns
GO

CREATE PROCEDURE sp_RemoveAS2Txns	@txns_id_table_name	nvarchar(200),
									@debug				bit = 0
AS

	-- We want to wrap these deletes in a transactions so that we don't end
	-- up with orphaned rows.
	BEGIN TRY
		BEGIN TRANSACTION

			-- To verify that all children were truly deleted, also explicitly
			-- delete from their tables.
			EXEC sp_RemoveTxnsFromTable @txns_id_table_name, N'AS2Actions', @debug
			EXEC sp_RemoveTxnsFromTable @txns_id_table_name, N'AS2Files', @debug
			EXEC sp_RemoveTxnsFromTable @txns_id_table_name, N'AS2Transactions', @debug

		COMMIT TRANSACTION
	END TRY

	BEGIN CATCH
		-- Whoops, there was an error
		IF @@TRANCOUNT > 0
			ROLLBACK

		-- Raise an error with the details of the exception
		DECLARE @ErrMsg nvarchar(4000),
				@ErrSeverity int
		SELECT	@ErrMsg = ERROR_MESSAGE(),
				@ErrSeverity = ERROR_SEVERITY()

		RAISERROR(@ErrMsg, @ErrSeverity, 1)
	END CATCH
GO

-- This procedure will delete EFT transactions from a all tables.
IF OBJECT_ID('dbo.sp_PurgeEFTTransactions') IS NOT NULL BEGIN
	DROP PROC dbo.sp_PurgeEFTTransactions
END
GO

-- By default, this procedure will purge data from 1990 to 60 days ago.
CREATE PROCEDURE sp_PurgeEFTTransactions	@startTime	datetime = NULL,
											@stopTime	datetime = NULL,
											@purgeSize	numeric = NULL,
											@debug		bit = 0
AS

	EXEC sp_PurgeEFTTransactionsVersion

	DECLARE @iteration numeric
	SET @iteration = 0

	DECLARE @deleteHappened numeric
	SET @deleteHappened = 1
	
	WHILE @deleteHappened = 1
	BEGIN
		SET @deleteHappened = 0
		SET @iteration = @iteration + 1

		PRINT ''
		PRINT 'Script iteration: ' + CAST(@iteration as NVARCHAR)
		
		BEGIN TRY
			SET NOCOUNT ON

			IF @startTime IS NULL BEGIN
				set @startTime = '19700101 00:00:00'
			END

			IF @stopTime IS NULL BEGIN
				SET @stopTime = DATEADD(DAY, -60, GETDATE())
			END

			IF @purgeSize IS NULL BEGIN
				set @purgeSize = 10000
			END

			PRINT 'Purging Transactions from ' + CAST(@startTime as NVARCHAR) + ' to ' +
					CAST(@stopTime AS NVARCHAR) + ' in batches of ' + CAST(@purgeSize AS NVARCHAR)

			DECLARE @tbl_TablesToPurge TABLE
			(
				[TableName] NVARCHAR(400) NOT NULL
			)

			INSERT @tbl_TablesToPurge ([TableName]) VALUES (N'tbl_AdminActions')
			INSERT @tbl_TablesToPurge ([TableName]) VALUES (N'tbl_ProtocolCommands')
			INSERT @tbl_TablesToPurge ([TableName]) VALUES (N'tbl_Actions')
			INSERT @tbl_TablesToPurge ([TableName]) VALUES (N'tbl_EventRules')
			INSERT @tbl_TablesToPurge ([TableName]) VALUES (N'tbl_ClientOperations')
			INSERT @tbl_TablesToPurge ([TableName]) VALUES (N'tbl_SocketConnections')
			INSERT @tbl_TablesToPurge ([TableName]) VALUES (N'tbl_Authentications')
			INSERT @tbl_TablesToPurge ([TableName]) VALUES (N'tbl_CustomCommands')

			-- Create a cursor to walk through each table name
			DECLARE @tableName NVARCHAR(400)

			DECLARE tablename_cursor CURSOR FOR
				SELECT [TableName]
				FROM @tbl_TablesToPurge

			OPEN tablename_cursor;

			-- Perform the first fetch and store the values in variables.
			-- Note: The variables are in the same order as the columns
			-- in the SELECT statement.
			FETCH NEXT FROM tablename_cursor INTO @tableName

			CREATE TABLE #tbl_TxnsToBePurged
			(
				TransactionID numeric,
				CONSTRAINT [PK_tbl_TxnsToBePurged] PRIMARY KEY CLUSTERED
				(
					TransactionID ASC
				)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
			) ON [PRIMARY]

			CREATE TABLE #tbl_SubsetTxnsToBePurged
			(
				TransactionID numeric,
				CONSTRAINT [PK_tbl_SubsetTxnsToBePurged] PRIMARY KEY CLUSTERED
				(
					TransactionID ASC
				)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
			) ON [PRIMARY]

			-- Check @@FETCH_STATUS to see if there are any more rows to fetch.
			WHILE @@FETCH_STATUS = 0
			BEGIN
				-- Now we'll remove the rows from the active tables.
				IF @debug = 1 BEGIN
					PRINT 'Now purging transactions from table ' + @tableName
				END

				-- Unfortunately, the name of the TimeStamp column is not the same
				-- for every table.  So, I've built this logic to generate the correct
				-- name for the corresponding table
				DECLARE @tsColumnName NVARCHAR(400)
				SET @tsColumnName = 'Time_stamp'

				IF @tableName = 'tbl_AdminActions' BEGIN
					SET @tsColumnName = 'Timestamp'
				END

				DECLARE	@sql nvarchar(4000)

				SET @sql =
					'INSERT INTO #tbl_TxnsToBePurged ' +
						'SELECT DISTINCT(TransactionID) TransactionID ' +
						'FROM ' + @tableName  + ' ' +
						'WHERE ' + @tsColumnName + ' BETWEEN @lstartTime AND @lstopTime  ' +
						'GROUP BY TransactionID'

				EXEC sp_executesql @sql, N'@lstartTime datetime, @lstopTime datetime', @startTime, @stopTime

				DECLARE @resultCount numeric
				DECLARE @lastResultCount numeric
				SET @lastResultCount = -1

				SELECT @resultCount = count(*) FROM #tbl_TxnsToBePurged

				IF @debug = 1 BEGIN
					PRINT 'Total Number Txns To Be Purged: ' + CAST(@resultCount AS NVARCHAR)
				END

				WHILE ((@resultCount > 0) AND (@resultCount != @lastResultCount)) BEGIN

					SET @lastResultCount = @resultCount
					SET @sql =
						'INSERT INTO #tbl_SubsetTxnsToBePurged ' +
							'SELECT a.TransactionID TransactionID ' +
							'FROM (SELECT TOP ' + CAST(@purgeSize AS NVARCHAR) + ' #tbl_TxnsToBePurged.TransactionID FROM #tbl_TxnsToBePurged) a ' +
							'LEFT JOIN tbl_Transactions tempTable ON a.TransactionID = tempTable.ParentTransactionID ' +
							'WHERE tempTable.ParentTransactionID IS NULL ' +
							'ORDER BY a.TransactionID'

					IF @debug = 1 BEGIN
						PRINT 'SQL to determine PurgeSet: ' + @sql
					END

					EXEC sp_executesql @sql

					SELECT @resultCount = count(*) FROM #tbl_SubsetTxnsToBePurged

					IF @debug = 1 BEGIN
						PRINT 'Total Number Txns To Be Purged This Round: ' + CAST(@resultCount AS NVARCHAR)
					END

					EXEC sp_RemoveTxns N'#tbl_SubsetTxnsToBePurged', @debug

					IF @debug = 1 BEGIN
						PRINT 'Successfully deleted transactions from tbl_Transactions and associated tables'
					END

					DELETE FROM #tbl_TxnsToBePurged
					WHERE TransactionID IN
						(
							SELECT #tbl_SubsetTxnsToBePurged.TransactionID TransactionID
							FROM #tbl_SubsetTxnsToBePurged
						)

					IF @debug = 1 BEGIN
						PRINT 'Successfully deleted transactions from #tbl_TxnsToBePurged'
					END

					DELETE FROM #tbl_SubsetTxnsToBePurged

					IF @debug = 1 BEGIN
						PRINT 'Determing number of rows remaining to be Purged.'
					END

					IF (@resultCount > 0) BEGIN
						SET @deleteHappened = 1
					END	

					SELECT @resultCount = count(*) FROM #tbl_TxnsToBePurged

					IF @debug = 1 BEGIN
						PRINT 'BOT of Loop: Total Number Txns To Be Purged: ' + CAST(@resultCount AS NVARCHAR)
					END
				END

				-- We want to delete all transactions from the temporary table
				DELETE FROM #tbl_TxnsToBePurged

				-- This is executed as long as the previous fetch succeeds.
				FETCH NEXT FROM tablename_cursor INTO @tableName
			END

			CLOSE tablename_cursor;

			--
			-- Purge AS2 transactions
			--

			SET @sql =
				'INSERT INTO #tbl_TxnsToBePurged ' +
					'SELECT DISTINCT(TransactionID) TransactionID ' +
					'FROM tbl_AS2Transactions ' +
					'WHERE CompleteTime BETWEEN @lstartTime AND @lstopTime  ' +
					'GROUP BY TransactionID'

			EXEC sp_executesql @sql, N'@lstartTime datetime, @lstopTime datetime', @startTime, @stopTime

			SET @lastResultCount = -1
			SELECT @resultCount = count(*) FROM #tbl_TxnsToBePurged

			IF @debug = 1 BEGIN
				PRINT 'Total Number AS2 Txns To Be Purged: ' + CAST(@resultCount AS NVARCHAR)
			END

			WHILE ((@resultCount > 0) AND (@resultCount != @lastResultCount)) BEGIN

				SET @lastResultCount = @resultCount

				SET @sql =
					'INSERT INTO #tbl_SubsetTxnsToBePurged ' +
						'SELECT TOP ' + CAST(@purgeSize AS NVARCHAR) + ' #tbl_TxnsToBePurged.TransactionID ' +
						'FROM #tbl_TxnsToBePurged ' +
						'ORDER BY TransactionID'

				IF @debug = 1 BEGIN
					PRINT 'SQL to determine AS2 PurgeSet: ' + @sql
				END

				EXEC sp_executesql @sql

				SELECT @resultCount = count(*) FROM #tbl_SubsetTxnsToBePurged

				IF @debug = 1 BEGIN
					PRINT 'Total Number AS2 Txns To Be Purged This Round: ' + CAST(@resultCount AS NVARCHAR)
				END

				EXEC sp_RemoveAS2Txns N'#tbl_SubsetTxnsToBePurged', @debug

				IF @debug = 1 BEGIN
					PRINT 'Successfully deleted AS2 transactions'
				END

				DELETE FROM #tbl_TxnsToBePurged
				WHERE TransactionID IN
					(
						SELECT #tbl_SubsetTxnsToBePurged.TransactionID TransactionID
						FROM #tbl_SubsetTxnsToBePurged
					)

				IF @debug = 1 BEGIN
					PRINT 'Successfully deleted transactions from #tbl_TxnsToBePurged'
				END

				DELETE FROM #tbl_SubsetTxnsToBePurged

				IF @debug = 1 BEGIN
					PRINT 'Determing number of rows remaining to be Purged.'
				END

				IF (@resultCount > 0) BEGIN
					SET @deleteHappened = 1
				END	

				SELECT @resultCount = count(*) FROM #tbl_TxnsToBePurged

				IF @debug = 1 BEGIN
					PRINT 'BOT of AS2 Loop: Total Number Txns To Be Purged: ' + CAST(@resultCount AS NVARCHAR)
				END
			END

			DELETE FROM #tbl_TxnsToBePurged


			--
			-- Purge SAT transactions
			--

			CREATE TABLE #tbl_SATTxnsToBePurged
			(
				ID numeric,
				CONSTRAINT [PK_tbl_SATTxnsToBePurged] PRIMARY KEY CLUSTERED
				(
					ID ASC
				)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
			) ON [PRIMARY]

			CREATE TABLE #tbl_SubsetSATTxnsToBePurged
			(
				ID numeric,
				CONSTRAINT [PK_tbl_SubsetSATTxnsToBePurged] PRIMARY KEY CLUSTERED
				(
					ID ASC
				)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
			) ON [PRIMARY]

			SET @sql =
				'INSERT INTO #tbl_SATTxnsToBePurged ' +
					'SELECT DISTINCT(ID) ID ' +
					'FROM tbl_SAT_Transactions ' +
					'WHERE time_stamp BETWEEN @lstartTime AND @lstopTime  ' +
					'GROUP BY ID'

			EXEC sp_executesql @sql, N'@lstartTime datetime, @lstopTime datetime', @startTime, @stopTime

			SET @lastResultCount = -1
			SELECT @resultCount = count(*) FROM #tbl_SATTxnsToBePurged

			IF @debug = 1 BEGIN
				PRINT 'Total Number SAT Txns To Be Purged: ' + CAST(@resultCount AS NVARCHAR)
			END

			WHILE ((@resultCount > 0) AND (@resultCount != @lastResultCount)) BEGIN

				SET @lastResultCount = @resultCount

				SET @sql =
					'INSERT INTO #tbl_SubsetSATTxnsToBePurged ' +
						'SELECT TOP ' + CAST(@purgeSize AS NVARCHAR) + ' #tbl_SATTxnsToBePurged.ID ' +
						'FROM #tbl_SATTxnsToBePurged ' +
						'ORDER BY ID'

				IF @debug = 1 BEGIN
					PRINT 'SQL to determine SAT PurgeSet: ' + @sql
				END

				EXEC sp_executesql @sql

				SELECT @resultCount = count(*) FROM #tbl_SubsetSATTxnsToBePurged

				IF @debug = 1 BEGIN
					PRINT 'Total Number SAT Txns To Be Purged This Round: ' + CAST(@resultCount AS NVARCHAR)
				END

				BEGIN TRANSACTION
				
				DELETE FROM tbl_SAT_Emails
				WHERE ID IN
					(
						SELECT ID
						FROM #tbl_SubsetSATTxnsToBePurged
					)

				DELETE FROM tbl_SAT_Files
				WHERE ID IN
					(
						SELECT ID
						FROM #tbl_SubsetSATTxnsToBePurged
					)

				DELETE FROM tbl_SAT_Transactions
				WHERE ID IN
					(
						SELECT ID
						FROM #tbl_SubsetSATTxnsToBePurged
					)

				COMMIT TRANSACTION

				IF @debug = 1 BEGIN
					PRINT 'Successfully deleted SAT transactions'
				END

				DELETE FROM #tbl_SATTxnsToBePurged
				WHERE ID IN
					(
						SELECT #tbl_SubsetSATTxnsToBePurged.ID ID
						FROM #tbl_SubsetSATTxnsToBePurged
					)

				IF @debug = 1 BEGIN
					PRINT 'Successfully deleted transactions from #tbl_TxnsToBePurged'
				END

				DELETE FROM #tbl_SubsetTxnsToBePurged

				IF @debug = 1 BEGIN
					PRINT 'Determing number of rows remaining to be Purged.'
				END

				IF (@resultCount > 0) BEGIN
					SET @deleteHappened = 1
				END	
				
				SELECT @resultCount = count(*) FROM #tbl_SATTxnsToBePurged

				IF @debug = 1 BEGIN
					PRINT 'BOT of SAT Loop: Total Number Txns To Be Purged: ' + CAST(@resultCount AS NVARCHAR)
				END
			END

			DELETE FROM #tbl_SATTxnsToBePurged
            

			--
			-- Purge AWESteps transactions
			--

			CREATE TABLE #tbl_AWEStepsToBePurged
			(
				ID numeric,
				CONSTRAINT [PK_tbl_AWEStepsToBePurged] PRIMARY KEY CLUSTERED
				(
					ID ASC
				)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
			) ON [PRIMARY]

			CREATE TABLE #tbl_SubsetAWEStepsToBePurged
			(
				ID numeric,
				CONSTRAINT [PK_tbl_SubsetAWEStepsToBePurged] PRIMARY KEY CLUSTERED
				(
					ID ASC
				)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
			) ON [PRIMARY]

			SET @sql =
				'INSERT INTO #tbl_AWEStepsToBePurged ' +
					'SELECT DISTINCT(ID) ID ' +
					'FROM tbl_AWESteps ' +
					'WHERE time_stamp BETWEEN @lstartTime AND @lstopTime  ' +
					'GROUP BY ID'

			EXEC sp_executesql @sql, N'@lstartTime datetime, @lstopTime datetime', @startTime, @stopTime

			SET @lastResultCount = -1
			SELECT @resultCount = count(*) FROM #tbl_AWEStepsToBePurged

			IF @debug = 1 BEGIN
				PRINT 'Total Number AWESteps To Be Purged: ' + CAST(@resultCount AS NVARCHAR)
			END

			WHILE ((@resultCount > 0) AND (@resultCount != @lastResultCount)) BEGIN

				SET @lastResultCount = @resultCount

				SET @sql =
					'INSERT INTO #tbl_SubsetAWEStepsToBePurged ' +
						'SELECT TOP ' + CAST(@purgeSize AS NVARCHAR) + ' #tbl_AWEStepsToBePurged.ID ' +
						'FROM #tbl_AWEStepsToBePurged ' +
						'ORDER BY ID'

				IF @debug = 1 BEGIN
					PRINT 'SQL to determine AWESteps PurgeSet: ' + @sql
				END

				EXEC sp_executesql @sql

				SELECT @resultCount = count(*) FROM #tbl_SubsetAWEStepsToBePurged

				IF @debug = 1 BEGIN
					PRINT 'Total Number AWESteps To Be Purged This Round: ' + CAST(@resultCount AS NVARCHAR)
				END

				BEGIN TRANSACTION
				
				DELETE FROM tbl_AWESteps
				WHERE ID IN
					(
						SELECT ID
						FROM #tbl_SubsetAWEStepsToBePurged
					)

				COMMIT TRANSACTION

				IF @debug = 1 BEGIN
					PRINT 'Successfully deleted AWESteps'
				END

				DELETE FROM #tbl_AWEStepsToBePurged
				WHERE ID IN
					(
						SELECT #tbl_AWEStepsToBePurged.ID ID
						FROM #tbl_SubsetAWEStepsToBePurged
					)

				IF @debug = 1 BEGIN
					PRINT 'Successfully deleted rows from #tbl_AWEStepsToBePurged'
				END

				DELETE FROM #tbl_SubsetAWEStepsToBePurged

				IF @debug = 1 BEGIN
					PRINT 'Determing number of rows remaining to be Purged.'
				END

				IF (@resultCount > 0) BEGIN
					SET @deleteHappened = 1
				END	
				
				SELECT @resultCount = count(*) FROM #tbl_AWEStepsToBePurged

				IF @debug = 1 BEGIN
					PRINT 'BOT of AWESteps Loop: Total Number Rows To Be Purged: ' + CAST(@resultCount AS NVARCHAR)
				END
			END

			DELETE FROM #tbl_AWEStepsToBePurged
            
            
		END TRY

		BEGIN CATCH
			-- Whoops, there was an error
			IF @@TRANCOUNT > 0 BEGIN
				ROLLBACK
			END

			-- Raise an error with the details of the exception
			DECLARE @ErrMsg nvarchar(4000),
					@ErrSeverity int
			SELECT	@ErrMsg = ERROR_MESSAGE(),
					@ErrSeverity = ERROR_SEVERITY()

			RAISERROR(@ErrMsg, @ErrSeverity, 1)
		END CATCH

		-- Regardless of whether there was an error, we need to
		-- remove the temporary table and dealloate the cursor
		-- we created.
		BEGIN TRY
			DROP TABLE #tbl_TxnsToBePurged
		END TRY
		BEGIN CATCH
		END CATCH

		BEGIN TRY
			DROP TABLE #tbl_SubsetTxnsToBePurged
		END TRY
		BEGIN CATCH
		END CATCH

		BEGIN TRY
			DEALLOCATE id_cursor;
		END TRY
		BEGIN CATCH
		END CATCH

		BEGIN TRY
			DEALLOCATE tablename_cursor;
		END TRY
		BEGIN CATCH
		END CATCH

		--
		-- drop sat and AWESteps temp tables
		--

		BEGIN TRY
			DROP TABLE #tbl_SATTxnsToBePurged
		END TRY
		BEGIN CATCH
		END CATCH

		BEGIN TRY
			DROP TABLE #tbl_SubsetSATTxnsToBePurged
		END TRY
		BEGIN CATCH
		END CATCH
        
		BEGIN TRY
			DROP TABLE #tbl_AWEStepsToBePurged
		END TRY
		BEGIN CATCH
		END CATCH

		BEGIN TRY
			DROP TABLE #tbl_SubsetAWEStepsToBePurged
		END TRY
		BEGIN CATCH
		END CATCH

	END
GO


SET STATISTICS TIME OFF
EXEC sp_PurgeEFTTransactions NULL, NULL, 100000, 1
SET STATISTICS TIME OFF


PRINT ''
PRINT 'Script completed at: ' + CAST(CURRENT_TIMESTAMP AS NVARCHAR)

GO
