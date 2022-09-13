# (c) Robert Carter
# Hide PowerShell Console
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();
[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'
$consolePtr = [Console.Window]::GetConsoleWindow()
[Console.Window]::ShowWindow($consolePtr, 0)


Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$Form                            = New-Object system.Windows.Forms.Form
$Form.ClientSize                 = '528,70'
$Form.text                       = "Dummy File Creator v1.0"
$Form.TopMost                    = $false
$Form.KeyPreview                 = $True

$Form.Add_KeyDown({if ($_.KeyCode -eq "Enter")
{Create-Dummy}})
$Form.Add_KeyDown({if ($_.KeyCode -eq "Escape")
{$Form.Close()}})

$PathBx                          = New-Object system.Windows.Forms.TextBox
$PathBx.multiline                = $false
$PathBx.width                    = 172
$PathBx.height                   = 20
$PathBx.location                 = New-Object System.Drawing.Point(9,35)
$PathBx.Font                     = 'Microsoft Sans Serif,10'
$PathBx.Text                     = $Env:userprofile + "\Desktop"

$CreateBt                        = New-Object system.Windows.Forms.Button
$CreateBt.text                   = "Create"
$CreateBt.width                  = 60
$CreateBt.height                 = 30
$CreateBt.location               = New-Object System.Drawing.Point(449,19)
$CreateBt.Font                   = 'Microsoft Sans Serif,10,style=Bold'

$SizeBx                          = New-Object system.Windows.Forms.TextBox
$SizeBx.multiline                = $false
$SizeBx.width                    = 51
$SizeBx.height                   = 20
$SizeBx.location                 = New-Object System.Drawing.Point(321,35)
$SizeBx.Font                     = 'Microsoft Sans Serif,10'
$SizeBx.Text                     = '20'

$QuantityBx                      = New-Object system.Windows.Forms.TextBox
$QuantityBx.multiline            = $false
$QuantityBx.width                = 36
$QuantityBx.height               = 20
$QuantityBx.location             = New-Object System.Drawing.Point(383,35)
$QuantityBx.Font                 = 'Microsoft Sans Serif,10'
$QuantityBx.Text                  = '1'

$PathLb                          = New-Object system.Windows.Forms.Label
$PathLb.text                     = "Path to file:"
$PathLb.AutoSize                 = $true
$PathLb.width                    = 25
$PathLb.height                   = 10
$PathLb.location                 = New-Object System.Drawing.Point(9,12)
$PathLb.Font                     = 'Microsoft Sans Serif,10'

$SizeLb                          = New-Object system.Windows.Forms.Label
$SizeLb.text                     = "Size MB:"
$SizeLb.AutoSize                 = $true
$SizeLb.width                    = 25
$SizeLb.height                   = 10
$SizeLb.location                 = New-Object System.Drawing.Point(321,12)
$SizeLb.Font                     = 'Microsoft Sans Serif,10'

$QuantityLb                      = New-Object system.Windows.Forms.Label
$QuantityLb.text                 = "Quantity:"
$QuantityLb.AutoSize             = $true
$QuantityLb.width                = 25
$QuantityLb.height               = 10
$QuantityLb.location             = New-Object System.Drawing.Point(383,11)
$QuantityLb.Font                 = 'Microsoft Sans Serif,10'

$BrowseBt                        = New-Object system.Windows.Forms.Button
$BrowseBt.text                   = "..."
$BrowseBt.width                  = 27
$BrowseBt.height                 = 24
$BrowseBt.location               = New-Object System.Drawing.Point(195,35)
$BrowseBt.Font                   = 'Microsoft Sans Serif,10'
$BrowseBt.Add_Click({$browse.ShowDialog();$PathBx.Text = $Browse.SelectedPath })

$FileNameBx                      = New-Object system.Windows.Forms.TextBox
$FileNameBx.multiline            = $false
$FileNameBx.width                = 75
$FileNameBx.height               = 20
$FileNameBx.location             = New-Object System.Drawing.Point(233,35)
$FileNameBx.Font                 = 'Microsoft Sans Serif,10'
$FileNameBx.Text                 = "dummy.txt"

$FileNameLb                      = New-Object system.Windows.Forms.Label
$FileNameLb.text                 = "FileName:"
$FileNameLb.AutoSize             = $true
$FileNameLb.width                = 25
$FileNameLb.height               = 10
$FileNameLb.location             = New-Object System.Drawing.Point(233,13)
$FileNameLb.Font                 = 'Microsoft Sans Serif,10'

$Browse = new-object system.windows.Forms.FolderBrowserDialog
$Browse.RootFolder = [System.Environment+SpecialFolder]'MyComputer'
$Browse.ShowNewFolderButton = $true
$Browse.selectedPath = "C:\"
$Browse.Description = "Choose a directory:"

$Form.controls.AddRange(@($PathBx,$CreateBt,$SizeBx,$QuantityBx,$PathLb,$SizeLb,$QuantityLb,$BrowseBt,$FileNameBx,$FileNameLb))

$CreateBt.Add_Click({Create-Dummy})

Function Create-Dummy {

$exten = $null

If ($FileNameBx.Text.Contains('.'))
{
$exten = '.' + $FileNameBx.Text.Split('.')[1]
}

fsutil file createnew ($PathBx.Text + '\' + $FileNameBx.Text) (($SizeBx.Text -as [INT]) * 1048576)

For($j = ($QuantityBx.Text -as [INT]); $j -gt 1; $j--)
{

fsutil file createnew ($PathBx.Text + '\' + $FileNameBx.Text.Split('.')[0] + $j + $exten) (($SizeBx.Text -as [INT]) * 1048576)

}

}


#Show form
$Form.Topmost = $True
$Form.Add_Shown({$Form.Activate()})
[void] $Form.ShowDialog()