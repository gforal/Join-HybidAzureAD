<#
    
    Author:  Graham Foral
    Date:    10/10/2022

    .SYNOPSIS
    To provide a way to spam your way to a Hybrid Azure Join. :)

    .PARAMETER Iterations
    Number of times you wish to try to force join to AAD
    
    .PARAMETER WaitTime
    Time in seconds to wait before trying again.
    
    .PARAMETER logFile
    Path to the PowerShell transcript you wish. Default is current directory


#>


Param(
    [int32]$Iterations = 1, # Number of times to cycle through trying to join HAAD
    [int32]$WaitTime = 5,
    $LogFile = "$CurrentDir\PersistentHAADJoin.log"
)


$i = 0
$CurrentDir = Split-Path $MyInvocation.MyCommand.Path

Start-Transcript -Path $LogFile -Append

Write-Host "DEBUG " -ForegroundColor Green -NoNewline
Write-Host "Iterations Selected: `t$Iterations"

Write-Host "DEBUG " -ForegroundColor Green -NoNewline
Write-Host "Wait Selected: `t`t$WaitTime (Seconds)"

Write-Host "DEBUG " -ForegroundColor Green -NoNewline
Write-Host "Date: `t`t`t`t$(Get-Date -DisplayHint DateTime)"

Write-Host "DEBUG " -ForegroundColor Green -NoNewline
Write-Host "Path: `t`t`t`t$CurrentDir"

Write-Host "DEBUG " -ForegroundColor Green -NoNewline
Write-Host "Log File: `t`t`t$LogFile"

Write-Host "`n---------------------------`n"



While ($i -lt $Iterations) {
    $RawStatus = Invoke-Expression -Command "dsregcmd.exe /status"
    $ResultantStatus = ($RawStatus | Select-String "IsDeviceJoined").ToString().Replace("IsDeviceJoined:", "")
    $ResultantStatus = ($ResultantStatus.Replace(" ", "") -split ":")[1]

    If ($ResultantStatus -eq "NO") {
        Write-Host "Information: " -ForegroundColor Green -NoNewline
        Write-Host "As of $(Get-Date -DisplayHint DateTime), the system is not AAD-joined. Attempting to join..."
        Start-Process -FilePath "dsregcmd.exe" -ArgumentList "/join /debug" -Wait -NoNewWindow
        Start-Sleep -Seconds $WaitTime
        $i = $i + 1
    }
    else {}

    If ($ResultantStatus -eq "YES") {
        Write-Host "Information: " -ForegroundColor Green -NoNewline
        Write-Host "As of $(Get-Date -DisplayHint DateTime), the system is AAD-joined. The script will exit"
        Break            
    }
    else {}

    
    Write-Host "Information: " -ForegroundColor Green -NoNewline
    Write-Host "Script is on cycle $i"
}

Stop-Transcript
