$ErrorActionPreference = "Stop"

# https://startallback.com/download.php

# Package args
$packageArgs = @{
    PackageName    = "StartAllBack"
    SoftwareName   = "StartAllBack"
    Version        = "3.6.1"
    Url            = "https://startisback.sfo3.cdn.digitaloceanspaces.com/StartAllBack_${VERSION}_setup.exe"
    Checksum       = "OLD_CHECKSUM_WILL_BE_REPLACED_BY_CHOCOLATEY_PACKAGE_UPDATER"
    ChecksumType   = "sha256"
    SilentArgs     = "/silent /elevated"
    ValidExitCodes = @(0)
}

# Install
Install-ChocolateyPackage @packageArgs