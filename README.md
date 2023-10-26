# Chocolatey-Package-Updater

![Chocolatey Package Updater screenshot](https://github.com/asheroto/Chocolatey-Package-Updater/assets/49938263/cbcb42cb-08d1-4b2f-9e15-51df062da47b)

[![GitHub Release Date - Published_At](https://img.shields.io/github/release-date/asheroto/Chocolatey-Package-Updater)](https://github.com/asheroto/Chocolatey-Package-Updater/releases)
[![GitHub Downloads - All Releases](https://img.shields.io/github/downloads/asheroto/Chocolatey-Package-Updater/total)](https://github.com/asheroto/Chocolatey-Package-Updater/releases)
[![GitHub Sponsor](https://img.shields.io/github/sponsors/asheroto?label=Sponsor&logo=GitHub)](https://github.com/sponsors/asheroto)
<a href="https://ko-fi.com/asheroto"><img src="https://ko-fi.com/img/githubbutton_sm.svg" alt="Ko-Fi Button" height="20px"></a>

**Brand new and under development but is currently working! 😊**

`Chocolatey-Package-Updater` is a PowerShell script designed to automate the update of a [Chocolatey](https://chocolatey.org) package's version and checksum, as well as send an alert to the maintainer for review.

`UpdateFunctions.ps1` can be placed anywhere, but ideally at the root of you Chocolatey packages repository, with your packages being subfolders underneath. Then you can dot-source this script to access the function `UpdateChocolateyPackage`.

## Inspiration

Thie package was inspired by the [Chocolatey Automatic Package Updater Module](https://github.com/majkinetor/au) but that project is no longer maintained and I wanted to create something that was more lightweight and easier to use. The goal is to make it as easy as possible to update your Chocolatey packages without having to write regex or much more than a few lines of code.

## Features

**ALERT NOTE:** Right now alerting is in still a work in progress and won't work. I'm working on adding native support for other services. You can use $Alert = false to disable alerting for now or update the `SendAlertRaw` function to use your own service.

The `UpdateChocolateyPackage` function provides the following features:

-   **No functions or regex expressions to write: everything happens _automatically_!**
-   Updates the version in the nuspec file.
-   Updates the url/checksum and url64/checksum64 (if specified) in the `ChocolateyInstall.ps1` script.
-   Updates the checksum and checksum64 (if specified) in the `VERIFICATION.txt` file (if it exists).
-   Updates the version number in the download URL (if specified).
-   Sends an alert to a designated URL.
-   Supports EXE files distributed in the package.
-   Supports variable and hash table formats for checksum in the `ChocolateyInstall.ps1` script.
-   Supports single and double quotes for checksum in the `ChocolateyInstall.ps1` script.
-   Automatic support for [aria2](https://github.com/aria2/aria2) download manager as well as `Invoke-WebRequest`.
-   Supports scraping the version number from the download URL.
-   Supports version number replacement in the download URL.
-   Supports getting the latest version from a GitHub repository.

**Note:** This is a rather new project, being born in late September 2023. There may still be some bugs. For now, check out the example packages to see how it works. Also check out the [To-Do List](#to-do-list) for upcoming features.

## Requirements

-   PowerShell 7+
-   Windows Terminal recommended but not required

## Recommended Folder Structure

The recommended folder structure matches this repository's structure. You can use this as a template for your own Chocolatey packages repository.

-   ChocolateyPackages
    -   Chocolatey-Package-Updater.ps1
    -   example-package-exe-distributed
        -   update.ps1
        -   fxsound.nuspec
        -   tools
            -   ChocolateyInstall.ps1
            -   fxsound_setup.exe
            -   VERIFICATION.txt
    -   example-package-url-url64
        -   update.ps1
        -   Miro.nuspec
        -   tools
            -   ChocolateyInstall.ps1
    -   example-package-scrape-version
        -   update.ps1
        -   StartAllBack.nuspec
        -   tools
            -   ChocolateyInstall.ps1

## Usage

### Step 1 - Create an `update.ps1` file

Match the [Recommended Folder Structure](#recommended-folder-structure) and create an `update.ps1` file in the folder of your Chocolatey package in the example).

Dot-source the `Chocolatey-Package-Updater.ps1` script to access its functions. Then call the `UpdateChocolateyPackage` function with the required parameters.

You may have to change the path to the `Chocolatey-Package-Updater.ps1` script depending on where you place it, but if you place it in the root folder as described in the and your `update.ps1` file is in a sub-folder (as described in the [Recommended Folder Structure](#recommended-folder-structure)), you can use the following code verbatim.

**Note:** The $ScriptPath variable **_must_** be defined so that the `UpdateChocolateyPackage` function can locate the package files. Whether you hard code the variable or use the code below, it's up to you.

#### Required code at the top of any `update.ps1` script

```powershell
# Set vars to the script and the parent path ($ScriptPath MUST be defined for the UpdateChocolateyPackage function to work)
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ParentPath = Split-Path -Parent $ScriptPath

# Import the UpdateChocolateyPackage function
. (Join-Path $ParentPath 'Chocolatey-Package-Updater.ps1')
```

#### Example using file distributed in package

This method corresponds to the [example-package-exe-distributed](example-package-exe-distributed) example package.

```powershell
# Create a hash table to store package information
$packageInfo = @{
    PackageName         = "fxsound"
    FileUrl             = 'https://download.fxsound.com/fxsoundlatest'   # URL to download the file from
    FileDestinationPath = '.\tools\fxsound_setup.exe'                    # Path to move/rename the temporary file to (if EXE is distributed in package
    Alert               = $true                                          # If the package is updated, send a message to the maintainer for review
}

# Call the UpdateChocolateyPackage function and pass the hash table
UpdateChocolateyPackage @packageInfo
```

#### Example using url and url64:

This method corresponds to the [example-package-url-url64](example-package-url-url64) example package.

```powershell
# Create a hash table to store package information
$packageInfo = @{
    PackageName = "miro"
    FileUrl     = 'https://desktop.miro.com/platforms/win32-x86/Miro.exe'   # URL to download the file from
    FileUrl64   = 'https://desktop.miro.com/platforms/win32/Miro.exe'       # URL to download the file from
    Alert       = $true                                                     # If the package is updated, send a message to the maintainer for review
}

# Call the UpdateChocolateyPackage function and pass the hash table
UpdateChocolateyPackage @packageInfo
```

#### Example using ScrapeUrl, ScrapePattern, FileUrl version replacement

This method corresponds to the [example-package-scrape-version](example-package-scrape-version) example package.

```powershell
# Create a hash table to store package information
$packageInfo = @{
    PackageName   = "StartAllBack"                                                                                  # Package name
    ScrapeUrl     = 'https://startallback.com/'                                                                     # URL to scrape for version number
    ScrapePattern = '(?<=<span class="title">Download v)[\d.]+'                                                     # Regex pattern to match version number
    FileUrl       = "https://startisback.sfo3.cdn.digitaloceanspaces.com/StartAllBack_{VERSION}_setup.exe"          # URL to download the file from
}

# Call the UpdateChocolateyPackage function and pass the hash table
UpdateChocolateyPackage @packageInfo
```

#### Example using GitHub release

This method corresponds to the [example-package-github-repo](example-package-github-repo) example package.

```powershell
# Create a hash table to store package information
$packageInfo = @{
    PackageName   = "ventoy"
    FileUrl       = "https://github.com/ventoy/Ventoy/releases/download/v{VERSION}/ventoy-{VERSION}-windows.zip"
    GitHubRepoUrl = "https://github.com/ventoy/Ventoy"
}

# Call the UpdateChocolateyPackage function and pass the hash table
UpdateChocolateyPackage @packageInfo
```

### Alternate method using named parameters

The splatting method above is recommended because it's easier to read and maintain, but if you'd rather use named parameters, you can do so like this:

```powershell
UpdateChocolateyPackage -PackageName "fxsound" -FileUrl "https://download.fxsound.com/fxsoundlatest" -FileDestinationPath ".\tools\fxsound_setup.exe" -Alert $true
```

```powershell
UpdateChocolateyPackage -PackageName "fxsound" -FileUrl "https://desktop.miro.com/platforms/win32-x86/Miro.exe" -FileUrl64 'https://desktop.miro.com/platforms/win32/Miro.exe' -Alert $true
```

```powershell
UpdateChocolateyPackage -PackageName "StartAllBack" -ScrapeUrl 'https://startallback.com/' -ScrapePattern '(?<=<span class="title">Download v)[\d.]+' -FileUrl "https://startisback.sfo3.cdn.digitaloceanspaces.com/StartAllBack_{VERSION}_setup.exe"
```

```powershell
UpdateChocolateyPackage -PackageName "ventoy" -FileUrl "https://github.com/ventoy/Ventoy/releases/download/v{VERSION}/ventoy-{VERSION}-windows.zip" -GitHubRepoUrl "https://github.com/ventoy/Ventoy"
```

---

### Step 2 - Schedule the PowerShell Script

You can use Windows Task Scheduler to schedule the `update.ps1` script to run automatically. It is recommended that you create an `UpdateAll.ps1` script in the same folder as `Chocolatey-Package-Updater.ps1` and schedule that script to run. See the [UpdateAll.ps1](UpdateAll.ps1) script in this repository for an example.

In Task Scheduler, create a new Task (not basic) and set the `Action` to the following:

```powershell
pwsh -Command "& 'YOUR_SCRIPT_PATH_HERE'"
```

for example

```powershell
pwsh -Command "& 'C:\Projects\ChocolateyPackages\UpdateAll.ps1'"
```

or if you don't want to use the `UpdateAll.ps1` script, you can use the `update.ps1` script of the package directly:

```powershell
pwsh -Command "& 'C:\Projects\ChocolateyPackages\fxsound\update.ps1'"
```

**Recommended options:**

-   `Run with the highest privileges`
    -   To avoid permission issues
-   `Run whether user is logged in or not`
    -   Will make the script run behind-the-scenes as well as hide the window. If you'd rather not use this, you can use my tool [SpawnProcess](https://github.com/asheroto/SpawnProcess) and use `SpawnProcess.exe` or `SpawnProcessHidden.exe` which will launch a hidden. [Example usage](https://github.com/asheroto/SpawnProcess#spawnprocesshidden-example-such-as-from-task-scheduler-example).
-   Schedule as often as you'd like, usually weekly or daily. Recommended twice a week, not more than once per day.
-   Consider changing the power/battery options in the `Conditions` tab.

## Full Examples

| Package                                        | Description                                                                                                                                     |
| ---------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| [fxsound](example-package-exe-distributed)     | Uses `FileUrl` and `FileDestinationPath` for distributing EXE within package                                                                    |
| [Miro](example-package-url-url64)              | Uses `FileUrl` and `FileUrl64` for updating a package with both 32/64-bit EXEs                                                                  |
| [StartAllBack](example-package-scrape-version) | Uses `ScrapePattern`, `ScrapeUrl`, and `FileUrl` for scraping version number from a URL, uses `{VERSION}` in FileUrl to be replaced by scraping |

## Function Parameters for `UpdateChocolateyPackage`

| Parameter                 | Type    | Required                                                                 | Description                                                                                                                                                             |
| ------------------------- | ------- | ------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `-PackageName`            | string  | Yes                                                                      | The name of the package.                                                                                                                                                |
| `-FileUrl`                | string  | Yes                                                                      | The URL to download the file from. If you're using `ScrapeUrl` and `ScrapePattern` you can specify `{VERSION}` in the `FileUrl` and it will download from that FileUrl. |
| `-FileUrl64`              | string  | Yes                                                                      | The URL to download the file from.                                                                                                                                      |
| `-FileDestinationPath`    | string  | Only required if EXE distributed in package                              | Absolute/relative path to move/rename the temporary file to (if EXE is distributed in package).                                                                         |
| `-FileDestinationPath64`  | string  | Only required if url and url64 is used and EXE is distributed in package | Absolute/relative path to move/rename the temporary file to (if EXE is distributed in package).                                                                         |
| `-GitHubRepoUrl`          | string  | No                                                                       | The URL to the GitHub repository. If specified, the latest release will be downloaded using `{VERSION}` replacement in the `FileUrl`.                                   |
| `-ScrapeUrl`              | string  | No                                                                       | If the version number is not available in the download URL, you can specify a URL to scrape the version number from.                                                    |
| `-ScrapePattern`          | string  | No                                                                       | The regex pattern to use when scraping the version number from the scrape URL.                                                                                          |
| `-Alert`                  | boolean | No                                                                       | If the package is updated, send a message to the maintainer for review                                                                                                  |
| `-NuspecPath`             | string  | No                                                                       | **Use not recommended. Recommended using default Choco paths.** Absolute/relative path to the nuspec file                                                               |
| `-InstallScriptPath`      | string  | No                                                                       | **Use not recommended. Recommended using default Choco paths.** Absolute/relative path to the `ChocolateyInstall.ps1` script                                            |
| `-VerificationPath`       | string  | No                                                                       | **Use not recommended. Recommended using default Choco paths.** Absolute/relative path to the `VERIFICATION.txt` file                                                   |
| `-FileDownloadTempPath`   | string  | No                                                                       | **Use not recommended. Recommended using default paths.**Absolute/relative path to save the file to                                                                     |
| `-FileDownloadTempPath64` | string  | No                                                                       | **Use not recommended. Recommended using default paths.**Absolute/relative path to save the file to                                                                     |

`-ScrapeUrl64` and `-ScrapePattern64` are not options because the version number should be the same regardless of architecture.

## Script Parameters

If you add these two lines to the _very top_ of your `update.ps1` script, you can then use the `-Debug` or `-Verbose` parameters when calling the script and it will give you **much more** information about what it's doing.

```powershell
[CmdletBinding()] # Enables -Debug parameter for troubleshooting
param ()
```

<details><summary>Screenshot of -Debug output</summary>
<p>
<img src="https://github.com/asheroto/Chocolatey-Package-Updater/assets/49938263/aaf9d230-b1cd-4879-8cef-66b7a23e0a26" alt="-Debug output">
</p>
</details>

## FAQ

-   Do I need to use the `VERIFICATION.txt` file?
    -   No, it's optional unless you are distributing an EXE with the package (if EULA allows it). If you don't use it, just leave the parameter blank or comment it out.
-   Can I use [ntfy.sh](https://github.com/binwiederhier/ntfy), Discord, Telegram, PagerDuty, Twilio, or some other service to alert me?
    -   Yes!.... but since this script is new I haven't built in native support for other services yet, so you'll have to update the `SendAlertRaw` function.
    -   If you aren't sure what to change, ChatGPT is a good place to start.
    -   [ntfy](https://github.com/binwiederhier/ntfy) is cool because once you get it setup, it integrates with many services. So in theory you could use ntfy to send a message to Discord, Telegram, PagerDuty, Twilio, and more.
    -   I am working on adding native support for other services.
-   How much development is going into this?
    -   I'm currently focused on multiple projects, but I'll definitely consider dedicating more time to this one based on community interest.
    -   If you find it useful or promising, please click the **Star** button at the top right which serves as an indicator for me to continue its development.
    -   Subscribe to release notifications by going to Watch → Custom → Releases → Apply
    -   Thank you for your support!

## To-Do List

-   Add `UpdateSelf` function
-   Add `ntfy.sh` support
-   Add to PowerShell Gallery
-   Add script to Chocolatey as a package
-   Add more examples
-   Improve output/debug
-   Support alternate checksum/checksum64 specification in `VERIFICATION.txt` file (right now it expects `checksum:` and `checksum64:`)
-   Add check for missing nuspec