$psISE.Options.Zoom = 100
$StartupVars = @()
$StartupVars = Get-Variable | Select-Object -ExpandProperty Name
