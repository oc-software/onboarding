###----------------------------- Second half of initial Windows configuration -----------------------------

###----------------------------- Jumpcloud agent install -----------------------------
Set-Location $env:temp | Invoke-Expression; Invoke-RestMethod -Method Get -URI https://raw.githubusercontent.com/TheJumpCloud/support/master/scripts/windows/InstallWindowsAgent.ps1 -OutFile InstallWindowsAgent.ps1 | Invoke-Expression; ./InstallWindowsAgent.ps1 -JumpCloudConnectKey "24d80141ecc628ae0a23cafb6b9c8b337cae06e0"

###----------------------------- Add to Active Directory -----------------------------

Add-Computer -DomainName 'oc.systems'

###----------------------------- Install initial software -----------------------------

#       --- Connectwise agent install --

$service = Get-Service -DisplayName "ScreenConnect*"

#   Check for existing service and exit if it exists
if ($service.Status -eq 'Running') {
    Exit
}
elseif ($service.Status -eq 'Stopped') {
    Start-Service -DisplayName "ScreenConnect*" -ErrorAction SilentlyContinue
}
else {
    #   Create working directory
    if (!(Test-Path C:\temp\)) {
        New-Item -ItemType Directory -Path "C:\temp"
    }

    #   Download, unzip, and install
    $url = "https://github.com/oc-software/ConnectWise/archive/refs/heads/main.zip"
    $token = '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'
    Invoke-WebRequest -Headers @{Authorization = "token $($token)"} -Uri "$url" -OutFile "C:\temp\main.zip"
    Expand-Archive -Path "C:\temp\main.zip" -DestinationPath "C:\temp\"
    Start-Process "C:\temp\ConnectWise-main\ConnectWiseControl.ClientSetup.msi"
}

#       --- 1Password 8 install ---

$url = 'https://oc-public-software.s3.us-west-2.amazonaws.com/Windows/1PasswordSetup-latest.msi'
$wc = New-Object System.Net.WebClient
$outPath = "C:\temp"
$msiPath = "C:\temp\1PasswordSetup-latest.msi"
$userPaths = (Get-ChildItem "C:\Users").Name
#       --- Checks each user's home directory for 1Password 8 exe install ---
foreach ($user in $userPaths) {
    if (Test-Path "C:\Users\$user\AppData\Local\1Password\app\8\1Password.exe") {
        Remove-Item "C:\Users\$user\Desktop\1Password.lnk"
        if (Get-Process '1Password') {
            Get-Process '1Password' | Stop-Process
            if ($LASTEXITCODE -ne 0) {
                Write-Host $LASTEXITCODE
                Exit
            }
        }
        Remove-Item -ItemType Directory -Path "C:\Users\$user\AppData\Local\1Password\app" -Recurse -Force
    } 
    else {
        Write-Host "1Password not installed for $user..."
    }
}
#       --- Tests for MSI install of 1Password 8 ---
if ((((Get-ChildItem "C:\Program Files\1Password\app\8\1Password.exe").VersionInfo | Select-Object FileVersion) -match "8.8.*") -or ((Get-Package -Name 1Password).Version -match "8.8.*")) {
        Write-Host "1Password 8 MSI already installed!"
}
elseif ((Get-Package -Name 1Password).Version -match "7.*") {
    Get-Package -Name 1Password | Uninstall-Package -ExcludeVersion "8.*"
}
#       --- Installs 1Password ---
else {
    if (!(Test-Path $outPath)) {
        New-Item -ItemType Directory -Path "C:\temp"
    }
    $wc.DownloadFile("$url","$msiPath")
    Start-Process msiexec.exe -ArgumentList "/i $msiPath /quiet"
    Start-Sleep -Seconds 15
    Write-Host "Installation complete, creating shortcut..."
    $exePath = "C:\Program Files\1Password\app\8\1Password.exe"
    if (Test-Path $exePath) {
        $ShortcutPath = "C:\Users\Public\Desktop\1Password.lnk"
        $WScriptObj = New-Object -ComObject "WScript.Shell"
        $shortcut = $WscriptObj.CreateShortcut($ShortcutPath)
        $shortcut.TargetPath = $exePath
        $shortcut.Save()
        if (Test-Path $ShortcutPath) {
            Write-Host "Installation complete! Have a nice day :)"
        }
    }
}

####       --- Install Freshservice asset agent ---

#       --- Variables ---
$url = 'https://raw.githubusercontent.com/oc-software/software/main/fs-windows-agent-2.15.0.msi'
$token = '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'
$outPath = "C:\temp"
$outFile = "C:\temp\fs-windows-agent-2.15.0.msi"
$package = Get-Package -Name "Freshservice*" -ErrorAction SilentlyContinue
#       --- Download and install ---
if (!$package) {
    if (!(Test-Path "$outPath")) {
        New-Item -ItemType Directory -Path "$outPath"
    }
    Invoke-WebRequest -Headers @{Authorization = "token $($token)"} -Uri "$url" -OutFile "$outFile"
    msiexec.exe /i $outFile /passive
} else {
    Write-Host "Freshservice agent already installed!"
}

####       --- Install Octopus ---

#       --- Checks if installed ---
$service = Get-Service -DisplayName "SDO*"
if ($service.Status -eq 'Running') { 
    Write-Host "Octopus already installed!" 
}
elseif ((Get-Service -DisplayName "SDO*").Status -eq 'Stopped') {
    Start-Service -DisplayName "SDO*"
    Write-Host "Octopus already installed, starting service..."
}
#       --- Installs SDO ---
else {
    $wc = New-Object System.Net.WebClient
    $wc.DownloadFile('https://oc-public-software.s3.us-west-2.amazonaws.com/Windows/OptConnect Octopus X64 Workstation.msi', 'C:\Windows\Temp\OptConnect Octopus X64 Workstation.msi')
    Start-Process msiexec.exe -ArgumentList '/I "C:\Windows\Temp\OptConnect Octopus X64 Workstation.msi" /qn'
    Start-Sleep -Seconds 15
    Start-Process "C:\Program Files\SecretDoubleOctopus\sdoguard.exe" -ArgumentList '-install'
    Restart-Service -DisplayName "SDO*"
}

####       --- Install Rapid7 insight agent ---

#       --- Checks if installed ---
if ((Get-Service -DisplayName "Rapid7*").Status -eq 'Running') { 
    Write-Host "Rapid7 agent already installed!" 
} 
elseif ((Get-Service -DisplayName "Rapid7*").Status -eq 'Stopped') {
    Write-Host "Rapid7 agent already installed, starting service..."
    Start-Service -DisplayName "Rapid7*" -ErrorAction SilentlyContinue
}
#       --- Installs agent ---
else {
    $wc = New-Object System.Net.WebClient
    $wc.DownloadFile('https://oc-public-software.s3.us-west-2.amazonaws.com/Windows/R7_agentInstaller-x86_64.msi', 'C:\Windows\Temp\R7_agentInstaller-x86_64.msi')
    Start-Process msiexec.exe -ArgumentList '/i "C:\Windows\Temp\R7_agentInstaller-x86_64.msi" /l*v insight_agent_install_log.log /quiet CUSTOMTOKEN=us:80d78708-f534-4132-a8e4-1eefa609ffe2'
    Write-Host "Rapid7 agent installed!"
}

####        --- Import WS0 CA to trusted certificates ---

#       --- Checks cert store for WS0 ---
$getCert = Get-ChildItem -Path Cert:\LocalMachine\Root\ | Where-Object { $_.Thumbprint -eq "D21F61FB80AFD01ACA9D5452041AB198987C6403" }
if ($getCert) {
    Write-Host "WS0 CA already present!"
} 
#       --- Gets cert from private repo and imports ---
else {
    $token = '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'
    Invoke-WebRequest -Headers @{Authorization = "token $($token)"} -Uri "https://github.com/oc-software/Certs/archive/refs/heads/main.zip" -OutFile "C:\Windows\Temp\cert.zip"
    Expand-Archive -Path "C:\Windows\Temp\cert.zip" -DestinationPath "C:\Windows\Temp\"
    Import-Certificate -FilePath "C:\Windows\Temp\Certs-main\oc-WS0-CA.cer" -CertStoreLocation "Cert:\LocalMachine\Root\"
    Remove-Item -Path "C:\Windows\Temp\Certs-main\" -Recurse
    Remove-Item -Path "C:\Windows\Temp\cert.zip"
}

###     --- Imports WS5 CA ---      ###

$getCert = $getCert = Get-ChildItem -Path Cert:\LocalMachine\Root\ | Where-Object { $_.Thumbprint -eq "FEF90EC6012C49125EC51231EDEC038527A88DB9" }
$outPath = "C:\Windows\Temp\cert.zip"

#       --- Checks if present ---
if ($getCert) {
    exit
} 
#       --- Download and import WS5 CA ---
else {
    $token = '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'
    Invoke-WebRequest -Headers @{Authorization = "token $($token)"} -Uri "https://github.com/oc-software/Certs/archive/refs/heads/main.zip" -OutFile $outPath
    Expand-Archive -Path $outPath -DestinationPath "C:\Windows\Temp\"
    Import-Certificate -FilePath "C:\Windows\Temp\Certs-main\oc-WS5-CA.cer" -CertStoreLocation "Cert:\LocalMachine\Root\"
    Remove-Item -Path "C:\Windows\Temp\Certs-main\" -Recurse
    Remove-Item -Path $outPath
}

####        --- Install SentinelOne - This will cause a forced reboot ---

#       --- Checks if installed ---
$service = Get-Service -DisplayName "Sentinel*"
if ($service.Status -eq 'Running') {
    Write-Host "S1 agent already installed!"
} 
elseif ($service.Status -eq 'Stopped') {
    $service | Start-Service
    Write-Host "S1 agent already installed, starting service..."
}
#       --- Installs S1 agent --- 
else {
    $wc = New-Object System.Net.WebClient
    $url = "https://oc-public-software.s3.us-west-2.amazonaws.com/Windows/SentinelInstaller_windows_64bit_v21_6_6_1200.msi"
    $outPath = "C:\Windows\Temp\SentinelInstaller_windows_64bit_v21_6_6_1200.msi"
    $wc.DownloadFile("$url", "$outPath")
    Start-Process msiexec.exe -ArgumentList '/i "C:\Windows\Temp\SentinelInstaller_windows_64bit_v21_6_6_1200.msi" SITE_TOKEN=eyJ1cmwiOiAiaHR0cHM6Ly91c2VhMS1lc2VudGlyZS5zZW50aW5lbG9uZS5uZXQiLCAic2l0ZV9rZXkiOiAiYzE3NjIxM2EyM2E0N2FlZCJ9 /quiet'
}
