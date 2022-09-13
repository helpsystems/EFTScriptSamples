/*

WHAT: 
Detects superfluous indexes

WHY:
These can hurt performance, since the DB must update them during Inserts, Updates and Deletes. And if they’re never used, then that’s a waste of resources.

WHEN:
Created in April of 2019

WHO:
Created by Globalscape, Inc.

HOW:
It’s best run on one of the larger, well-used databases, since it then has more info to work with. Otherwise stats won't be available to determine whether indexes are unused or not. Indexes that are identified as seldom used should be deleted by your db admin.

*/

SELECT TOP 10 o.name AS TableName, i.name AS IndexName, u.user_seeks As Seeks, u.user_scans As Scans, u.user_lookups As Lookups,
  u.user_updates As UserUpdates, u.last_user_seek As LastUserSeek, u.last_user_scan As LastUserScan,
  (SELECT SUM(s.[used_page_count]) * 8 FROM sys.dm_db_partition_stats s WHERE s.[object_id] = i.[object_id] AND s.[index_id] = i.[index_id]) As IndexSizeKB,
  'Drop index ' + i.name + ' on ' + o.name as DropIndexStatement
FROM sys.indexes i
JOIN sys.objects o ON  i.object_id = o.object_id
LEFT JOIN  sys.dm_db_index_usage_stats u ON i.object_id = u.object_id
          AND    i.index_id = u.index_id
          AND    u.database_id = DB_ID()
WHERE    o.type <> 'S'
and isnull(u.user_updates,0) > 0
and i.type_desc <> 'HEAP'
and i.type_desc <> 'CLUSTERED'
and u.user_seeks < 5 and u.user_scans < 5 and u.user_lookups < 5
ORDER BY  IndexSizeKB DESC, UserUpdates DESC