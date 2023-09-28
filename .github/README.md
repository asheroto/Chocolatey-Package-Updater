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
-   Automatic support for [aria2](https://github.com/aria2/aria2) download manager as well as `Invoke-WebRequest`.

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

## Recommended Folder Structure

-   Root Folder
    -   Chocolatey-Package-Updater.ps1
    -   example-package
        -   update.ps1
        -   fxsound.nuspec
        -   tools
            -   ChocolateyInstall.ps1
            -   fxsound_setup.exe
            -   legal
                -   VERIFICATION.txt
    -   another-package
        -   update.ps1
        -   another.nuspec
        -   tools
            -   ChocolateyInstall.ps1
            -   another_setup.exe
            -   legal
                -   VERIFICATION.txt

## Usage

Don't worry, it's not hard! There's a [full example](example-package) available on this repo in case you get stuck.

### Step 1 - Dot-Source the Functions

Dot-source the `Chocolatey-Package-Updater.ps1` script to access its functions. Then call the `UpdateChocolateyPackage` function with the required parameters.

You may have to change the path to the `Chocolatey-Package-Updater.ps1` script depending on where you place it, but if you place it in the root folder as described in the and your `update.ps1` file is in a sub-folder (as described in the [Recommended Folder Structure](#recommended-folder-structure)), you can use the following code verbatim.

```powershell
# Remember current directory
Push-Location

# Change to the directory of this script
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
Set-Location $scriptPath

# Imports the Chocolatey-Package-Updater functions
. ..\Chocolatey-Package-Updater.ps1
```

You can call the `UpdateChocolateyPackage` function with either **named parameters** or **splatting** (similar to what many `ChocolateyInstall.ps1` packages do).

---

### Step 2 (option #1) - Update Using Named Parameters

```powershell
UpdateChocolateyPackage -PackageName "fxsound" -FileUrl "https://download.fxsound.com/fxsoundlatest" -FileDownloadTempPath ".\fxsound_setup_temp.exe" -FileDestinationPath ".\tools\fxsound_setup.exe" -NuspecPath ".\fxsound.nuspec" -InstallScriptPath ".\tools\ChocolateyInstall.ps1" -VerificationPath ".\tools\legal\VERIFICATION.txt" -Alert $true

# Return to the original directory (if you used Push-Location at the beginning)
Pop-Location
```

The command above does the same thing as the command below, it's just a different way to issue the update command.

### Step 2 (option #2) - Update Using Splatting (Hash Table)

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

# Return to the original directory (if you used Push-Location at the beginning)
Pop-Location
```

---

### Step 3 - Schedule the PowerShell Script

In Task Scheduler, create a new Task (not basic) and set the `Action` to the following:

```powershell
pwsh -Command "& 'YOUR_SCRIPT_PATH_HERE'"
```

for example

```powershell
pwsh -Command "& 'C:\Projects\ChocolateyPackages\fxsound\update.ps1'"
```

**Recommended options:**

-   `Run with the highest privileges`
    -   To avoid permission issues
-   `Run whether user is logged in or not`
    -   Will make the script run behind-the-scenes as well as hide the window. If you'd rather not use this, you can use my tool [SpawnProcess](https://github.com/asheroto/SpawnProcess) and use `SpawnProcess.exe` or `SpawnProcessHidden.exe` which will launch a hidden. [Example usage](https://github.com/asheroto/SpawnProcess#spawnprocesshidden-example-such-as-from-task-scheduler-example).
-   Schedule as often as you'd like, usually weekly or daily. Recommended not more than once per day.
-   Consider changing the power/battery options in the `Conditions` tab.

## Example Chocolatey Package

Included in this repository is a real-world example using [FxSound](example-package).

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

## FAQ
- Do I need to use the `VERIFICATION.txt` file?
  - No, it's optional unless you are distributing an EXE with the package (if EULA allows it). If you don't use it, just leave the parameter blank or comment it out.
- Can I use [ntfy.sh](https://github.com/binwiederhier/ntfy), Discord, Telegram, PagerDuty, Twilio, or some other service to alert me?
  - Yes!.... but since this script is new I haven't built in native support for other services yet, so you'll have to update the `SendAlertRaw` function.
  - If you aren't sure what to change, ChatGPT is a good place to start.
  - [ntfy](https://github.com/binwiederhier/ntfy) is cool because once you get it setup, it integrates with many services. So in theory you could use ntfy to send a message to Discord, Telegram, PagerDuty, Twilio, and more.
  - I am working on adding native support for other services.
- Do I have to use Push-Location and Pop-Location?
  - If you don't want to use these then you will need either:
    - Use absolute paths with each file for all parameters.
    - or use the "Working Directory" argument when launching the script so that PowerShell knows where to look for relative paths.
- How much development is going into this?
  - I'm currently focused on multiple projects, but I'll definitely consider dedicating more time to this one based on community interest.
  - If you find it useful or promising, your stars and shares will be greatly appreciated and will serve as an indicator for me to continue its development.
  - Thank you for your support!