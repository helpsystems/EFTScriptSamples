ServerAddress = "192.168.102.28"
ServerUsername = "eftadmin"
ServerPassword = "a"
ExcelFile = "R:\jhulme\COM Scripts\usersGlobalscape.xlsx"
Set SFTPServer = CreateObject("SFTPCOMInterface.CIServer")

SFTPServer.Connect ServerAddress,1100,ServerUsername,ServerPassword

Set sites=SFTPServer.Sites
Set site = sites.Item(0)
SFTPServer.RefreshSettings

Set objExcel = CreateObject("Excel.Application")
Set objWorkbook = objExcel.Workbooks.Open(ExcelFile)
objExcel.Visible = True
i = 1
Do Until objExcel.Cells(i, 1).Value = ""
	site.CreateUserEx objExcel.Cells(i, 1).Value, objExcel.Cells(i, 2).Value, 0, objExcel.Cells(i, 4).Value, objExcel.Cells(i, 5).Value,True,True,objExcel.Cells(i, 6).Value
	i = i + 1
Loop
objExcel.Quit
SFTPServer.AutoSave=True
SFTPServer.ApplyChanges
