SELECT *
FROM tbl_ClientOperations
WHERE Protocol = 'AS2' AND Operation = 'UPLOAD_MOVE' AND LocalPath LIKE '%%' AND BytesTransferred LIKE '0' --AND Time_stamp > '2020-04-1' AND Time_stamp < '2020-04-2'