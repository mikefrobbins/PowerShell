#Requires -Version 3.0 -Modules Pester
function Test-MrVMBackupRequirement {

<#
.SYNOPSIS
    Tests the requirements for live backups of a Hyper-V Guest VM for use with Altaro VMBackup.
 
.DESCRIPTION
    Test the requirements for live backups of a Hyper-V Guest VM as defined in this Altaro support article:
    http://support.altaro.com/customer/portal/articles/808575-what-are-the-requirements-for-live-backups-of-a-hyper-v-guest-vm-.
 
.PARAMETER ComputerName
    Name of the Hyper-V host virtualization server that the specified VM's are running on.

.PARAMETER VMHost
    Name of the VM (Guest) server to test the requirements for.

.PARAMETER Credential
    Specifies a user account that has permission to perform this action. The default is the current user.
 
.EXAMPLE
     Test-MrVMBackupRequirement -ComputerName HyperVServer01 -VMName VM01, VCM02 -Credential (Get-Credential)

.INPUTS
    String
 
.OUTPUTS
    None
 
.NOTES
    Author:  Mike F Robbins
    Website: http://mikefrobbins.com
    Twitter: @mikefrobbins
#>

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
                        Get-WmiObject -Class Win32_OperatingSystem -Property Caption
                    }).caption

                    ($SupportedGuestOS | ForEach-Object {$OS -like "*$_*"}) -contains $true |
                    Should Be $true
                }
                
                $VMInfo = Invoke-Command -Session $HostSession {
                    Get-VM -Name $Using:VM | Select-Object -Property IntegrationServicesState, State
                }

                It 'Should have the latest Integration Services version installed' {
                    ($VMInfo).IntegrationServicesState -eq 'Up to date' |
                    Should Be $true
                }

                It 'Should have Backup (volume snapshot) enabled in the Hyper-V settings' {
                    (Invoke-Command -Session $HostSession {
                        Get-VM -Name $Using:VM | Get-VMIntegrationService -Name VSS | Select-Object -Property Enabled
                    }).enabled |
                    Should Be $true
                }

                It 'Should be running' {
                    ($VMInfo).State |
                    Should Be 'Running'
                }

                $GuestDiskInfo = Invoke-Command -Session $GuestSession {
                    Get-WMIObject -Class Win32_Volume -Filter 'DriveType = 3' -Property Capacity, FileSystem, FreeSpace, Label
                }

                It 'Should have at least 10% free disk space on all disks' {
                    $GuestDiskInfo | ForEach-Object {$_.FreeSpace / $_.Capacity * 100} |
                    Should BeGreaterThan 10
                }
        
                $GuestServiceInfo = Invoke-Command -Session $GuestSession {
                    Get-Service -DisplayName 'Hyper-V Volume Shadow Copy Requestor', 'Volume Shadow Copy', 'COM+ Event System',
                                             'Distributed Transaction Coordinator', 'Remote Procedure Call (RPC)', 'System Event Notification Service'
                }

                It 'Should be running the "Hyper-V Volume Shadow Copy Requestor" service on the guest' {
                    ($GuestServiceInfo |
                     Where-Object DisplayName -eq 'Hyper-V Volume Shadow Copy Requestor'
                    ).status |
                    Should Be 'Running'
                }
        
                It 'Should have snapshot file location for VM set to same location as VM VHD file' {
                    #Hyper-V on Windows Server 2008 R2 and higher: The .AVHD file is always created in the same location as its parent virtual hard disk.
                    $HostOS = (Invoke-Command -Session $HostSession {
                        Get-WmiObject -Class Win32_OperatingSystem -Property Version
                    }).version
            
                    [Version]$HostOS -gt [Version]'6.1.7600' |
                    Should Be $true
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
                    Invoke-Command -Session $GuestSession {
                        $Results = vssadmin.exe list shadowstorage | Select-String -SimpleMatch 'For Volume', 'Shadow Copy Storage volume'
                        if ($Results) {
                            ($Results[0] -split 'volume:')[1].trim() -eq ($Results[1] -split 'volume:')[1].trim()                        
                        }
                        else {
                            $true
                        }                 
                    } |
                    Should Be $true                    
                }

                It 'Should not have any App-V drives installed on the VM' {
                    #App-V drives installed on the VM creates a non-NTFS volume.
                    ($GuestDiskInfo).filesystem |
                    Should Be 'NTFS'
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

                It 'Should have volume containing VHD files formated with NTFS' {
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
                        Get-WmiObject -Class Win32_DiskPartition -Property Type |
                        ForEach-Object {$DynamicDisk -contains $_.Type}
                    } |
                    Should Be $false
                }

                It 'Should be running specific services within the VM' {
                    $RunningServices = 'COM+ Event System', 'Distributed Transaction Coordinator', 'Remote Procedure Call (RPC)', 'System Event Notification Service'
                    ($GuestServiceInfo | Where-Object DisplayName -in $RunningServices).status |
                    Should Be 'Running'
                }

                It 'Should have specific services set to manual or automatic within the VM' {
                    $StartMode = (Invoke-Command -Session $GuestSession {
                            Get-WmiObject -Class Win32_Service -Filter "DisplayName = 'COM+ System Application' or DisplayName = 'Microsoft Software Shadow Copy Provider' or DisplayName = 'Volume Shadow Copy'"
                    }).StartMode
                    
                    $StartMode -eq 'Manual' -or $StartMode -eq 'Automatic' |
                    Should Be $true
                    
                }

                Remove-PSSession -Session $GuestSession
    
            }
        
        }
            
    }

    END {
        Remove-PSSession -Session $HostSession
    }

}