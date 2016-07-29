#Requires -Version 3.0 -Modules Pester
function Test-MrVMBackupRequirement {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [Alias('VMHost')]
        [string]$ComputerName,

        [Parameter(Mandatory,
            ValueFromPipeline)]
        [string[]]$VMName,

        [System.Management.Automation.Credential()]$Credential = [System.Management.Automation.PSCredential]::Empty
    )

    BEGIN {
        try {
            $HostSession = New-PSSession -ComputerName $ComputerName -Credential $Credential -ErrorAction Stop
        }
        catch {
            Throw "Unable to connect to Hyper-V host '$ComputerName'. Aborting Pester tests."
        } 
    }
    
    PROCESS {
        foreach ($VM in $VMName) {

            Describe "Validation of Altaro VM Backup Requirements for Live Backups of Hyper-V Guest VM: '$VM'" {

                try {
                    $GuestSession = New-PSSession -ComputerName $VM -Credential $Credential -ErrorAction Stop
                }
                catch {
                    Write-Warning -Message "Unable to connect. Aborting Pester tests for computer: '$VM'."
                    Continue
                } 
        
                $SupportedGuestOS = '2008 R2', 'Server 2012', 'Server 2012 R2'

                It "Should be running one of the supported guest OS's ($($SupportedGuestOS -join ', '))" {
                    $OS = (Invoke-Command -Session $GuestSession {
                        Get-WmiObject -Class Win32_OperatingSystem |
                        Select-Object -Property Caption
                    }).caption 
            
                    ($SupportedGuestOS | ForEach-Object {$OS -like "*$_*"}) -contains $true |
                    Should Be $true
                }
        
                It 'Should have the latest Integration Services version installed' {
                    Invoke-Command -Session $HostSession {
                        (Get-VM -Name $Using:VM).IntegrationServicesState -eq 'Up to date'
                    } |
                    Should Be $true
                }

                It 'Should have Backup (volume snapshot) enabled in the Hyper-V settings' {
                    Invoke-Command -Session $HostSession {
                        (Get-VM -Name $Using:VM | Get-VMIntegrationService -Name VSS).Enabled
                    } |
                    Should Be $true
                }

                It 'Should be running' {
                    (Invoke-Command -Session $HostSession {
                        Get-VM -Name $Using:VM
                    }).State |
                    Should Be 'Running'
                }

                $GuestDiskInfo = Invoke-Command -Session $GuestSession {
                    Get-WMIObject -Class Win32_Volume -Filter 'DriveType = 3' -Property Capacity, FileSystem, FreeSpace, Label
                }

                It 'Should have at least 10% free disk space on all disks' {
                    ($GuestDiskInfo |
                    Select-Object -Property @{label='PercentFree';expression={$_.FreeSpace / $_.Capacity * 100 -as [int]}}).percentfree |
                    Should BeGreaterThan 10 
                }
        
                $GuestServiceInfo = Invoke-Command -Session $GuestSession {
                    Get-Service -DisplayName 'Hyper-V Volume Shadow Copy Requestor', 'COM+ Event System', 'Distributed Transaction Coordinator', 'Remote Procedure Call (RPC)',
                                             'System Event Notification Service', 'COM+ System Application', 'Microsoft Software Shadow Copy Provider', 'Volume Shadow Copy'
                }

                It 'Should be running the "Hyper-V Volume Shadow Copy Requestor" service on the guest' {
                    ($GuestServiceInfo |
                     Where-Object DisplayName -eq 'Hyper-V Volume Shadow Copy Requestor'
                    ).status |
                    Should Be 'Running'
                }
        
                It 'Should have snapshot file location for VM set to same location as VM VHD file' {
            
                }

                It 'Should be running VSS in the guest OS' {
                    ($GuestServiceInfo |
                     Where-Object Name -eq VSS
                    ).status |
                    Should Be 'Running'
                }
        
                It 'Should have a SCSI controller attached in the VM settings' {
                    Invoke-Command -Session $HostSession {
                        Get-VM -Name $Using:VM | Get-VMScsiController
                    } |
                    Should Be $true
                }
        
                It 'Should not have an explicit shadow storage assignment of a volume other than itself' {
        
                }

                It 'Should not have any App-V drives installed on the VM' {
        
                }

                It 'Should have at least 45MB of free space on system reserved partition if one exists in the guest OS' {
                    ($GuestDiskInfo |
                    Where-Object Label -eq 'System Reserved').freespace / 1MB |
                    Should BeGreaterThan 45 
                }
        
                It 'Should have all volumes formated with NTFS in the guest OS' {
                    ($GuestDiskInfo).filesystem |
                    Should Be 'NTFS'
                }
        
                It 'Should have volume containing VHD formated with NTFS' {
                    $HostDiskLetter = (Invoke-Command -Session $HostSession {
                        Get-VM -Name $Using:VM | Get-VMHardDiskDrive
                    }).path -replace '\\.*$'
            
                    $HostDiskInfo = Invoke-Command -Session $HostSession {
                        Get-WMIObject -Class Win32_Volume -Filter 'DriveType = 3' -Property Capacity, DriveLetter, FileSystem, FreeSpace, Label            
                    }

                    ($HostDiskLetter | ForEach-Object {$HostDiskInfo | Where-Object DriveLetter -eq $_}).filesystem |
                    Should Be 'NTFS'
                }

                It 'Should only contain basic and not dynamic disks in the guest OS' {
                    Invoke-Command -Session $GuestSession {
                        $DynamicDisk = 'Logical Disk Manager', 'GPT: Logical Disk Manager Data' 
                        Get-WmiObject -Class win32_DiskPartition -Property Type |
                        ForEach-Object {$DynamicDisk -contains $_.Type}
                    } |
                    Should Be $false
                }

                Remove-PSSession -Session $GuestSession
    
            }
        
        }
            
    }

    END {
        Remove-PSSession -Session $HostSession
    }

}