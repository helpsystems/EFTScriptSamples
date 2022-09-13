/*
Script by: Jonathan Branan, 8-10-2020

Purpose: To trim uneeded data from fact tables in EFT's database. A simple function that allows a specification of 'daysSaved'.

DISCLAIMER: Use at your own risk. Globalscape does not accept ANY responsiblity for any unexpected outcomes as a result of use of this script.

Version 1.0 - Added before and after row counts, status updates and set default retention period to match EFT's Purge Script.
*/

DECLARE @count INT
DECLARE	@daysSaved DATETIME2
--Set the integer "60" to the amount of days you would like to retain in the fact tables.
SET	@daysSaved = DATEADD(DAY, -60, GETDATE())


PRINT 'Fact Table Purge Version 1.0'
PRINT ''
PRINT 'Row count of Fact Tables before the purge:'
PRINT ''

--Initial Row Count
select @count =  count(*) from [dbo].[tbl_Report_Exec_Summ] PRINT '	tbl_Report_Exec_Summ count = ' +CAST(@count AS NVARCHAR)
select @count =  count(*) from [dbo].[tbl_Report_Traffic1] PRINT '	tbl_Report_Traffic1 count = ' +CAST(@count AS NVARCHAR)
select @count =  count(*) from [dbo].[tbl_Report_Traffic2] PRINT '	tbl_Report_Traffic2 count = ' +CAST(@count AS NVARCHAR)
select @count =  count(*) from [dbo].[tbl_Report_Traffic3] PRINT '	tbl_Report_Traffic3 count = ' +CAST(@count AS NVARCHAR)
select @count =  count(*) from [dbo].[tbl_Report_Traffic4] PRINT '	tbl_Report_Traffic4 count = ' +CAST(@count AS NVARCHAR)

PRINT ''
PRINT 'Purging Fact Tables...'
PRINT ''

--Purge Fact Tables
PRINT 'Purging from tbl_Report_Exec_Summ...'
DELETE FROM tbl_Report_Exec_Summ WHERE DayOfRecord < @daysSaved

PRINT ''
PRINT 'Purging from tbl_Report_Traffic1...'
DELETE FROM tbl_Report_Traffic1 WHERE DayOfRecord < @daysSaved

PRINT ''
PRINT 'Purging from tbl_Report_Traffic2...'
DELETE FROM tbl_Report_Traffic2 WHERE DayOfRecord < @daysSaved

PRINT ''
PRINT 'Purging from tbl_Report_Traffic3...'
DELETE FROM tbl_Report_Traffic3 WHERE DayOfRecord < @daysSaved

PRINT ''
PRINT 'Purging from tbl_Report_Traffic4...'
DELETE FROM tbl_Report_Traffic4 WHERE DayOfRecord < @daysSaved

PRINT ''
PRINT 'Purging Complete'
PRINT ''
PRINT 'Row counts of Fact Tables after the purge:'
PRINT ''

--Final Row Count
select @count =  count(*) from [dbo].[tbl_Report_Exec_Summ] PRINT '	tbl_Report_Exec_Summ count = ' +CAST(@count AS NVARCHAR)
select @count =  count(*) from [dbo].[tbl_Report_Traffic1] PRINT '	tbl_Report_Traffic1 count = ' +CAST(@count AS NVARCHAR)
select @count =  count(*) from [dbo].[tbl_Report_Traffic2] PRINT '	tbl_Report_Traffic2 count = ' +CAST(@count AS NVARCHAR)
select @count =  count(*) from [dbo].[tbl_Report_Traffic3] PRINT '	tbl_Report_Traffic3 count = ' +CAST(@count AS NVARCHAR)
select @count =  count(*) from [dbo].[tbl_Report_Traffic4] PRINT '	tbl_Report_Traffic4 count = ' +CAST(@count AS NVARCHAR)

PRINT ''
PRINT 'Done'