###------------------ Initial configuration for Windows devices ------------------

#------------------ Warns of reboot possibility and prompts to continue ------------------
$warning = Read-Host -Prompt "Device will reboot upon completion, continue? [y/n]"

if ($warning -eq 'y'){
    Write-Host
}
else {
    exit
}

$hostName = Read-Host "Please enter the computer name"
$admin = Get-LocalUser -Name "owner"
#------------------ Asks user to set Owner's password with confirmation it was entered correct then applies it ------------------
if ($admin) {
    do {
        $pass = Read-Host -AsSecureString -Prompt "Please enter a password for $admin"
        $passConfirm = Read-Host -AsSecureString -Prompt "Please confirm the password"
    }
    while ($pass -notmatch $passConfirm) {
    }
    Get-LocalUser -Name $admin | Set-LocalUser -Password $pass
    Write-Host "$admin's password has been set"
}
else {
    Write-Error "$admin does not exist, please rerun this script and enter an existing local admin"
}

#------------------ Set's computer name if needed ------------------
if ($hostName -notmatch $env:COMPUTERNAME) {
    Rename-Computer -NewName $hostName -Restart
}
else {
    Write-Host "Computer name already set to $hostName"
    Start-Sleep -Seconds 5
    Restart-Computer -Force
}
