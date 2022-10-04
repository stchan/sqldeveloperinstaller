# SQL Developer Installer (with JDK) for Windows x64 - v22.2.1.234.1810
Oracle does not provide a SQL Developer installation package for Windows. This VS/Wix project will build an MSI package for 64-bit Windows that will install SQL Developer and its included JDK, update the system path, create program menu entries for SQL Developer / SQLcl (sql.exe), and (optionally) create a public desktop shortcut for SQL Developer.

## Disclaimers
This installer is not an official Oracle release, and the Oracle corporation is not involved in its development. I (@stchan) am not affiliated with Oracle corporation in any way, have no involvement in the development of its products (including SQL Developer), and do not represent it in any manner. SQL Developer is the property of Oracle corporation. Check your licensing agreement with Oracle if you have concerns about using this installer.

## License
Any content that is not the property of Oracle corporation (SQL Developer and its associated material), and is the work of the author (@stchan) is MIT/X11 licensed.

## Tooling
* Visual Studio 2022
* Wix 3.11
* Votive 2022 (Wix VS Extension)

## Building
1. Download the Windows 64-bit with JDK included archive from [here](https://www.oracle.com/database/sqldeveloper/technologies/download/).
1. Extract the "sqldeveloper" folder in the archive under the solution folder (ie. at the same level as the "SQLDeveloperInstaller" project folder). You can overwrite an empty existing "sqldeveloper" folder - .gitignore has an entry for that folder. If there are files in the folder (ie. an upgrade situation), I recommend deleting it first as the harvest process (heat.exe) will gather everything. Any old/obsolete files would be included.
1. Set the solution configuration to "Release", and the platform to "x64".
1. Build the solution - the MSI will be in "bin\Release"

## Notes
* I developed on Windows 11 22H2, but don't see any reason why this wouldn't work on any 64-bit version of Windows that can run the tools.
* The installer derives its version from the fileversion of "sqldeveloper.exe", so as long as Oracle continues to increment it, new MSIs will automatically be able to upgrade old installs.
* The MSI output name is manually set, so if you upgrade to newer versions of SQL Developer, it should be changed. It will still work properly (ie will upgrade older versions), but will be incorrectly named.
