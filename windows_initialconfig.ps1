###------------------ Initial configuration for Windows devices ------------------

#------------------ Warns of reboot possibility and prompts to continue ------------------
$title = 'Device will restart upon completion'
$message = 'Continue?'
$yes = New-Object System.Management.Automation.ChoiceDescription '&Yes', 'Will reboot'
$no = New-Object System.Management.Automation.Host.ChoiceDescription '&No', 'Exits'
$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes,$no)
$warning = $host.UI.PromptForChoice($title, $message, $options, 0)
switch ($warning) {
    0 {$choice = 'y'}
    1 {$choice = 'n'}
}
if ($choice -eq 'y'){
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
    Restart-Computer -Force
}
