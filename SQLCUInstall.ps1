#Execute script from the server to install SQL
#right click and unblock the installation media enable silent install
#install media can/cannot be unpacked with /x prior to install
#install script stored on localserver\c$\Documents\SQLCUInstall.ps1

#run with admin rights
Param (
    [switch]$Elevated
)

function Test-Admin {
  $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
  $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

if ((Test-Admin) -eq $false)  {
    if ($elevated) 
    {
        # tried to elevate, did not work, aborting
    } 
    else {
        Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
}

exit
}


Param (
    [switch]$Silent = $false
)

#------------------------------------------------------------
# Disable McAfee Move 
# - will interfere with installation of SQL if not done
#------------------------------------------------------------

#https://kc.mcafee.com/corporate/index?page=content&id=KB74700

$moveAvExists = $false
try 
{
    mvadm help | out-null
    $moveAvExists = $true
}
catch {}

if ($moveAvExists) 
{
    write-host "Disabling MOVE AV..." -fore Yellow
    mvadm disable
}
else 
{
    write-host "Move AV not installed." -fore yellow
}


#------------------------------------------------------------
# Get Installer for this server
#------------------------------------------------------------

# Get path that script file is running from
$root = "\\mk-ds02\mkc_public\Information Technology\Database Admins\SQL Server\SQL Server Updates\" #split-path $pscommandpath -Parent

# Path of Change List
$ChangeList = join-path $root "ChangeList.csv"

# Where we store the installer files
#$repository = "\\mk-ds02\itstorage\installs\microsoft\SQL Server\"
$repository = "\\dc1-tools01\installs\Microsoft.com\SQL Server\"

write-host "Locating installer for $env:COMPUTERNAME"

# Load change list
$servers = Import-Csv $ChangeList

if (-not $servers) { 
    THROW "No Change List data loaded!"
    RETURN
}

# Grab only this server
$ThisServer = $servers | where {$_.SvrName -like $env:COMPUTERNAME}

if (-not $ThisServer) {
    THROW "Unable to locate $env:COMPUTERNAME in ChangeList.csv !"
    RETURN
}

# Get NewVersion
$NewVersion = $ThisServer.NewVersion

if (-not $NewVersion) {
    THROW "No Installer found for $env:COMPUTERNAME"
    RETURN
}

# Build path variable to installer folder
$installerFolder = join-path $repository $NewVersion

if (-not (test-path $installerFolder -PathType Container)) {
    THROW "Installer folder not found: $installerFolder"
    RETURN
}

# Locate EXE in folder
$installer = Get-ChildItem $installerFolder -filter '*.exe' | select -expand Fullname

if (-not $installer) {
    THROW "No EXE found in $installerFolder"
    RETURN
}


#------------------------------------------------------------
# Install SQL
# - waits for installer to finish
#------------------------------------------------------------

Write-host "Installing SQL: $NewVersion" -fore yellow

#Run executable
if ($Silent) {
    start-process $installer -ArgumentList ('/allinstances', '/quiet' ,'/IACCEPTSQLSERVERLICENSETERMS') -Wait
}
else {
    start-process $installer -ArgumentList ('/allinstances', '/quiet' ,'/IACCEPTSQLSERVERLICENSETERMS') -Wait
}

#& $installer /allinstances /q /IACCEPTSQLSERVERLICENSETERMS 


#------------------------------------------------------------
# Re-enable MOVE AV
#------------------------------------------------------------
if ($moveAvExists) 
{
    write-host "Re-enabling MOVE AV..." -fore Yellow
    mvadm enable
}


write-host "Complete" -fore green