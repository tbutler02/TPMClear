#Reset Value
$RES = 0
#Writes "TPM Clearer to screen"
Write-Host "TPM Clearer"
#This Elevates the script
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
    if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
         $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
         Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
         Exit
        }
       }
   

#This line gets the user account and logs them out
Get-ItemProperty -Path "C:\Users*\AppData\Local\Packages" | ForEach-Object {
    Remove-Item -Path "$_\Microsoft.AAD.BrokerPlugin*" -Recurse -Force | Out-Null
    } 
#This line clears TPM keys

#This block checks if TPM keys have been cleared
Get-Tpm | Out-File -FilePath .\TPMCHECK.txt
$SEL = Select-String -path .\TPMCHECK.txt -Pattern 'RestartPending            : True'
if ($SEL -ne $null)
{
    $RES = $true
}
else
{
    $RES = $false
}
#This restarts the computer if the TPM was cleared
if ($RES == $true)
{
    Restart-Computer
} else [
    Write-Host "TPM not cleared. Please clear manually or run script again!"
    Start-Sleep -seconds 2.5
    exit
]
