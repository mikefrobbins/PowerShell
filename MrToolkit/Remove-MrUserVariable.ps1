#Requires -Version 3.0
function Remove-MrUserVariable {

<#
.SYNOPSIS
    Removes user defined variables.
 
.DESCRIPTION
    Removes user defined variables from the PowerShell ISE or console. $StartupVars must be defined prior to running
    this function, preferably in a profile script. Populate $StartUpVars with 'Get-Variable | Select-Object -ExpandProperty
    Name'. All variables added after populating $StartupVars will be removed when this function is run.
 
.EXAMPLE
     Remove-MrUserVariable

.INPUTS
    None
 
.OUTPUTS
    None
 
.NOTES
    Author:  Mike F Robbins
    Website: http://mikefrobbins.com
    Twitter: @mikefrobbins
#>

    [CmdletBinding(SupportsShouldProcess)]
    param ()

    if ($StartupVars) {
        $UserVars = Get-Variable -Exclude $StartupVars -Scope Global
        
        foreach ($var in $UserVars){
            try {
                Remove-Variable -Name $var.Name -Force -Scope Global -ErrorAction Stop
                Write-Verbose -Message "Variable '$($var.Name)' has been successfully removed."
            }
            catch {
                Write-Warning -Message "An error has occured. Error Details: $($_.Exception.Message)"
            }            
            
        }
        
    }
    else {
        Write-Warning -Message '$StartupVars has not been added to your PowerShell profile'
    }    

}