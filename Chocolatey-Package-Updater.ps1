<#PSScriptInfo

.VERSION 0.0.1

.GUID 9b612c16-25c0-4a40-afc7-f876274e7e8c

.AUTHOR asheroto

.COMPANYNAME asheroto

.TAGS PowerShell Windows Chocolatey choco package updater update maintain maintainer monitor monitoring alert notification exe installer automatic auto automated automation schedule scheduled scheduler task

.PROJECTURI https://github.com/asheroto/Chocolatey-Package-Updater

.RELEASENOTES
[Version 0.0.1] - Initial release, deployment and additional features still under development.

#>

<#

.SYNOPSIS
This PowerShell script automates the updating of Chocolatey packages, managing version changes, checksum updates, and alert notifications.

.DESCRIPTION
The script simplifies the process of updating Chocolatey packages by providing automated functionality to:
- Update the version in the nuspec file.
- Update the checksum in the install script.
- Update the checksum in the verification file (if it exists).
- Send alerts to a designated URL.
- Support EXE files distributed in the package.
- Support variable and hash table formats for checksums in the install script.
- Support single and double quotes for checksums in the install script.

.EXAMPLE
To update a Chocolatey package, run the following command:
UpdateChocolateyPackage -PackageName "fxsound" -FileUrl "https://download.fxsound.com/fxsoundlatest" -FileDownloadTempPath ".\fxsound_setup_temp.exe" -FileDestinationPath ".\tools\fxsound_setup.exe" -NuspecPath ".\fxsound.nuspec" -InstallScriptPath ".\tools\ChocolateyInstall.ps1" -VerificationPath ".\tools\legal\VERIFICATION.txt" -Alert $true

.NOTES
- Version: 0.0.1
- Created by: asheroto

.LINK
Project Site: https://github.com/asheroto/Chocolatey-Package-Updater

#>

# Script information (future use)
# $CurrentVersion = '0.0.1'
# $RepoOwner = 'asheroto'
# $RepoName = 'Chocolatey-Package-Updater'
# $PowerShellGalleryName = 'Chocolatey-Package-Updater'

# Suppress progress bar (makes downloading super fast)
$ProgressPreference = 'SilentlyContinue'

function UpdateFileContent {
    [OutputType([System.String])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$FilePath,

        [Parameter(Mandatory = $true)]
        [string]$Pattern,

        [Parameter(Mandatory = $true)]
        [string]$Replacement
    )

    # Get the absolute path of the file
    $absolutePath = (Resolve-Path $FilePath).ProviderPath

    Write-Debug "Updating file content: $absolutePath"

    if (Test-Path $absolutePath) {
        $fileContent = Get-Content $absolutePath -Raw

        # Attempt to replace the specified pattern with the replacement string
        $updatedContent = $fileContent -replace $Pattern, $Replacement

        # Write the updated content back to the file
        [System.IO.File]::WriteAllText($absolutePath, $updatedContent)

        # Verify that the replacement actually occurred by checking the file content
        $verifyContent = Get-Content $absolutePath -Raw
        if ($verifyContent -match [regex]::Escape($Replacement)) {
            Write-Debug "Replacement verified in file: $absolutePath"
            return "true"
        } else {
            $errorMessage = "Replacement not found in file: $absolutePath"
            return $errorMessage
        }
    } else {
        $errorMessage = "File not found: $absolutePath"
        return $errorMessage
    }
}

function SendAlertRaw {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Subject,

        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    # Note - you might consider using ntfy.sh, it's an awesome tool
    # In this script, however, I'm using a custom service that I built
    # This function gets the URL from a secure string file and sends the alert by making a POST request to the URL

    # Get the secret URL from the secure string file using the path in the environment variable
    $CredsFile = [System.Environment]::GetEnvironmentVariable('EMAIL_NOTIFICATION_CREDS_PATH', [System.EnvironmentVariableTarget]::User)

    # Convert the secure string to a string
    $secret = Get-Content $CredsFile | ConvertTo-SecureString
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secret)
    $alertUrl = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

    # Replace {SUBJECT} and {MESSAGE} in the URL
    $alertUrl = $alertUrl -replace '{SUBJECT}', $Subject
    $alertUrl = $alertUrl -replace '{MESSAGE}', $Message

    if ($alertUrl) {
        Invoke-WebRequest -Uri $alertUrl -Method Post -Body $Message -ContentType "text/plain" | Out-Null
        Write-Output "Alert sent."
    }
}

function SendAlert {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Subject,

        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter(Mandatory = $false)]
        [boolean]$Alert = $true
    )

    # If Alert is false, let the user know that the alert is disabled
    if (!$Alert) {
        Write-Output "Alert disabled. Skipping alert."
        return
    }

    # Output sending alert
    Write-Output "Sending alert..."

    # Create the HTML body for the notification
    $date = Get-Date -Format "yyyy-MM-dd hh:mm:ss tt"
    $body = "<html><body>"
    $body += "<font face='Arial'>"
    $body += "<p>$Message</p>"
    $body += "<p><strong>Time:</strong> $date</p>"
    $body += "</font>"
    $body += "</body></html>"

    Write-Verbose "Sending alert with subject: $Subject"
    Write-Verbose "Sending alert with body:`n$body"

    # Send the alert
    SendAlertRaw -Subject $Subject -Message $body
}

function Write-Section {
    <#
        .SYNOPSIS
        Prints a text block surrounded by a section divider for enhanced output readability.

        .DESCRIPTION
        This function takes a message input and prints it to the console, surrounded by a section divider made of hash characters.
        It enhances the readability of console output by categorizing messages based on the Type parameter.

        .PARAMETER Message
        The message to be printed within the section divider. This parameter is mandatory.

        .PARAMETER Type
        The type of message to display. Possible values: "Output" (default), "Debug," "Warning," "Information," "Verbose."

        .EXAMPLE
        Write-Section -Message "This is a sample message."

        This command prints the provided message surrounded by a section divider. Because the Type parameter is not specified, it defaults to "Output."

        .EXAMPLE
        Write-Section "This is another sample message."

        This command also prints the message surrounded by a section divider. The -Message parameter is implied and does not need to be explicitly named.

        .EXAMPLE
        Write-Section -Message "This is a warning message." -Type "Warning"

        This command prints the provided message surrounded by a section divider and uses Write-Warning to display the message, due to the Type parameter being set to "Warning."
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message,
        [ValidateSet("Output", "Debug", "Warning", "Information", "Verbose")]
        [string]$Type = "Output"
    )

    $consoleWidth = [System.Console]::WindowWidth - 2
    $prependLength = 0

    switch ($Type) {
        "Output" { $writeCmd = { Write-Output $args[0] } }
        "Debug" { $writeCmd = { Write-Debug $args[0] }; $prependLength = 7 }
        "Warning" { $writeCmd = { Write-Warning $args[0] }; $prependLength = 9 }
        "Information" { $writeCmd = { Write-Information $args[0] }; }
        "Verbose" { $writeCmd = { Write-Verbose $args[0] }; $prependLength = 9 }
    }

    $divider = "#" * ($consoleWidth - $prependLength)
    & $writeCmd $divider

    $words = $Message -split ' '
    $line = "# "
    foreach ($word in $words) {
        if (($line.Length + $word.Length + 1) -gt ($consoleWidth - $prependLength - 1)) {
            $line = $line.PadRight($consoleWidth - $prependLength - 1) + "#"
            & $writeCmd $line
            $line = "# "
        }
        $line += "$word "
    }

    if ($line.Trim().Length -gt 1) {
        $line = $line.PadRight($consoleWidth - $prependLength - 1) + "#"
        & $writeCmd $line
    }

    $divider = "#" * ($consoleWidth - $prependLength)
    & $writeCmd $divider
}

function UpdateChocolateyPackage {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$PackageName,

        [Parameter(Mandatory = $true)]
        [string]$FileUrl,

        [Parameter(Mandatory = $true)]
        [string]$FileDownloadTempPath,

        [Parameter(Mandatory = $false)]
        [string]$FileDestinationPath,

        [Parameter(Mandatory = $true)]
        [string]$NuspecPath,

        [Parameter(Mandatory = $true)]
        [string]$InstallScriptPath,

        [Parameter(Mandatory = $false)]
        [string]$VerificationPath,

        [Parameter(Mandatory = $false)]
        [boolean]$Alert = $true,

        [Parameter(Mandatory = $false)]
        [boolean]$FileDownloadTempDelete = $true
    )

    function CleanupFileDownload {
        # Check if FileDownloadTempDelete is not set
        if (-not $FileDownloadTempDelete) {
            Write-Debug "Temporary file deletion is disabled."
        } else {
            # Check if the file exists at the specified path
            if (Test-Path $FileDownloadTempPath) {
                try {
                    Write-Debug "Removing temporary file: $FileDownloadTempPath"
                    Remove-Item $FileDownloadTempPath -Force
                } catch {
                    Write-Warning "Failed to remove temporary file: $FileDownloadTempPath"
                }
            } else {
                Write-Debug "File download temp path does not exist and will not conflict with downloads: $FileDownloadTempPath"
            }
        }
    }

    try {
        # Show the current directory
        Write-Debug "Current directory: $pwd"

        # FileDownloadTempDelete warning
        if ($FileDownloadTempDelete -eq $false) {
            Write-Section "FileDownloadTempDelete is disabled. The temporary file will not be deleted which could cause issues when downloading next time." -Type Warning
        }

        # If the temp file exists and the FileDeleteTempPath parameter is true, remove the temp file
        CleanupFileDownload

        # Download the file and get its ProductVersion
        Write-Output "Downloading file: $FileUrl"
        Write-Output "Saving to: $FileDownloadTempPath"
        if (Get-Command aria2c -ErrorAction SilentlyContinue) {
            Write-Debug "aria2c is installed. Using aria2c to download the file."
            Invoke-Expression $("aria2c --out=`"$FileDownloadTempPath`" `"$FileUrl`" $($DebugPreference -eq 'SilentlyContinue' ? '--quiet' : '')")
        } else {
            Write-Debug "aria2c is not installed. Using Invoke-WebRequest to download the file."
            Invoke-WebRequest -Uri $FileUrl -OutFile $FileDownloadTempPath
        }

        # Get the product version from the downloaded file
        $ProductVersion = (Get-Command $FileDownloadTempPath).FileVersionInfo.ProductVersion

        # Trim the version to 3 parts if it has 4
        if ($ProductVersion -match '^\d+(\.\d+){3}$') {
            $ProductVersion = ($ProductVersion -split '\.')[0..2] -join '.'
        }

        # Get the current version from the nuspec
        $NuspecContent = Get-Content $NuspecPath -Raw
        $VersionMatches = [regex]::Match($NuspecContent, '<version>(.*?)<\/version>')
        $NuspecVersion = $VersionMatches.Groups[1].Value

        # Define the match pattern for checksum in ChocolateyInstall.ps1
        $checksumPattern = '(?<=\$checksum\s*=\s*)["''].*?["'']|(?<=checksum\s*=\s*)["''].*?["'']'

        # Extract the current checksum from ChocolateyInstall.ps1
        $chocolateyInstallContent = Get-Content $InstallScriptPath -Raw
        $CurrentChecksumMatches = [regex]::Match($chocolateyInstallContent, $checksumPattern)
        $CurrentChecksum = $CurrentChecksumMatches.Value.Trim("'")

        # Calculate the new checksum
        $NewChecksum = (Get-FileHash -Algorithm SHA256 $FileDownloadTempPath).Hash

        Write-Debug "Product version: $ProductVersion"
        Write-Debug "Nuspec version: $NuspecVersion"
        Write-Debug "New checksum: $NewChecksum"
        Write-Debug "Current checksum: $CurrentChecksum"

        # Validate version strings
        if ($ProductVersion -match '^\d+(\.\d+){1,3}$' -and $NuspecVersion -match '^\d+(\.\d+){1,3}$') {
            Write-Debug "Version strings are valid."

            # Compare versions and checksums
            if ([version]$ProductVersion -gt [version]$NuspecVersion -or $NewChecksum -ne $CurrentChecksum) {
                Write-Output "Version or checksum is different. Updating package..."

                # nuspec file
                # Update the version
                $nuspecResult = UpdateFileContent -FilePath $NuspecPath -Pattern '(<version>).*?(<\/version>)' -Replacement "`${1}$ProductVersion`$2"
                if (!$nuspecResult) {
                    throw "Failed to update version in nuspec file: $NuspecPath"
                } else {
                    Write-Output "Updated version in nuspec file: $NuspecPath"
                }

                # ChocolateyInstall.ps1
                # Detect the format (variable or hash table) and update the checksum accordingly
                $chocolateyInstallPattern = '(?<=(checksum\s*=\s*)["''])(.*?)(?=["''])'
                $chocolateyInstallResult = UpdateFileContent -FilePath $InstallScriptPath -Pattern $chocolateyInstallPattern -Replacement $NewChecksum

                if (!$chocolateyInstallResult) {
                    throw "Failed to update checksum in ChocolateyInstall.ps1 script: $InstallScriptPath"
                } else {
                    Write-Output "Updated checksum in ChocolateyInstall.ps1 script: $InstallScriptPath"
                }

                # VERIFICATION.txt
                # Check whether $VerificationPath is set or not, and if set, check if it exists or not
                if ($VerificationPath) {
                    if (Test-Path $VerificationPath) {
                        Write-Debug "Verification path is set and file exists. Updating checksum in verification file: $VerificationPath."

                        $verificationResult = UpdateFileContent -FilePath $VerificationPath -Pattern '(checksum:\s*)\w+' -Replacement "`${1}$NewChecksum"

                        if (!$verificationResult) {
                            throw "Failed to update checksum in verification file: $VerificationPath"
                        } else {
                            Write-Output "Updated checksum in verification file: $VerificationPath"
                        }
                    } else {
                        throw "Verification path is set but the file does not exist: $VerificationPath."
                    }
                } else {
                    Write-Debug "Verification path is not set."
                }

                # Write the new version to the console
                Write-Output "Updated to version $ProductVersion."

                # Send an alert if enabled
                Write-Debug "Sending alert..."
                SendAlert -Subject "$PackageName Package Updated" -Message "$PackageName has been updated to version $ProductVersion. It is now ready for testing." -Alert $Alert

                # If the destination path is specified, move the downloaded file to the specified destination
                if ($FileDestinationPath) {
                    Write-Debug "Moving file `"${FileDownloadTempPath}`" to `"${FileDestinationPath}`""
                    Move-Item $FileDownloadTempPath -Destination $FileDestinationPath -Force
                }
            } else {
                # Package is up to date
                Write-Output "No update needed."
            }
        } else {
            # Invalid version format
            Write-Output "Invalid version format. Skipping update."

            # Send an alert if enabled
            Write-Debug "Sending alert..."
            SendAlert -Subject "$PackageName Package Error" -Message "$PackageName detected an invalid version format. Please check the update script and files." -Alert $Alert
        }
    } catch {
        # Send an alert if enabled
        Write-Debug "Sending alert..."
        SendAlert -Subject "$PackageName Package Error" -Message "$PackageName had an error when checking for updates. Please check the update script and files.<br><br><strong>Error:</strong> $_" -Alert $Alert

        # Write the error to the console
        Write-Warning "An error occurred: $_"
        Write-Warning "Line number : $($_.InvocationInfo.ScriptLineNumber)"
    } finally {
        CleanupFileDownload
    }
}