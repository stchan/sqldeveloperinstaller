#Requires -Version 7.2
param (
   [string]$name = "sqldeveloper",
   [string]$versionoverride = $null,
   [switch]$sign = $false
)

Set-StrictMode -version 2

$startworkinglocation = Get-Location

if ($sign)
{
        $vspaths = @("$env:ProgramFiles\Microsoft Visual Studio\2022\Community\Common7\Tools\Launch-VsDevShell.ps1","$env:ProgramFiles\Microsoft Visual Studio\2022\Professional\Common7\Tools\Launch-VsDevShell.ps1","$env:ProgramFiles\Microsoft Visual Studio\2022\BuildTools\Common7\Tools\Launch-VsDevShell.ps1")
        foreach ($testvspath in $vspaths)
        {
            if (Test-Path $testvspath)
            {
                $initvsdevshell = $testvspath
                break;
            }        
        }
        if ([string]::IsNullOrEmpty($initvsdevshell) -eq $true)
        { 
            Write-Output 'Visual Studio 2022 was not found - VS developer shell launch script was not run.'
        }
        else {
            & $initvsdevshell
        }
        $requiredexecutables = @("msbuild.exe", "signtool.exe")
        foreach ($required in $requiredexecutables)
        {
            Write-Host Searching for $required in PATH.
            if ((Get-Command "$required" -ErrorAction SilentlyContinue) -eq $null) 
            { 
                Write-Host "$required not found in PATH. Exiting."
                exit 1
            }
            Write-Host $required found.
        }

        $buildoutputpath = "$PSScriptRoot\publish\signed"
}
else {
    $buildoutputpath = "$PSScriptRoot\publish\unsigned"
}

Set-Location -Path $PSScriptRoot


# Remove old stuff
Remove-Item -path $buildoutputpath -recurse -ErrorAction SilentlyContinue
mkdir -p $buildoutputpath | Out-Null

# set the version string used in the MSI filename
$sqldevversion = (get-item .\sqldeveloper\sqldeveloper.exe).VersionInfo.FileVersion
Write-Host sqldeveloper.exe version is $sqldevversion
# use the -versionoverride parameter if set
if ([string]::IsNullOrEmpty($versionoverride) -eq $false)
{
    $sqldevversion = $versionoverride
    Write-Host "Version manually set to $versionoverride (will not change the product version, only the MSI filename)" 
}


dotnet clean --configuration Release
dotnet build -p:Configuration=Release -p:InstallerName=$name -p:InstallerVersion=$sqldevversion -p:OutputPath="$buildoutputpath" SQLDeveloperInstaller.sln

# sign the installer if -sign was specified
if ($sign -eq $true)
{
   signtool.exe sign /sha1 $env:CodeSignHash /t http://time.certum.pl /fd sha256 /v "$buildoutputpath\$((Get-Culture).Name)\*.msi"
}

Set-Location -Path "$buildoutputpath\$((Get-Culture).Name)\"

# compute hashes of the output
$outputfiles = Get-ChildItem "."
foreach ($outfile in $outputfiles) {
    certutil -hashfile $outfile.Name sha512  | Out-File -Encoding utf8NoBOM  -FilePath "$outfile.sha512"
}

Set-Location -Path $startworkinglocation
