# Chocolatey-Package-Updater

![Chocolatey Package Updater screenshot](https://github.com/asheroto/Chocolatey-Package-Updater/assets/49938263/658fd110-19ac-4d9a-9807-768b11a780dc)

[![GitHub Release Date - Published_At](https://img.shields.io/github/release-date/asheroto/Chocolatey-Package-Updater)](https://github.com/asheroto/Chocolatey-Package-Updater/releases)
[![GitHub Downloads - All Releases](https://img.shields.io/github/downloads/asheroto/Chocolatey-Package-Updater/total)](https://github.com/asheroto/Chocolatey-Package-Updater/releases)
[![GitHub Sponsor](https://img.shields.io/github/sponsors/asheroto?label=Sponsor&logo=GitHub)](https://github.com/sponsors/asheroto)
<a href="https://ko-fi.com/asheroto"><img src="https://ko-fi.com/img/githubbutton_sm.svg" alt="Ko-Fi Button" height="20px"></a>

**Brand new and under development but is currently working! 😊**

`Chocolatey-Package-Updater` is a PowerShell script designed to automate the update of a [Chocolatey](https://chocolatey.org) package's version and checksum, as well as send an alert to the maintainer for review.

`UpdateFunctions.ps1` can be placed anywhere, but ideally at the root of you Chocolatey packages repository, with your packages being subfolders underneath. Then you can dot-source this script to access the function `UpdateChocolateyPackage`.

## Inspiration
Thie package was inspired by the [Chocolatey Automatic Package Updater Module](https://github.com/majkinetor/au) but that project is no longer maintained and I wanted to create something that was more lightweight and easier to use.

## Features

The `UpdateChocolateyPackage` function provides the following features:

-   Updates the version in the nuspec file.
-   Updates the checksum in the `ChocolateyInstall.ps1` script.
-   Updates the checksum in the `VERIFICATION.txt` file (if it exists).
-   Sends an alert to a designated URL.
-   Supports EXE files distributed in the package.
-   Supports variable and hash table formats for checksum in the install script.
-   Supports single and double quotes for checksum in the install script.

## How It Works

The `UpdateChocolateyPackage` function operates in the following steps:

1. Downloads the package EXE file and retrieves its product version.
2. Compares the downloaded file's version to the version specified in the nuspec file.
3. Compares the downloaded file's checksum to the checksum in the install script.
4. If the package requires an update, it performs the following actions:
    - Updates the version in the nuspec file.
    - Updates the checksum in the install script.
    - Updates the checksum in the verification file (if it exists).
    - Sends an alert to a designated URL.

## Requirements

-   PowerShell 7+
-   Windows Terminal recommended but not required

## Example Usage

You can call the `UpdateChocolateyPackage` function with either **named parameters** or **splatting** (similar to what many ChocolateyInstall.ps1 packages do).

### Using Named Parameters

```powershell
UpdateChocolateyPackage -PackageName "fxsound" -FileUrl "https://download.fxsound.com/fxsoundlatest" -FileDownloadTempPath ".\fxsound_setup_temp.exe" -FileDestinationPath ".\tools\fxsound_setup.exe" -NuspecPath ".\fxsound.nuspec" -InstallScriptPath ".\tools\ChocolateyInstall.ps1" -VerificationPath ".\tools\legal\VERIFICATION.txt" -Alert $true
```

### Using Splatting (Hash Table)

```powershell
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
```

## Example Chocolatey Package

Included in this repository is a real-world example using FxSound.

## Parameters

| Parameter                 | Required | Default | Description                                                                             |
| ------------------------- | -------- | ------- | --------------------------------------------------------------------------------------- |
| `-PackageName`            | Yes      | -       | The name of the package                                                                 |
| `-FileUrl`                | Yes      | -       | The URL to download the file from                                                       |
| `-FileDownloadTempPath`   | Yes      | -       | The path to save the file to                                                            |
| `-FileDownloadTempDelete` | No       | true    | Delete the temporary file after downloading and comparing to exiting version & checksum |
| `-FileDestinationPath`    | No       | -       | The path to move/rename the temporary file to (if EXE is distributed in package)        |
| `-NuspecPath`             | Yes      | -       | The path to the nuspec file                                                             |
| `-InstallScriptPath`      | Yes      | -       | The path to the `ChocolateyInstall.ps1` script                                          |
| `-VerificationPath`       | No       | -       | The path to the `VERIFICATION.txt` file                                                 |
| `-Alert`                  | No       | true    | If the package is updated, send a message to the maintainer for review                  |