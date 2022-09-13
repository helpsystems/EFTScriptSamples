SELECT *
FROM tbl_ProtocolCommands
WHERE Protocol = 'HTTPS' AND Command = 'copy' AND CommandParameters LIKE '%filename.txt%' AND Time_stamp > '2020-04-1' AND Time_stamp < '2020-04-2'
