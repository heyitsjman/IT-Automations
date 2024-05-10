# Get all local printer queues
$printers = Get-WmiObject -Query "SELECT * FROM Win32_Printer WHERE Local='True'"

# Iterate through each printer queue and clear it
foreach ($printer in $printers) {
    Write-Host "Clearing printer queue for $($printer.Name)..."
    Get-WmiObject -Query "SELECT * FROM Win32_PrintJob WHERE Name LIKE '%$($printer.Name)%'" | ForEach-Object {
        $_.Delete()
    }
}

Write-Host "All local printer queues cleared successfully."
