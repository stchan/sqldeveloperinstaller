# SQL Developer (with JDK) Installer for Windows x64 - v23.1.1.345.2114
Oracle does not provide a SQL Developer installation package for Windows. This VS/Wix project will build an MSI package for 64-bit Windows that will install SQL Developer and its included JDK, update the system path, create program menu entries for SQL Developer / SQLcl (sql.exe), and (optionally) create a public desktop shortcut for SQL Developer.

## Disclaimers
This installer is not an official Oracle release, and the Oracle corporation is not involved in its development. I (@stchan) am not affiliated with Oracle in any way, have no involvement in the development of its products (including SQL Developer), and do not represent it in any manner. SQL Developer is the property of the Oracle corporation. Check your licensing agreement if you have concerns about building and/or using this installer.

## License
Any content that is not the property of Oracle (SQL Developer and its associated material), and is the work of the author (@stchan) is MIT/X11 licensed.

## Tooling
* Visual Studio 2022
* Wix 4

## Building
1. Download the Windows 64-bit with JDK included archive from [here](https://www.oracle.com/database/sqldeveloper/technologies/download/).
1. Extract the "sqldeveloper" folder in the archive under the solution folder (ie. at the same level as the "SQLDeveloperInstaller" project folder). You can overwrite an empty existing "sqldeveloper" folder - .gitignore has an entry for that folder. If there are files in the folder (ie. an upgrade situation), I recommend emptying, or deleting it first, as the harvest process will gather everything. Any old/obsolete files would be included.
1. Run the **buildrelease.ps1** script. Powershell 7.2 (or newer) is required.
1. The MSI will be in "publish\unsigned\\<culture>". If you build from within VS 2022, the MSI filename will default to version "0.0.0.0" (the actual Product Version is not affected, only the filename) - this is because Wix 4.0 does not use the "TargetName" property set in a "BeforeBuild" target. Run the powershell script if you want an MSI with a filename that reflects the **sqldeveloper.exe** version.

## Notes
* The installer derives its version from "sqldeveloper.exe", so as long as Oracle increments the file version every release, new MSIs will automatically be able to upgrade old installs.
* [Jeff Smith](https://www.thatjeffsmith.com/about/), a product manager at Oracle on the SQL Developer team [does not recommend installing SQL Developer into the %ProgramFiles% folder](https://www.thatjeffsmith.com/archive/2022/06/oracle-sql-developer-modeler-versions-22-2-now-available/), though I'm not sure if he means never ever, or just don't xcopy it in.
* There are no plans to support 32-bit installations (zilch, zero, so don't ask), but modifying the project to target x86 shouldn't be difficult.



