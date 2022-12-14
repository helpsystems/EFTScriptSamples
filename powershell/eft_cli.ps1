 [CmdletBinding()]
 param()
$global:Server = $null
$global:sites  = $null
$global:site   = $null
$global:user   = $null

#####################################################################
## Server 
#####################################################################
function EFT-Connect(
        [Parameter(Position = 0, Mandatory=$False, HelpMessage = "Enter a host name or IP address")]
        [String] $Hostname = "localhost", 
        
        [Parameter(Position = 1, Mandatory=$False, HelpMessage = "Enter a port where EFT Server is listening for admin connections")]
        [int] $Port = 1111, 
        
        [Parameter(Position = 2, Mandatory=$False, HelpMessage = "Enter a Authentication Type to connect to EFT Server. 0: EFT Login, 1: Windows Login, 2: Network Logon")]
        [int] $AuthType=1,
        
        [Parameter(Position = 3, Mandatory=$False, HelpMessage = "Enter login")]
        [String] $Login, 
        
        [Parameter(Position = 4, Mandatory=$False, HelpMessage = "Enter password")]
        [String] $Password 
        )
{
<#
    .SYNOPSIS 
      Connects to an EFT Server
    .EXAMPLE
     EFT-Connect localhost 1100 admin admin
     This commands will connect to an EFT server listening in localhost using port 1100 and using 
     admin/admin as username/password.
#>

        Write-Verbose "hostname      :$hostname"
        Write-Verbose "port          :$port"
        Write-Verbose "Login         :$login"
        Write-Verbose "len(Password) :$password.length"
        Write-Verbose "SiteName      :$siteName"
        
        $global:Server = new-object -ComObject "SFTPCOMInterface.CIServer"
        
		try
		{
            $global:Server.ConnectEx($hostname, $port, $AuthType, $login, $password)    
            $global:sites = $global:server.Sites()
            Write-Host "You are now connected !!" -ForegroundColor Green
        }
        catch [System.Runtime.InteropServices.COMException]
        {       
           Write-Host "Exception : $error[0]" -ForegroundColor Red
           Write-Host "You are NOT connected !!" -ForegroundColor Red
        }
}

function EFT-Disconnect()
{
<#
    .SYNOPSIS 
      Disconnect the connection to EFT Server
    .EXAMPLE
     EFT-Close 
     This commands will disconnect from an EFT server.
#>
   
    if ($global:site -ne $null)
    {
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($global:site)
         $global:site =$null
    }
    if ($global:sites -ne $null)
    {
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($global:sites)
         $global:sites =$null
    }
    if ($global:Server -ne $null)
    {
        $global:Server.Close()    
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($global:Server)
         $global:sites =$null
    }
}

function EFT-Status()
{
        if ($global:Server -eq $null)
        {
            Write-Host "Disconnected" -ForegroundColor Red
        }
        else
        {    
            Write-Host "Connected" -ForegroundColor Green
        }
}
#####################################################################
## Sites 
#####################################################################
function EFT-LS-Sites()
{
     if ($global:Server -eq $null)
     {
        Write-Host "You need to connect to EFT Server first" -ForegroundColor Red
     }
     else
     {
        $results =@()
        for ($i=0; $i -le $global:sites.Count()-1; $i++ )
         {
         $site = $global:sites.Item($i)
         $row = New-Object PSObject
                $row | Add-Member -type NoteProperty -name SiteName -Value $site.Name
                $row | Add-Member -type NoteProperty -name IsRunning -Value $site.IsStarted
                $row | Add-Member -type NoteProperty -name "Active Sessions" -Value $site.GetConnectedCount()
                $row | Add-Member -type NoteProperty -name UsersDefined -Value $site.UsersDefined
                $row | Add-Member -type NoteProperty -name "WTC Sessions Active" -Value $site.WTCSessionsActive
                $row | Add-Member -type NoteProperty -name "WTC Sessions Remaining" -Value $site.WTCSessionsActive
                $row | Add-Member -type NoteProperty -name "Active Uploads" -Value $site.GetUploadCount()
                $row | Add-Member -type NoteProperty -name "Active Downloads" -Value $site.GetDownloadCount()
                $results +=$row          
         }
          return $results  
          Write-Host "Site '$siteName' not found" -ForegroundColor Red
     }
}
function EFT-CD-Site(
		[Parameter(Position = 0, Mandatory=$True, HelpMessage = "Enter a site name")]
		[String]$siteName)
{
		Write-Verbose "SiteName      :$siteName"
		if ($global:Server -eq $null)
		{
			Write-Host "You need to connect to EFT Server first" -ForegroundColor Red
		}
		else
		{
			for ($i=0; $i -le $global:sites.Count()-1; $i++ )
			 {
			  $global:site = $global:sites.Item($i)
			  if ($global:site.Name -eq $siteName) {
				Write-Host "Site '$siteName' selected" -ForegroundColor Green
				return $siteName
			   }     
			 }
			  Write-Host "Site '$siteName' not found" -ForegroundColor Red
		}
}
#####################################################################
## Users 
#####################################################################
function EFT-LS-Users()
{
     if ($global:site -eq $null)
     {
        Write-Host "You need to select a EFT Site first use EFT-CD-Site <sitename>" -ForegroundColor Red    
     }
     else
     {
        $results =@()
        $users = $global:site.GetUsers()
        for ($i=0; $i -le $users.length-1; $i++ )
         {
         $row = New-Object PSObject
                $row | Add-Member -type NoteProperty -name Username -Value $users[$i]
                $results +=$row          
         }
          return $results  
          Write-Host "User not found" -ForegroundColor Red
     }
}

function EFT-CD-User()
{
    [CmdletBinding()]
	param([String]$username)
    
    if ($global:site -eq $null)
     {
        Write-Host "You need to select a EFT Site first use EFT-Site <sitename>" -ForegroundColor Red    
     }
     else
     {
        try
        {
        
            if ($global:site.DoesUsernameExist($username))
            {
                $global:user = $global:site.GetUserSettings($username)
                Write-Host "User '$username' selected" -ForegroundColor Green         
                return $global:user
            }
            else
            {
                Write-Host "User '$username' doesn't exist" -ForegroundColor Red
                return
            }
        }
        catch [System.Runtime.InteropServices.COMException]
        {       
           Write-Host "Exception : $error[0]" -ForegroundColor Red
        }
     }
}
function EFT-RM-User()
{  
    [CmdletBinding()]
	param([String]$username)
    
     if ($global:site -eq $null)
     {
        Write-Host "You need to select a EFT Site first use EFT-Site <sitename>" -ForegroundColor Red    
     }
     else
     {
        try
        {
	        $users = $global:site.RemoveUser($username)
	        for ($i=0; $i -le $users.length-1; $i++ )
	         {
		         $row = New-Object PSObject
                	$row | Add-Member -type NoteProperty -name Username -Value $users[$i]
                	$results +=$row          
         	}
         	 return $results  
        }
        catch [System.Runtime.InteropServices.COMException]
        {       
          Write-Host "User not found" -ForegroundColor Red
           Write-Host "Exception : $error[0]" -ForegroundColor Red
        }
     }
}

#####################################################################
## Virtual Folder 
#####################################################################
function EFT-LS-VirtualFolders()
{
    Write-Verbose "SiteName      :$global:site.Name"
     if ($global:site -eq $null)
     {
        Write-Host "You need to select a EFT Site first use EFT-Site <sitename>" -ForegroundColor Red    
     }
     else
     {
        $results =@()
        $paths = $global:site.GetVirtualFolderList("").Split()
        for ($i=0 ;$i -le $paths.Length - 1 ;$i++)
        {
            $currentPath =$paths.GetValue($i)
            if ($currentPath -ne "")
            {
                $row = New-Object PSObject
                $row | Add-Member -type NoteProperty -name Path -Value $currentPath
                $row | Add-Member -type NoteProperty -name PhysicalPath -Value $global:site.GetPhysicalPath($currentPath)
                $results +=$row
            }
        }
        return $results
        
     }
}
function EFT-ADD-VirtualFolders()
{
    [CmdletBinding()]
	param([String]$path, [String]$physicalPath, [bool]$validateTarget)
    
     if ($global:site -eq $null)
     {
        Write-Host "You need to select a EFT Site first use EFT-Site <sitename>" -ForegroundColor Red    
     }
     else
     {
        
        $global:site.CreateVirtualFolder($path, $physicalPath, $validateTarget);
        Write-Host "Virtual folder '$path' added" -ForegroundColor Green  
     }
}
function EFT-Update-VirtualFolder()
{
    [CmdletBinding()]
	param([String]$path, [String]$newPhysicalPath)
    
     if ($global:site -eq $null)
     {
        Write-Host "You need to select a EFT Site first use EFT-Site <sitename>" -ForegroundColor Red    
     }
     else
     {
        $global:site.RemapVirtualFolder($path, $newPhysicalPath);
        Write-Host "Virtual folder '$path' updated" -ForegroundColor Green  
     }
}
function EFT-RM-VirtualFolder()
{
    [CmdletBinding()]
	param([String]$path)
    
     if ($global:site -eq $null)
     {
        Write-Host "You need to select a EFT Site first use EFT-Site <sitename>" -ForegroundColor Red    
     }
     else
     {
         if ($global:site.IsFolderVirtual($path))
         {
            $global:site.RemoveFolder($path);
            Write-Host "path '$path' removed" -ForegroundColor Green  
         }
         else
         {
            Write-Host "path '$path' is not virtual folder" -ForegroundColor Red
         }
     }
}

#####################################################################
## Permisions 
#####################################################################
function EFT-ADD-Permissions()
{
    [CmdletBinding()]
	param(
        [String]$path, 
        [String]$clientId, 
        [bool] $ReplaceExisting,
        [bool] $FileUpload ,
        [bool] $FileDownload, 
        [bool] $FileDelete ,
        [bool] $FileRename ,
        [bool] $FileAppend ,
        [bool] $DirCreate ,
        [bool] $DirDelete ,
        [bool] $DirShowHidden, 
        [bool] $DirShowReadOnly,
        [bool] $DirShowInList,
        [bool] $DirList
        )
            
     if ($global:site -eq $null)
     {
        Write-Host "You need to select a EFT Site first use EFT-Site <sitename>" -ForegroundColor Red    
     }
     else
     {
        try
		{
            $perm = $global:site.GetBlankPermission($path, $clientId)
            $perm.FileUpload = $FileUpload;
            $perm.FileDownload = $FileDownload;
            $perm.FileDelete = $FileDelete;
            $perm.FileRename = $FileRename;
            $perm.FileAppend = $FileAppend;
            $perm.DirCreate = $DirCreate;
            $perm.DirDelete = $DirDelete;
            $perm.DirShowHidden = $DirShowHidden;
            $perm.DirShowReadOnly = $DirShowReadOnly;
            $perm.DirShowInList = $DirShowInList;
            $perm.DirList = $DirList;
            $global:site.SetPermission($perm, $ReplaceExisting);
            Write-Host "permission '$path' for client '$clientId' has been added" -ForegroundColor Green  
        }
		catch [System.Runtime.InteropServices.COMException]
		{
			 Write-Host  "Exception : $error[0]" -ForegroundColor REd  
		}
     }
}
function EFT-Update-Permissions()
{
    [CmdletBinding()]
	param(
        [String]$path, 
        [String]$clientId, 
        [bool] $ReplaceExisting,
        [bool] $FileUpload ,
        [bool] $FileDownload, 
        [bool] $FileDelete ,
        [bool] $FileRename ,
        [bool] $FileAppend ,
        [bool] $DirCreate ,
        [bool] $DirDelete ,
        [bool] $DirShowHidden, 
        [bool] $DirShowReadOnly,
        [bool] $DirShowInList,
        [bool] $DirList
        
        )
            
     if ($global:site -eq $null)
     {
        Write-Host "You need to select a EFT Site first use EFT-Site <sitename>" -ForegroundColor Red    
     }
     else
     {
        try
		{
            $permissions= $global:site.GetFolderPermissions($path)
            for ($i=0;$i-le $permissions.length-1; $i++)
            {
                $perm =$permissions.GetValue($i)
                if ($perm.Client -eq $clientId)
                {
                    $perm.FileUpload = $FileUpload;
                    $perm.FileDownload = $FileDownload;
                    $perm.FileDelete = $FileDelete;
                    $perm.FileRename = $FileRename;
                    $perm.FileAppend = $FileAppend;
                    $perm.DirCreate = $DirCreate;
                    $perm.DirDelete = $DirDelete;
                    $perm.DirShowHidden = $DirShowHidden;
                    $perm.DirShowReadOnly = $DirShowReadOnly;
                    $perm.DirShowInList = $DirShowInList;
                    $perm.DirList = $DirList;
                    $global:site.SetPermission($perm, $ReplaceExisting);
                    Write-Host "permission '$path' for client '$clientId' has been updated" -ForegroundColor Green  
                    break
                }
                else
                {
                  Write-Host "permission '$path' for client '$clientId' not found" -ForegroundColor Red
                }
            }            
        }
		catch [System.Runtime.InteropServices.COMException]
		{
			 Write-Host  "Exception : $error[0]" -ForegroundColor REd  
		}
     }
}
function EFT-LS-Permissions()
{
    [CmdletBinding()]
	param(
        [String]$path)
            
     if ($global:site -eq $null)
     {
        Write-Host "You need to select a EFT Site first use EFT-Site <sitename>" -ForegroundColor Red    
     }
     else
     {
        try
		{
           return $varpermissions= $global:site.GetFolderPermissions($path)
        }
		catch [System.Runtime.InteropServices.COMException]
		{
			 Write-Host  "Exception : $error[0]" -ForegroundColor REd  
		}
     }
}
function EFT-RM-Permission()
{
    [CmdletBinding()]
	param(
        [String]$path, 
        [String]$clientId)
            
     if ($global:site -eq $null)
     {
        Write-Host "You need to select a EFT Site first use EFT-Site <sitename>" -ForegroundColor Red    
     }
     else
     {
        try
		{
          $global:site.RemovePermission($path, $clientId )
          Write-Host "permission '$path' for client '$clientId' has been removed" -ForegroundColor Green  
          return $true
        }
		catch [System.Runtime.InteropServices.COMException]
		{
			 Write-Host  "Exception : $error[0]" -ForegroundColor Red  
             return $false
		}
     }
}