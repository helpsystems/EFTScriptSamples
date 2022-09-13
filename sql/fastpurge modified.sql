-- [Optional] Set Database Recovery Mode to Simple
-- [Optional] Comment out lines 20-27 from sp_RemoveTxns (these seem unnecessary since the auxiliary tables are cleaned up by their cascade delete rule)

USE jonathan27
GO

-- CREATE INDEXES TO SPEED UP TRANSACTION PURGE
-- Note that these commands took appromimately 2 minutes 30 seconds to complete in total.
-- This IX_tbl_Transactions_ParentTransactionID index provides the most significant performance improvement
-- because otherwise for each record being deleted it would have to perform a full table scan to find any records
-- that have it as a parent.  The table scan is likely to be very slow when tbl_Transactions is large.  With this
-- index the query can do an index seek which is a much faster operation.
CREATE NONCLUSTERED INDEX IX_tbl_Transactions_ParentTransactionID   
    ON [dbo].[tbl_Transactions] ([ParentTransactionID])
GO 

CREATE NONCLUSTERED INDEX IX_tbl_ProtocolCommands_TransactionID
    ON [dbo].[tbl_ProtocolCommands] ([TransactionID])
    INCLUDE ([ProtocolCommandID])
GO

CREATE NONCLUSTERED INDEX IX_tbl_SocketConnections_TransactionID
    ON [dbo].[tbl_SocketConnections] ([TransactionID])
    INCLUDE ([SocketID])
GO

-- PERFORM PURGE 
DECLARE	@return_value int
DECLARE	@stopTimetemp DATETIME2
SET	@stopTimetemp = DATEADD(DAY, -60, GETDATE())
EXEC	@return_value = [dbo].[sp_PurgeEFTTransactions]
		@startTime = N'19700101', -- Set to desired start time
		@stopTime = @stopTimetemp, -- Set to desired stop time
		@purgeSize = NULL,
		@debug = 0

SELECT	'Return Value' = @return_value

-- DELETE INDEXES CREATED TO SPEED UP PURGE
DROP INDEX IX_tbl_Transactions_ParentTransactionID ON [dbo].[tbl_Transactions]
DROP INDEX IX_tbl_ProtocolCommands_TransactionID ON [dbo].[tbl_ProtocolCommands]
DROP INDEX IX_tbl_SocketConnections_TransactionID ON [dbo].[tbl_SocketConnections]
GO