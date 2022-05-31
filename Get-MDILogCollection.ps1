function Get-MDILogCollection {
    <#
        .SYNOPSIS
            Collect Defender for Identity logs

        .DESCRIPTION
            Collect Defender for Identity logs

        .PARAMETER InstallPath
            Default install location for Defender for Identity

        .PARAMETER LogFile
            Output logging file

        .PARAMETER Logging
            Enable logging

        .PARAMETER OutputDirectory
            Save location for the data collection

        .PARAMETER TempDirectory
            Temp copy location for in use files so they can be archived

        .PARAMETER ZippedLogCollection
            Name of compressed collection

        .EXAMPLE
            Get-MDILogCollection

                Will collect all of the Intune client side logs, event logs, registry information and compress them to a zip file

        .EXAMPLE
            Get-MDILogCollection -Logging

                Will collect all of the Defender for Identity logs and compress them to a zip file for review as well as save logging of the script execution

        .EXAMPLE
            Get-MDILogCollection -LogFile "<DriveLetter>:\YourSaveLocation"

                Will collect all of the Defender for Identity logs and compress them to a zip file for review as well as save logging to a custom save location

        .NOTES
            None
    #>

    [CmdletBinding()]
    [OutputType('System.String')]
    param(
        [string]
        $InstallPath = "C:\Program Files\Azure Advanced Threat Protection Sensor",

        [string]
        $LogFile = "C:\MDILogs\CollectionTranscript.txt",

        [switch]
        $Logging,

        [string]
        $OutputDirectory = "c:\MDILogs",

        [string]
        $TempDirectory = "c:\MDILogs\Temp",

        [string]
        $ZippedLogCollection = "MDILogs.zip"
    )

    begin {
        Write-Output "Starting data collection"
        if ($Logging.IsPresent) { Start-Transcript -Path $LogFile }
    }

    process {
        $directories = @($OutputDirectory, $TempDirectory)
        foreach ($directory in $directories) {
            if (-NOT (Test-Path -Path $directory)) {
                Write-Verbose "Directory not found! Creating directory: $directory"
                try {
                    $null = New-Item -Path $directory -ItemType Directory -ErrorAction Stop
                }
                catch {
                    $_
                    return
                }
            }
            else {
                Write-Verbose -Message "Directory: $directory already exists"
            }
        }

        try {
            # Set the location so we can remove the files
            Set-Location $OutputDirectory

            Write-Verbose -Message "Checking for Defender for Identity sensor versions"
            $directories = Get-ChildItem -Path $InstallPath
            foreach ($directory in $directories) { $null = New-Item -Path $TempDirectory\$directory -ItemType Directory -ErrorAction SilentlyContinue }

            foreach ($item in @("*.log", "*.config")) {
                $filesFound = Get-ChildItem -Path $InstallPath -Recurse -Filter $item -ErrorAction SilentlyContinue
                Write-Verbose -Message "Checking for Defender for Identity file types: $($item)"
                foreach ($file in $filesFound) {
                    $null = $file.DirectoryName -match '\d{1,}\.\d{1,}.\d{1,}.\d{1,}'
                    $null = Copy-Item -Path "$($file.DirectoryName)\$($file.Name)" -Destination (Join-Path -Path $TempDirectory -ChildPath $matches[0]) -Force -Recurse -ErrorAction SilentlyContinue
                }
                Write-Verbose -Message "Copied $($filesFound.Count) files to $($TempDirectory) successful!"
            }
        }
        catch {
            Write-Output "$_"
        }

        # Compress all needed archives in to one archive
        try {
            Write-Verbose "Compressing entire collection into $($OutputDirectory)\$ZippedLogCollection"
            $compressionCollection = @{
                Path             = "$TempDirectory\*.*"
                CompressionLevel = "Fastest"
                DestinationPath  = "$OutputDirectory\$ZippedLogCollection"
            }
            Compress-Archive @compressionCollection -Update
        }
        catch {
            Write-Output "$_"
            return
        }

        # Cleanup
        try {
            Write-Verbose "Starting cleanup. Removing $TempDirectory and all temp items"
            Remove-Item -Path $TempDirectory -Force -Recurse -ErrorAction SilentlyContinue
        }
        catch { Write-Output "$_" }
    }

    end {
        if ($Logging.IsPresent) { Stop-Transcript }
        Write-Output "Data collection completed!"
    }
}