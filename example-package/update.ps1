[CmdletBinding()] # Enables -Debug parameter for troubleshooting
param ()

# Use PowerShell 7+ to run this script

# Imports the Chocolatey-Package-Updater functions
. ..\Chocolatey-Package-Updater.ps1

# Create a hash table to store package information
$packageInfo = @{
    PackageName            = "fxsound"
    FileUrl                = 'https://download.fxsound.com/fxsoundlatest'   # URL to download the file from
    FileDownloadTempPath   = '.\fxsound_setup_temp.exe'                     # Path to save the file to
    FileDownloadTempDelete = $true                                          # Delete the temporary file after downloading and comparing to exiting version & checksum
    FileDestinationPath    = '.\tools\fxsound_setup.exe'                    # Path to move/rename the temporary file to (if EXE is distributed in package)
    NuspecPath             = '.\fxsound.nuspec'                             # Path to the nuspec file
    InstallScriptPath      = '.\tools\ChocolateyInstall.ps1'                # Path to the ChocolateyInstall.ps1 script
    VerificationPath       = '.\tools\legal\VERIFICATION.txt'               # Path to the VERIFICATION.txt file
    Alert                  = $true                                          # If the package is updated, send a message to the maintainer for review
}

# Call the UpdateChocolateyPackage function and pass the hash table
UpdateChocolateyPackage @packageInfo