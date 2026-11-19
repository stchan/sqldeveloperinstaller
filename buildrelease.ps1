#Requires -Version 7.2
param (
   [string]$sign
)
if ($args.Count) { throw "Unexpected arguments passed: $args" }

Set-StrictMode -version 2

$startworkinglocation = Get-Location

# If -sign commandline argument was passed, run the VS Dev Shell script so signtool.exe is in the PATH
if ($sign -ne "" -and $sign -ne $null)
{
        $initvsdevshell = & "$PSScriptRoot\tools\vswhere.exe" -latest -find **\Launch-VsDevShell.ps1 | select-object -first 1
        if ([string]::IsNullOrEmpty($initvsdevshell) -eq $false)
        { 
            & $initvsdevshell
        }
        else 
        {
            Write-Output 'Visual Studio was not found - VS developer shell launch script was not run.'            
        }

        $requiredexecutables = @("msbuild.exe", "signtool.exe")
        foreach ($required in $requiredexecutables)
        {
            Write-Host Searching for $required in PATH.
            if ($null -eq (Get-Command "$required" -ErrorAction SilentlyContinue)) 
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


dotnet clean --configuration Release -p:Platform="x64"
dotnet build -p:Configuration=Release  -p:Platform="x64" -p:OutputPath="$buildoutputpath" SQLDeveloperInstaller.slnx

# sign the installer if -sign was specified
if ($sign -ne "" -and $sign -ne $null)
{
   signtool.exe sign /sha1 $sign /t http://time.certum.pl /fd sha256 /v "$buildoutputpath\$((Get-Culture).Name)\*.msi"
}

Set-Location -Path "$buildoutputpath\$((Get-Culture).Name)\"

# compute hashes of the output
$outputfiles = Get-ChildItem "."
foreach ($outfile in $outputfiles) {
    certutil -hashfile $outfile.Name sha256  | Out-File -Encoding utf8NoBOM  -FilePath "$outfile.sha256"
}

Set-Location -Path $startworkinglocation
