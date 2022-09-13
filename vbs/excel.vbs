Dim objXL
Dim objWB
Dim objWS

Set objXL = CreateObject("Excel.Application")
Set objWB = objXL.Workbooks.Open("C:\wd\scripts\blahblah.xls")
Set objWS = objWB.Worksheets("sheet1")

objWS.Rows(1).EntireRow.Delete

objWB.Save

objWB.Close

objXL.Quit

Set objXL = Nothing
Set objWB = Nothing
Set objWS = Nothing