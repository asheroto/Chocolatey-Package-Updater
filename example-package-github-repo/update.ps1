[CmdletBinding()] # Enables -Debug parameter for troubleshooting
param ()

# Set vars to the script and the parent path
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ParentPath = Split-Path -Parent $ScriptPath

# Import the UpdateChocolateyPackage function
. (Join-Path $ParentPath 'Chocolatey-Package-Updater.ps1')

# Create a hash table to store package information
$packageInfo = @{
    PackageName   = "ventoy"                                                                                        # Package name
    FileUrl       = "https://github.com/ventoy/Ventoy/releases/download/v{VERSION}/ventoy-{VERSION}-windows.zip"    # URL to download the file from, using {VERSION} where the version number goes
    GitHubRepoUrl = "https://github.com/ventoy/Ventoy"                                                              # GitHub repository URL
    AutoPush      = $true                                                                                           # Automatically push the package to the Chocolatey community repository
    EnvFilePath   = "..\.env"                                                                                       # Path to the .env file for alerting
}

# Call the UpdateChocolateyPackage function and pass the hash table
UpdateChocolateyPackage @packageInfo