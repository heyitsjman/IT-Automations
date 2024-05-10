# Prompt the user to choose between providing a single computer name or importing a list
$choice = Read-Host -Prompt "Do you want to provide a single computer name (S) or import a list from a file (F)? [S/F]"

# If the user chooses to provide a single computer name
if ($choice -eq "S" -or $choice -eq "s") {
    $computerNames = @()
    $computerName = Read-Host -Prompt "Enter the computer name"
    $computerNames += $computerName
}
# If the user chooses to import a list from a file
elseif ($choice -eq "F" -or $choice -eq "f") {
    $filePath = Read-Host -Prompt "Enter the path to the file containing the list of computer names"
    $computerNames = Get-Content $filePath
}
else {
    Write-Host "Invalid choice. Exiting script."
    exit
}

# Define an array to store all machine information
$allMachineInfo = @()

foreach ($computerName in $computerNames) {
    # Define an array to store the machine information for each computer
    $machineInfo = @()

    # Get the IP address using WMI
    $networkConfig = Get-WmiObject Win32_NetworkAdapterConfiguration -ComputerName $computerName | Where-Object { $_.IPAddress -ne $null }
    $ipAddress = $networkConfig.IPAddress[0]

    # Get the model of the computer
    $computerSystem = Get-WmiObject Win32_ComputerSystem -ComputerName $computerName
    $model = $computerSystem.Model

    # Get the OS version
    $osVersion = (Get-WmiObject Win32_OperatingSystem -ComputerName $computerName).Version

    # Get the last logged-in user
    $lastLoggedInUser = Get-WmiObject Win32_ComputerSystem -ComputerName $computerName | Select-Object -ExpandProperty UserName

    # Get installed applications
    $installedApps = Get-WmiObject -Class Win32_Product -ComputerName $computerName | Select-Object Name

    # Get installed printers
    $installedPrinters = Get-WmiObject -Class Win32_Printer -ComputerName $computerName | Select-Object Name

    # Get system uptime
    $os = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $computerName
    $uptime = (Get-Date) - $os.ConvertToDateTime($os.LastBootUpTime)

    # Get processor information
    $processor = Get-WmiObject Win32_Processor -ComputerName $computerName | Select-Object Name, MaxClockSpeed, NumberOfCores

    # Get memory information
    $memory = Get-WmiObject Win32_PhysicalMemory -ComputerName $computerName | Measure-Object -Property Capacity -Sum
    $memoryCapacityGB = [math]::Round($memory.Sum / 1GB, 2)

    # Add the gathered information to the machineInfo array
    $machineInfo += [PSCustomObject]@{
        "MachineName" = $computerName
        "IPAddress" = $ipAddress
        "Model" = $model
        "OSVersion" = $osVersion
        "LastLoggedInUser" = $lastLoggedInUser
        "InstalledApplications" = ($installedApps | ForEach-Object { $_.Name }) -join ", "
        "InstalledPrinters" = ($installedPrinters | ForEach-Object { $_.Name }) -join ", "
        "Uptime" = $uptime.Days.ToString() + " days " + $uptime.Hours.ToString() + " hours " + $uptime.Minutes.ToString() + " minutes"
        "ProcessorName" = $processor.Name
        "ProcessorClockSpeed" = $processor.MaxClockSpeed
        "ProcessorCores" = $processor.NumberOfCores
        "MemoryCapacityGB" = $memoryCapacityGB
    }

    # Add the machineInfo array to the allMachineInfo array
    $allMachineInfo += $machineInfo
}

# Get the path to the current user's Documents folder
$documentsFolder = [Environment]::GetFolderPath("MyDocuments")

# Export the allMachineInfo array to a CSV file in the Documents folder
$allMachineInfo | Export-Csv -Path "$documentsFolder\MachineInfo.csv" -NoTypeInformation

Write-Host "Machine information exported to MachineInfo.csv"
