<# 
Written by: Brent Kroontje

Purpose: Hard disk space on shared kiosk machines fills up quickly
         after many users have logged into it.
         This script remotely deletes user profiles on kiosk machines to clear up space

How to Use: 1. Open powershell
            2. enter command: start powershell -credential -$cred "C:\path\to\script"
            3. Username\Password dialog box: na\tildeAccount, password
            2. Enter in the name of the computer
            3. Kiosk machine will reboot to clear logged in users
            4. Script will then run through and clear all user accounts except Public, and Admin

       



#>

#mandatory parameter to take in the name of a computer
param (
    [Parameter(Mandatory=$true)]
        [String]$computer
)  

#if want to run without reboot comment out these two lines
restart-Computer $computer -Force -verbose
Start-Sleep -Seconds 60



function delete-profiles { 
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [String]$computer
    )

    #Tests connection to remote machine after reboots
    Do {
        $Ping = Test-Connection $computer -quiet
    }Until ($Ping = "True") 


    $profiles = $null

    #gets profiles to delete. 
    $profiles = Get-WMIObject -computername $computer -class Win32_UserProfile| Where {((!$_.Special) -and ($_.LocalPath -ne "C:\Users\Administrator")  -and ($_.LocalPath -ne "C:\Users\Public"))} -Verbose

    #deletes each profile
    foreach ($prof in $profiles) {
        $p = Get-WmiObject -computerName $computer -Class Win32_UserProfile | where { $_.sid -eq $prof.sid } 
        $p|Remove-WmiObject -Verbose 
    }
}

delete-profiles($computer)



