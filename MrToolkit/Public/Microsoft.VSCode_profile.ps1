$StartupVars = @()
$StartupVars = Get-Variable | Select-Object -ExpandProperty Name