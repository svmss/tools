# $env:BUILD_SOURCESDIRECTORY contains the installer sources
# $env:BINARIESPATH contains the iMacros binaries and other files to be included in the installer
$applicationPath = "$env:BINARIESPATH\imacros.exe"

# Get the version information from the application file
# https://docs.microsoft.com/en-us/dotnet/api/system.diagnostics.fileversioninfo.productversion?view=netcore-3.1#System_Diagnostics_FileVersionInfo_ProductVersion
$versionInfo = (Get-ChildItem -Path $applicationPath).VersionInfo
$major = $versionInfo.ProductMajorPart
$minor = $versionInfo.ProductMinorPart
$build = $versionInfo.ProductBuildPart
$revision = $versionInfo.ProductPrivatePart

# Get other product information from the application file
$copyright = $versionInfo.LegalCopyright
$company_name = $versionInfo.CompanyName
$product_name = $versionInfo.ProductName
$product_description=$versionInfo.Comments + " Installer"

$company_name_short = ($company_name | Select-String -Pattern '(\w+)(:\s+\w+)*').Matches.Groups[1].Value

copy-item -Force $env:BUILD_SOURCESDIRECTORY\src\imacros_2018.iap_xml $env:BUILD_SOURCESDIRECTORY\imacros_2018.iap_xml
$bins=$env:BINARIESPATH -replace "\\", "/"

$source_file="$env:BUILD_SOURCESDIRECTORY\src\imacros_build.xml"
$target_file="$env:BUILD_SOURCESDIRECTORY\imacros_build.xml"
$content=Get-Content $source_file

$certpath=$env:PROGRESS_CERT_PATH -replace "\\", "/"
$icon="imacros.ico"
$png="imacros32.png"

$newContent = $content -replace "##MARKET_VERSION_MAJOR##", "2021"
$newContent = $newcontent -replace "##MARKET_VERSION_MINOR##", "0"
$newContent = $newcontent -replace "##VERSION_MAJOR##", $major
$newContent = $newContent -replace "##VERSION_MINOR##", $minor
$newContent = $newContent -replace "##VERSION_REV##", $build
$newContent = $newContent -replace "##VERSION_SUBREV##", $revision
$newContent = $newContent -replace '##BIN_DIR##', $bins
$newContent = $newContent -replace '##IA_SIGN_CERT_FILE##', $certpath
$newContent = $newContent -replace '##IMACROS_ICON_PATH##', $imgpath
$newContent = $newContent -replace '##IMACROS_ICON_NAME##', $icon
$newContent = $newContent -replace '##IMACROS_ICON_IMG##', $png
$newContent = $newContent -replace '##COPYRIGHT##', $copyright
$newContent = $newContent -replace '##COMPANY_NAME##', $company_name
$newContent = $newContent -replace '##PRODUCT_NAME##', $product_name
$newContent = $newContent -replace '##COMPANY_NAME_SHORT##', $company_name_short
$newContent = $newContent -replace '##PRODUCT_DESCRIPTION##', $product_description

Set-Content -Path $target_file -Value $newContent -Encoding UTF8
#Create the manifest directory
New-Item -Path "$env:BUILD_SOURCESDIRECTORY" -ItemType "directory" -name "manifest"

$src_imacros_manifest="$env:BUILD_SOURCESDIRECTORY\src\manifest\imacros.manifest"
$src_enterprise_manifest="$env:BUILD_SOURCESDIRECTORY\src\manifest\enterprise.manifest"
$src_samples_manifest="$env:BUILD_SOURCESDIRECTORY\src\manifest\samples.manifest"
$src_enterprise_samples_manifest="$env:BUILD_SOURCESDIRECTORY\src\manifest\enterprise_samples.manifest"
$src_personal_manifest="$env:BUILD_SOURCESDIRECTORY\src\manifest\personal.manifest"

$dest_imacros_manifest="$env:BUILD_SOURCESDIRECTORY\manifest\imacros.manifest"
$dest_enterprise_manifest="$env:BUILD_SOURCESDIRECTORY\manifest\enterprise.manifest"
$dest_samples_manifest="$env:BUILD_SOURCESDIRECTORY\manifest\samples.manifest"
$dest_enterprise_samples_manifest="$env:BUILD_SOURCESDIRECTORY\manifest\enterprise_samples.manifest"
$dest_personal_manifest="$env:BUILD_SOURCESDIRECTORY\manifest\personal.manifest"

$content=Get-Content $src_imacros_manifest
$newContent=$content -replace '@BIN_DIR@', $bins

[System.IO.File]::WriteAllLines($dest_imacros_manifest, $newContent)

$content=Get-Content $src_enterprise_manifest
$newContent=$content -replace '@BIN_DIR@', $bins

[System.IO.File]::WriteAllLines($dest_enterprise_manifest, $newContent)

$content=Get-Content $src_samples_manifest
$newContent=$content -replace '@BIN_DIR@', $bins

[System.IO.File]::WriteAllLines($dest_samples_manifest, $newContent)

$content=Get-Content $src_enterprise_samples_manifest
$newContent=$content -replace '@BIN_DIR@', $bins

[System.IO.File]::WriteAllLines($dest_enterprise_samples_manifest, $newContent)

$content=Get-Content $src_personal_manifest
$newContent=$content -replace '@BIN_DIR@', $bins

[System.IO.File]::WriteAllLines($dest_personal_manifest, $newContent)
