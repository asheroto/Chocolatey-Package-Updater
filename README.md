# Chocolatey-Package-Updater

![Chocolatey Package Updater screenshot](https://github.com/asheroto/Chocolatey-Package-Updater/assets/49938263/cbcb42cb-08d1-4b2f-9e15-51df062da47b)

[![GitHub Release Date - Published_At](https://img.shields.io/github/release-date/asheroto/Chocolatey-Package-Updater)](https://github.com/asheroto/Chocolatey-Package-Updater/releases)
[![GitHub Downloads - All Releases](https://img.shields.io/github/downloads/asheroto/Chocolatey-Package-Updater/total)](https://github.com/asheroto/Chocolatey-Package-Updater/releases)
[![GitHub Sponsor](https://img.shields.io/github/sponsors/asheroto?label=Sponsor&logo=GitHub)](https://github.com/sponsors/asheroto?frequency=one-time&sponsor=asheroto)
<a href="https://ko-fi.com/asheroto"><img src="https://ko-fi.com/img/githubbutton_sm.svg" alt="Ko-Fi Button" height="20px"></a>
<a href="https://www.buymeacoffee.com/asheroto"><img src="https://img.buymeacoffee.com/button-api/?text=Buy me a coffee&emoji=&slug=seb6596&button_colour=FFDD00&font_colour=000000&font_family=Lato&outline_colour=000000&coffee_colour=ffffff](https://img.buymeacoffee.com/button-api/?text=Buy%20me%20a%20coffee&emoji=&slug=asheroto&button_colour=FFDD00&font_colour=000000&font_family=Lato&outline_colour=000000&coffee_colour=ffffff)" height="40px"></a>

`Chocolatey-Package-Updater` is a PowerShell script designed to automate the update of a [Chocolatey](https://chocolatey.org) package's version and checksum, as well as send an alert to the maintainer for review.

`UpdateFunctions.ps1` can be placed anywhere, but ideally at the root of you Chocolatey packages repository, with your packages being subfolders underneath. Then you can dot-source this script to access the function `UpdateChocolateyPackage`.

## Inspiration

Thie package was inspired by the [Chocolatey Automatic Package Updater Module](https://github.com/majkinetor/au) (AU) but that project is no longer maintained and I wanted to create something that was more lightweight and easier to use. The goal is to make it as easy as possible to update your Chocolatey packages without having to write regex or much more than a few lines of code.

## Differences from AU

This script has two key advantages over [AU](https://github.com/majkinetor/au):

- **Automation:** Most tasks are handled automatically, reducing the need for regex, except when retrieving version numbers from websites. GitHub repositories automatically detect the latest version.

- **EXE Comparison:** For EXEs with static URLs, the script compares the actual files to check for newer versions. This is a major benefit over AU, which relies on the version information available online instead of the actual EXE's version.

## Features

The `UpdateChocolateyPackage` function provides the following features:

-   **No functions or regex to write: everything happens _automatically_!**
-   **Regex expressions only required if scraping version number from a URL.**
-   Updates the version in the nuspec file.
-   Updates the url/checksum and url64/checksum64 (if specified) in the `ChocolateyInstall.ps1` script.
-   Updates the checksum and checksum64 (if specified) in the `VERIFICATION.txt` file (if it exists).
-   Updates the version number in the download URL (if specified).
-   Sends an email alert when the package has been updated or if there was an error updating the package.
-   Supports EXE files distributed in the package.
-   Supports variable and hash table formats for checksum in the `ChocolateyInstall.ps1` script.
-   Supports single and double quotes for checksum in the `ChocolateyInstall.ps1` script.
-   Automatic support for [aria2](https://github.com/aria2/aria2) download manager as well as `Invoke-WebRequest`.
-   Supports scraping the version number from the download URL.
-   Supports version number replacement in the download URL.
-   Supports getting the latest version from a GitHub repository.
-   **Coming soon:** support for `ntfy` to send alerts to other services (Discord, Telegram, PagerDuty, Twilio, etc.)
-   **Coming soon:** dot-sourcing the script will not be required.

**Note:** This is a rather new project, being born in late September 2023. There may still be some bugs. For now, check out the example packages to see how it works. Also check out the [To-Do List](#to-do-list) for upcoming features.

> [!IMPORTANT]
> Alerting uses [Mailjet](https://www.mailjet.com) to send email alerts. I will add in support for different types of alerts later.

## Requirements

-   PowerShell 7+
-   Windows Terminal recommended but not required

## Installation

> [!NOTE]
> An installer is not available yet, but for now you can follow the instructions below.

For the initial setup, a few short steps are required that takes less than 5 minutes. After that, you can simply copy and paste the `update.ps1` script and change the parameters as needed.

1. **Download** the `Chocolatey-Package-Updater.ps1` script from the [latest release](https://github.com/asheroto/Chocolatey-Package-Updater/releases/latest/download/Chocolatey-Package-Updater.ps1).
2. **Move** the downloaded script into the root directory of your Chocolatey packages repository like the **Recommended Folder Structure** below.
3. **Create** an `update.ps1` file within the folder of your specific Chocolatey package (or copy the example package from this repository).
4. **Make** the functions from `Chocolatey-Package-Updater.ps1` available in your `update.ps1` file by [dot-sourcing it](#dot-sourcing-the-main-script-required-at-the-top-of-each-updateps1).
5. **Call** the `UpdateChocolateyPackage` function, passing in the necessary parameters using the [examples below](#calling-the-updatechocolateypackage-function).

<details><summary>Recommended Folder Structure</summary>

<p>

## Recommended Folder Structure

The recommended folder structure matches this repository's structure. You can use this as a template for your own Chocolatey packages repository.

Your folder may be called "ChocolateyPackages" and then instead of `example-package-exe-distributed`, for example, it would be `fxsound` or whatever your package name is.

![image](https://github.com/asheroto/Chocolatey-Package-Updater/assets/49938263/7dce86c6-6700-4542-9efb-820563c656a2)

Certainly, here's a simplified explanation:

### Real-World Example

For a practical example of how to set up your Chocolatey packages, you can check out [this GitHub repository](https://github.com/asheroto/ChocolateyPackages). This repository shows you how to organize your Chocolatey packages.

> [!NOTE]
> Not every package in this example is using the `Chocolatey-Package-Updater.ps1` script yet, but they will be updated to use it soon. To see which packages are already using the updater script, take a look at the [UpdateAll.ps1 file](https://github.com/asheroto/ChocolateyPackages/blob/master/UpdateAll.ps1) in the same repository.

</p>
</details>

## Usage

Before we get too deep into the usage, here are the included example packages. If the code block examples are confusing to you, you can check out the example packages to see how it works.

### Example Packages

| Package                                        | Description                                                                                                                                     |
| ---------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| [fxsound](example-package-exe-distributed)     | Uses `FileUrl` and `FileDestinationPath` for distributing EXE within package                                                                    |
| [Miro](example-package-url-url64)              | Uses `FileUrl` and `FileUrl64` for updating a package with both 32/64-bit EXEs                                                                  |
| [StartAllBack](example-package-scrape-version) | Uses `ScrapePattern`, `ScrapeUrl`, and `FileUrl` for scraping version number from a URL, uses `{VERSION}` in FileUrl to be replaced by scraping |
| [Ventoy](example-package-github-repo)          | Uses `GitHubRepoUrl` and `FileUrl` for downloading the latest release from a GitHub repository                                                  |

---

### Dot-sourcing the main script (required at the top of each `update.ps1`)

**Note:** The $ScriptPath variable **_must_** be defined so that the `UpdateChocolateyPackage` function can locate the package files. Whether you hard code the variable or use the code below, it's up to you.

#### Required code at the top of any `update.ps1` script

```powershell
# Set vars to the script and the parent path ($ScriptPath MUST be defined for the UpdateChocolateyPackage function to work)
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ParentPath = Split-Path -Parent $ScriptPath

# Import the UpdateChocolateyPackage function
. (Join-Path $ParentPath 'Chocolatey-Package-Updater.ps1')
```

---

### Calling the `UpdateChocolateyPackage` function

Now that you have the dot-sourcing code at the top of your `update.ps1` script, you can call the `UpdateChocolateyPackage` function immediately after.

#### Example using file distributed in package

This method corresponds to the [example-package-exe-distributed](example-package-exe-distributed) example package.

```powershell
# Create a hash table to store package information
$packageInfo = @{
    PackageName         = "fxsound"
    FileUrl             = 'https://download.fxsound.com/fxsoundlatest'   # URL to download the file from
    FileDestinationPath = '.\tools\fxsound_setup.exe'                    # Path to move/rename the temporary file to (if EXE is distributed in package
    Alert               = $true                                          # If the package is updated, send a message to the maintainer for review (optional, default is $true)
    EnvFilePath         = "..\.env"                                      # Path to the .env file for alerting
}

# Call the UpdateChocolateyPackage function and pass the hash table
UpdateChocolateyPackage @packageInfo
```

<details><summary>Full Example</summary>
<p>

```powershell
[CmdletBinding()] # Enables -Debug parameter for troubleshooting
param ()

# Set vars to the script and the parent path ($ScriptPath MUST be defined for the UpdateChocolateyPackage function to work)
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ParentPath = Split-Path -Parent $ScriptPath

# Import the UpdateChocolateyPackage function
. (Join-Path $ParentPath 'Chocolatey-Package-Updater.ps1')

# Create a hash table to store package information
$packageInfo = @{
    PackageName         = "fxsound"
    FileUrl             = 'https://download.fxsound.com/fxsoundlatest'   # URL to download the file from
    FileDestinationPath = '.\tools\fxsound_setup.exe'                    # Path to move/rename the temporary file to (if EXE is distributed in package
    EnvFilePath         = "..\.env"                                      # Path to the .env file for alerting
}

# Call the UpdateChocolateyPackage function and pass the hash table
UpdateChocolateyPackage @packageInfo
```

</p>
</details>

#### Example using url and url64:

This method corresponds to the [example-package-url-url64](example-package-url-url64) example package.

```powershell
# Create a hash table to store package information
$packageInfo = @{
    PackageName         = "miro"
    FileUrl             = 'https://desktop.miro.com/platforms/win32-x86/Miro.exe'   # URL to download the file from
    FileUrl64           = 'https://desktop.miro.com/platforms/win32/Miro.exe'       # URL to download the file from
    EnvFilePath         = "..\.env"                                                 # Path to the .env file for alerting
}

# Call the UpdateChocolateyPackage function and pass the hash table
UpdateChocolateyPackage @packageInfo
```

#### Example using ScrapeUrl, ScrapePattern, FileUrl version replacement

This method corresponds to the [example-package-scrape-version](example-package-scrape-version) example package.

```powershell
# Create a hash table to store package information
$packageInfo = @{
    PackageName         = "StartAllBack"                                                                                  # Package name
    ScrapeUrl           = 'https://startallback.com/'                                                                     # URL to scrape for version number
    ScrapePattern       = '(?<=<span class="title">Download v)[\d.]+'                                                     # Regex pattern to match version number
    FileUrl             = "https://startisback.sfo3.cdn.digitaloceanspaces.com/StartAllBack_{VERSION}_setup.exe"          # URL to download the file from
    EnvFilePath         = "..\.env"                                                                                       # Path to the .env file for alerting
}

# Call the UpdateChocolateyPackage function and pass the hash table
UpdateChocolateyPackage @packageInfo
```

#### Example using GitHub release

This method corresponds to the [example-package-github-repo](example-package-github-repo) example package.

```powershell
# Create a hash table to store package information
$packageInfo = @{
    PackageName         = "ventoy"                                                                                        # Package name
    FileUrl             = "https://github.com/ventoy/Ventoy/releases/download/v{VERSION}/ventoy-{VERSION}-windows.zip"    # URL to download the file from, using {VERSION} where the version number goes
    GitHubRepoUrl       = "https://github.com/ventoy/Ventoy"                                                              # GitHub repository URL
    AutoPush            = $true                                                                                           # Automatically push the package to the Chocolatey community repository
    EnvFilePath         = "..\.env"                                                                                       # Path to the .env file for alerting
}

# Call the UpdateChocolateyPackage function and pass the hash table
UpdateChocolateyPackage @packageInfo
```

### Alternate method using named parameters

The splatting method above is recommended because it's easier to read and maintain, but if you'd rather use named parameters, you can do so like this:

```powershell
UpdateChocolateyPackage -PackageName "fxsound" -FileUrl "https://download.fxsound.com/fxsoundlatest" -FileDestinationPath ".\tools\fxsound_setup.exe" -Alert $true -EnvFilePath "..\.env"
```

```powershell
UpdateChocolateyPackage -PackageName "fxsound" -FileUrl "https://desktop.miro.com/platforms/win32-x86/Miro.exe" -FileUrl64 'https://desktop.miro.com/platforms/win32/Miro.exe' -EnvFilePath "..\.env"
```

```powershell
UpdateChocolateyPackage -PackageName "StartAllBack" -ScrapeUrl 'https://startallback.com/' -ScrapePattern '(?<=<span class="title">Download v)[\d.]+' -FileUrl "https://startisback.sfo3.cdn.digitaloceanspaces.com/StartAllBack_{VERSION}_setup.exe" -EnvFilePath "..\.env"
```

```powershell
UpdateChocolateyPackage -PackageName "ventoy" -FileUrl "https://github.com/ventoy/Ventoy/releases/download/v{VERSION}/ventoy-{VERSION}-windows.zip" -GitHubRepoUrl "https://github.com/ventoy/Ventoy" -AutoPush $true -EnvFilePath "..\.env"
```

---

### Scheduling the PowerShell Script

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

## Function Parameters for `UpdateChocolateyPackage`

| Parameter                 | Type    | Required                       | Description                                                                                                                           |
| ------------------------- | ------- | ------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------- |
| `-PackageName`            | string  | Yes                            | The name of the package.                                                                                                              |
| `-FileUrl`                | string  | Yes                            | The URL to download the file from. Supports `{VERSION}` placeholder if used with `ScrapeUrl` and `ScrapePattern`.                     |
| `-FileUrl64`              | string  | Yes                            | The URL to download the 64-bit file from.                                                                                             |
| `-FileDestinationPath`    | string  | Required if EXE is distributed | Absolute/relative path to move/rename the temporary file to (if EXE is distributed in package).                                       |
| `-FileDestinationPath64`  | string  | Required if EXE is distributed | Absolute/relative path to move/rename the temporary 64-bit file to (if EXE is distributed in package).                                |
| `-GitHubRepoUrl`          | string  | No                             | The URL to the GitHub repository. If specified, the latest release will be downloaded using `{VERSION}` replacement in the `FileUrl`. |
| `-ScrapeUrl`              | string  | No                             | URL to scrape the version number from if it is not available in the download URL.                                                     |
| `-ScrapePattern`          | string  | No                             | Regex pattern to use when scraping the version number from the scrape URL.                                                            |
| `-IgnoreVersion`          | string  | No                             | Ignore this version when attempting to update. Useful for ignoring modified versions like `1.0.2.20240531`.                           |
| `-AutoPush`               | boolean | No                             | Automatically performs "choco push" to push the package to the Chocolatey community repository.                                       |
| `-Alert`                  | boolean | No                             | If the package is updated, send a notification to the maintainer for review.                                                          |
| `-EnvFilePath`            | string  | Required for email alerts      | Specifies the path to the .env file that contains Mailjet API key and to/from email information (refer to example below).             |
| `-NuspecPath`             | string  | No                             | **Not recommended.** Absolute/relative path to the nuspec file. Default Choco paths are recommended.                                  |
| `-InstallScriptPath`      | string  | No                             | **Not recommended.** Absolute/relative path to the `ChocolateyInstall.ps1` script. Default Choco paths are recommended.               |
| `-VerificationPath`       | string  | No                             | **Not recommended.** Absolute/relative path to the `VERIFICATION.txt` file. Default Choco paths are recommended.                      |
| `-FileDownloadTempPath`   | string  | No                             | **Not recommended.** Absolute/relative path to save the temporary download file. Default paths are recommended.                       |
| `-FileDownloadTempPath64` | string  | No                             | **Not recommended.** Absolute/relative path to save the temporary 64-bit download file. Default paths are recommended.                |

### Notes:
- **Required if EXE is distributed:** This parameter is required only if the EXE file is distributed as part of the package.
- **Not recommended:** These parameters are not recommended as it is better to use the default Chocolatey paths for consistency and simplicity.

`-ScrapeUrl64` and `-ScrapePattern64` are not options because the version number should be the same regardless of architecture.

## Alert Email Address Environment Variable

To avoid exposing your email address in the Chocolatey `update.ps1` script, especially if the script is published to a public repository, you can set the environment variable CHOCO_PACKAGE_UPDATER_ALERT_EMAIL with your email address. This can be done in the Windows settings or set programmatically before calling your `update.ps1` script.

### Setting the Environment Variable in Windows

1. Open the **Start** menu and search for "Environment Variables."
2. Select **Edit the system environment variables.**
3. In the **System Properties** window, click on **Environment Variables.**
4. Under **User variables**, click **New** and enter the following:
   - **Variable name:** `CHOCO_PACKAGE_UPDATER_ALERT_EMAIL`
   - **Variable value:** user@domain.com
5. Click **OK** to save the new variable.

### Setting the Environment Variable Programmatically

```powershell
$env:CHOCO_PACKAGE_UPDATER_ALERT_EMAIL = "user@domain.com"

# Run your update.ps1 script
.\update.ps1
```

## Alerting

To get email notifications, you can use [Mailjet](https://www.mailjet.com/). Signing up is quick, taking just 5-10 minutes. The free plan lets you send up to 6,000 emails a month. Once you have your API key from the account settings, set up your `.env` file like this:

```env
mailjet_api_key = "ABC123DEF321"
mailjet_api_secret = "XYZ321ZYX123"
mailjet_from_name = "Chocolatey Package Updater"
mailjet_from_email = "alerts@yourdomain.com"
mailjet_to_name = "your name"
mailjet_to_email = "alerts@yourdomain.com"
```

Make sure the `from` email matches your account email, unless you add another verified sender.

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

- Do I have to use Mailjet?
    - If you want to be alerted when the package is updated, yes.
    - Their service is free and only takes a few minutes to sign up.
-   Do I need to use the `VERIFICATION.txt` file?
    -   No, it's optional unless you are distributing an EXE with the package (if EULA allows it). If you don't use it, just leave the parameter blank or comment it out.
-   Can I use [ntfy.sh](https://github.com/binwiederhier/ntfy), Discord, Telegram, PagerDuty, Twilio, or some other service to alert me?
    -   Not yet, unless you add it yourself.
    -   If you aren't sure what to change, ChatGPT is a good place to start.
    -   [ntfy](https://github.com/binwiederhier/ntfy) is cool because once you get it setup, it integrates with many services. So in theory you could use ntfy to send a message to Discord, Telegram, PagerDuty, Twilio, and more.
    -   I am working on adding native support for other services.
-   How much development is going into this?
    -   I'm currently focused on multiple projects, but I'll definitely consider dedicating more time to this one based on community interest.
    -   If you find it useful or promising, please click the **Star** button at the top right which serves as an indicator for me to continue its development.
    -   Subscribe to release notifications by going to Watch → Custom → Releases → Apply
    -   Thank you for your support!

## To-Do List

-   [x] Add `Mailjet` support for email alerts
-   [ ] Add `ntfy` to open up support for many other notification services (email, Discord, Telegram, PagerDuty, Twilio, etc.)
-   [ ] Add `UpdateSelf` function
-   [ ] Add to PowerShell Gallery
-   [ ] Add script to Chocolatey community repository
-   [ ] Add more examples
-   [ ] Improve output/debug
-   [ ] Support alternate checksum/checksum64 specification in `VERIFICATION.txt` file (right now it expects `checksum:` and `checksum64:`)
-   [ ] Add check for missing nuspec
-   [ ] Add support for regex matches in case that is needed
-   [ ] Simplify the Usage section
-   [ ] Change it so that the `UpdateChocolateyPackage` function can be called without dot-sourcing the script (global function?)
-   [ ] Add color to output
-   [ ] Automatically remove previous `nupkg` file
-   [ ] Automatically push to Chocolatey community repository