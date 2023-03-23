#This Elevates the script
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
    if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
         $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
         Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
         Exit
        }
       }

#Sets reset value for future use
$RES = 0
#Writes "TPM Clearer to screen"
Write-Host "TPM Clearer"

#This line gets the user account and logs them out
Get-ItemProperty -Path "C:\Users\$env:UserName\AppData\Local\Packages" | ForEach-Object {
    Remove-Item -Path "$_\Microsoft.AAD.BrokerPlugin*" -Recurse -Force | Out-Null
    } 
#This line clears TPM keys
#LINE EMPTY UNTIL TESTED OR READY TO PUSH TO CLIENT
#This block checks if TPM keys have been cleared
Get-Tpm | Out-File -FilePath .\TPMCHECK.txt
$SEL = Select-String -path .\TPMCHECK.txt -Pattern 'RestartPending            : True'
if ($null -ne $SEL)
{
    $RES = 1
} else {
    $RES = 0
}
#This restarts the computer if the TPM was cleared
if ($RES == $1)
{
    Restart-Computer
} else {
    Write-Host "TPM not cleared. Please clear manually or run script again!"
    Start-Sleep -seconds 2.5
    exit
}
