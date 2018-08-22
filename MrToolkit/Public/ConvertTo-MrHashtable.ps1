function ConvertTo-MrHashTable {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,
                   ValueFromPipeline)]
        [PSObject[]]$Object
    )
    PROCESS {
        foreach ($o in $Object) {
            $hashtable = @{}
            
            foreach ($p in Get-Member -InputObject $o -MemberType Property) {
                $hashtable.($p.Name) = $o.($p.Name)
            }

            Write-Output $hashtable
        }
    }
}