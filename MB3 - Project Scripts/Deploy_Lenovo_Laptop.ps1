## Removal Of Lenovo McAfee - Uninstall Script

$app = Get-WmiObject -Class Win32_Product | Where-Object { 
    $_.Name -match "McAfee LiveSafe" 
}

$app.Uninstall()