# Get-MDILogCollection

Collect Defender for Identity logs

> EXAMPLE 1: Get-MDILogCollection

        Will collect all of the Defender for Identity logs and compress them to a zip file

> EXAMPLE 2: Get-MDILogCollection -Logging

        Will collect all of the Defender for Identity logs and compress them to a zip file for review as well as save logging of the script execution

> EXAMPLE 3: Get-MDILogCollection -LogFile "<DriveLetter>:\YourSaveLocation"

        Will collect all of the Defender for Identity logs and compress them to a zip file for review as well as save logging to a custom save location

> For more information on MDI logs please see: https://docs.microsoft.com/en-us/defender-for-identity/troubleshooting-using-logs