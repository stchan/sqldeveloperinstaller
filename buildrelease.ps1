#Requires -Version 7.2
param (
   [string]$name = "sqldeveloper",
   [switch]$sign = $false
)

$startworkinglocation = Get-Location

if ($sign)
{
        if (Test-Path "$env:ProgramFiles\Microsoft Visual Studio\2022\Community\Common7\Tools\Launch-VsDevShell.ps1")
        {
            $initvsdevshell = "$env:ProgramFiles\Microsoft Visual Studio\2022\Community\Common7\Tools\Launch-VsDevShell.ps1"
        }
        elseif (Test-Path "$env:ProgramFiles\Microsoft Visual Studio\2022\Professional\Common7\Tools\Launch-VsDevShell.ps1")
        {
            $initvsdevshell = "$env:ProgramFiles\Microsoft Visual Studio\2022\Professional\Common7\Tools\Launch-VsDevShell.ps1"
        }
        elseif (Test-Path "$env:ProgramFiles\Microsoft Visual Studio\2022\BuildTools\Common7\Tools\Launch-VsDevShell.ps1")
        {
            $initvsdevshell = "$env:ProgramFiles\Microsoft Visual Studio\2022\BuildTools\Common7\Tools\Launch-VsDevShell.ps1"
        }
        if ($initvsdevshell)
        { 
            & $initvsdevshell
        }
        else
        {
            Write-Output 'Visual Studio 2022 was not found - VS developer shell launch script will not be run.'
        }
        if ((Get-Command "msbuild.exe" -ErrorAction SilentlyContinue) -eq $null) 
        { 
            Write-Host "msbuild.exe not found in PATH. Exiting."
            exit 1
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

$sqldevversion = (get-item .\sqldeveloper\sqldeveloper.exe).VersionInfo.FileVersion
Write-Host sqldeveloper.exe version is $sqldevversion

dotnet clean --configuration Release
dotnet build -p:Configuration=Release -p:InstallerName=$name -p:InstallerVersion=$sqldevversion -p:OutputPath="$buildoutputpath" SQLDeveloperInstaller.sln

# sign the installer if -sign was specified
if ($sign -eq $true)
{
   signtool.exe sign /sha1 $env:CodeSignHash /t http://time.certum.pl /fd sha256 /v "$buildoutputpath\$((Get-Culture).Name)\*.msi"
}

Set-Location -Path "$buildoutputpath\$((Get-Culture).Name)\"

$outputfiles = Get-ChildItem "."
foreach ($outfile in $outputfiles) {
    certutil -hashfile $outfile.Name sha512  | Out-File -Encoding utf8NoBOM  -FilePath "$outfile.sha512"
}

Set-Location -Path $startworkinglocation
