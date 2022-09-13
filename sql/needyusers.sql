SELECT TOP 3 UserName, Count(*) As SuccessConnections
FROM tbl_Authentications
WHERE resultID = 0 AND protocol <> 'Administration' AND Time_stamp >= DATEADD(minute,-1440,GetDate())
GROUP BY UserName
ORDER BY SuccessConnections DESC

SELECT TOP 3 UserName, Count(*) As FailedConnections
FROM tbl_Authentications
WHERE resultID = 1 AND protocol <> 'Administration' AND Time_stamp >= DATEADD(minute,-1440,GetDate())
GROUP BY UserName
ORDER BY FailedConnections DESC