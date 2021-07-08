<#
.DESCRIPTION
This script captures/re-applies permissions of the provided location.
.PARAMETER
Parameters:
       -location  - location of the files
                                       - This parameter is mandatory and default value is C:
       -mode  - Mode/operation which accepts two values capture/reapply
                  - capture to capture/record the folders and files permission recursively for the location
                  - reapply the already captured folders and files permissions recursively to the location
                  - This parameter is mandatory
        -dbLocation - Location to which the script can write the generated files
                         - default value is C:\TMP
                         - This parameter is optional
        -help        - Outputs the information about various available parameters
#>

<#
The Parameters for the script are taken from here. The default values are set.
#>

param (
[string]$location="C:\",
[string]$mode,
[string]$dbLocation="C:\TMP"
)



function checkDBLocation()
{
  Write-Debug "Check if the dbLocation directory exists and if not it will be created"
  if (-NOT (Test-Path $dbLocation)){
    mkdir $dbLocation | out-null
  }
}

<#
This is for providing the options as help.
.\permisssions_sync.ps1 -help should give the necessary help.
#>

if ($args[0] -like "-help")
{
  Write-Output "Captures and re-apply permissions for the files in provided location.                                                                "
  Write-Output " Parameters:                                                                                                                   "
  Write-Output "       -location  -location of the files to capture/reapply permission                                                            "
  Write-Output "                                       - This parameter by default takes C:                                                          "
  Write-Output "                                                                                                                               "
  Write-Output "       -mode  - Mode/operation which accepts two values capture/reapply                                                    "
  Write-Output "                  - capture to capture/record the folders and files permissions recursively in the given location   "
  Write-Output "                  - reapply the already captured folders and files permissions recursively in the given location    "
  Write-Output "                  - This parameter is mandatory                                                                                "
  Write-Output "                                                                                                                               "
  Write-Output "        -dbLocation - Location to which the script can write the generated files                                          "
  Write-Output "                         - default value is C:\tmp                                                                               "
  Write-Output "                         - This parameter is optional                                                                          "
  Write-Output "                                                                                                                               "
  Write-Output "        -help        - Outputs the information about various available parameters                                           "
}
else
{
if (-NOT $mode)
{
  Write-Error "Mode has to be provided. Please use the -help flag to get more details."
  Write-Error ".\permisssions_sync.ps1 -help should give the necessary help."
  Break
}

Write-Output "The mode is set to $mode"

###############################################################################################################################################################
### In Capture mode
###############################################################################################################################################################

if($mode -like "capture")
{
  #####################################################
  ### Check if the path for the CSV exists or not:
  #####################################################
  $start=Get-Date
  checkDBLocation
  $Header = '"FolderName","IdentityReference","AccessControlType","PropagationFlags","FileSystemRights","InheritanceFlags"'
  if (Test-Path "$dbLocation\Permissions.csv")
  {
    Remove-Item "$dbLocation\Permissions.csv"
  }
  Add-Content -Value $Header -Path "$dbLocation\Permissions.csv"

  #############################################
  ### Recursively parse all directories
  #############################################
  Write-Debug "The parsing of all the files and folders will be started"
  $Folders = Get-ChildItem -Path $location -Recurse -Force
  Write-Debug "The parsing of all the files and folders is completed"
  ##########################################################################################
  ### Report the permissions for different files and directories
  ##########################################################################################
  Write-Debug "The collection of different file and folder permissions will be started"
  $sb = New-Object System.Text.StringBuilder

  foreach ($Folder in $Folders){
  $ACLs = get-acl $Folder.fullname | ForEach-Object { $_.Access }
    Foreach ($ACL in $ACLs){
    $OutInfo = '"'+$Folder.Fullname + '","' + $ACL.IdentityReference + '","' + $ACL.AccessControlType + '","' + $ACL.PropagationFlags + '","' + $ACL.FileSystemRights + '","' + $ACL.IsInherited +'"'
    [void]$sb.Append($OutInfo)
    [void]$sb.Append("`n")
    }
  }

  Add-Content -Value $sb.ToString() -Path "$dbLocation\Permissions.csv"

  $end=Get-Date
  $totalSeconds = "{0:N4}" -f ($end-$start).TotalSeconds
  Write-Output $totalSeconds
  Write-Debug "The collection of different file and folder permissions is completed"
}
###############################################################################################################################################################
### In reapply mode
###############################################################################################################################################################
elseif ($mode -like "reapply")
{
  If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
  {
  Write-Error "You do not have Administrator rights to run this script! Please re-run this script as an Administrator!"
  Break
  }
  If (-NOT (Test-Path "$dbLocation\Permissions.csv" ) )
  {
  Write-Error "$dbLocation\Permissions.csv does not exist. Please point to the location that has the file - Permissions.csv generated by this script or rerun the script with -help option to know how to capture permissions"
  Break
  }
  Write-Output "Re-applying captured permissions"
  $start=Get-Date
  $HashTable = @{}
  $par = Import-Csv -Path "$dbLocation\Permissions.csv"
  foreach ( $i in $par ) {
      $path= $i.FolderName
      $IdentityReference= $i.IdentityReference
      $AccessControlType=$i.AccessControlType
      $PropagationFlags=$i.PropagationFlags
      $FileSystemRights=$i.FileSystemRights
      if($PropagationFlags -notmatch "InheritOnly"){
        $permission = $IdentityReference,$FileSystemRights,$AccessControlType
        $HashTable[$path]=$permission
    }
  }
    $interim=Get-Date
    $interimSeconds = "{0:N4}" -f ($interim-$start).TotalSeconds
    Write-Output "The hashing is completed at $interimSeconds"
  $acl = Get-Acl $location
  ForEach ($key in $HashTable.Keys)
  {
    $accessRule = new-object System.Security.AccessControl.FileSystemAccessRule $HashTable[$key]
    $acl.SetAccessRule($accessRule)
    $acl | Set-Acl $key
  }
  $end=Get-Date
  $totalSeconds = "{0:N4}" -f ($end-$start).TotalSeconds
  Write-Output "The restore of permissions took : $totalSeconds"
  }
}
