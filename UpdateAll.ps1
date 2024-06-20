# This script is an example of what your UpdateAll.ps1 script could look like.
# It will update all packages in the repository.

# Remember location
Push-Location

# Change to script directory
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
Set-Location $scriptPath

# Update packages
./fxsound/update.ps1
./Clickup-Official/update.ps1
./miro/update.ps1

# Return
Pop-Location