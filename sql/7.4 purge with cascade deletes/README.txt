

1. Run recreate_foreign_keys.sql first, as it will fix any problems with FK associations if present (see notes in that script)

2. Run index_foreign_keys_and_time_stamps.sql next, as that will signficantly improve purge performance.

3. Open PurgeSQLEFTData.sql

3. Modify the purge date if desired. -30 means purge all records older than 30 days
	3a. To change: search for "SET @stopTime = DATEADD(DAY, -60, GETDATE())"
	3b. A value of -0 means ALL records
	3c. Alternatively, you can pass in an exact date range:
		3ci. Search for EXEC sp_PurgeEFTTransactions NULL, NULL, 1000000, 1 
		3cii. Enter date and times in quotes as such: EXEC sp_PurgeEFTTransactions '2019-01-20 18:11:00', '2019-04-01 07:50:00', 1000000, 1 

4. Modify "USE EFTDB" below if your database name is different

5. Make sure you database is NOT actively recording data (disable ARM reporting in EFT temporarily)

6. Execute the script (it may take several hours if your databases has hundreds of millions of records) 