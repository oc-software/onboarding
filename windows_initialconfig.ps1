###------------------ Initial configuration for Windows devices ------------------

#------------------ Warns of reboot possibility and prompts to continue ------------------
$warning = Read-Host "If the computer name needs to be changed this device will reboot upon completion, continue? [y/n]"
if ($warning -eq 'y'){
    Write-Host
}
else {
    exit
}

$hostName = Read-Host "Please enter the computer name"
$admin = Read-Host "Please enter the name of the local admin"
#------------------ Asks user to set Owner's password with confirmation it was entered correct then applies it ------------------
if (Get-LocalUser -Name $admin) {
    do {
        $pass = Read-Host "Please enter a password for $admin" -AsSecureString -MaskInput
        $passConfirm = Read-Host "Please confirm the password" -AsSecureString -MaskInput
    }
    while ($pass -notmatch $passConfirm) {
        Get-LocalUser -Name $admin | Set-LocalUser -Password $pass
        Write-Host "$admin's password has been set"
    }
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
}
