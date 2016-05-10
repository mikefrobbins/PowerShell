#Requires -Version 4.0 -Modules Pester
function Invoke-MrTDDWorkflow {

    [CmdletBinding()]
    param (
        [ValidateScript({
          If (Test-Path -Path $_ -PathType Container) {
            $true
          }
          else {
            Throw "'$_' is not a valid directory."
          }
        })]
        [string]$Path = (Get-Location),

        [ValidateNotNullOrEmpty()]
        [int]$Seconds = 30
    )

    Add-Type -AssemblyName System.Windows.Forms
    Clear-Host

    while (-not $Complete) {       
    
        if ((Invoke-Pester -Script $Path -Quiet -PassThru -OutVariable Results).FailedCount -eq 0) {

            if ([System.Windows.Forms.MessageBox]::Show('Is the code complete?', 'Status', 4, 'Question', 'Button2') -eq 'Yes') {
                $Complete = $true
            }
            else {
                $Complete = $False
                Write-Output "Write a failing unit test for a simple feature that doesn't yet exist."
            
                if ($psISE) {
                    [System.Windows.Forms.MessageBox]::Show('Click Ok to Continue')
                }
                else {
                    Write-Output 'Press any key to continue ...'
                    $Host.UI.RawUI.ReadKey('NoEcho, IncludeKeyDown') | Out-Null
                }

                Clear-Host
            }
              
        }
        else {
            Write-Output "Write code until unit test: '$($Results.TestResult.Where({$_.Passed -eq $false}, 'First', 1).Name)' passes"
            Start-Sleep -Seconds $Seconds
            Clear-Host
        }    

    }

}