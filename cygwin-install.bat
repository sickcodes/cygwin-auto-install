@ECHO OFF
REM -- Automates cygwin installation
REM -- Source: https://github.com/rtwolf/cygwin-auto-install
REM -- Contrib: https://github.com/sickcodes/cygwin-auto-install
REM -- Based on: https://gist.github.com/wjrogers/1016065
rem cygwin-auto-install
rem ===================

rem Automated cygwin install. Just download the project as a zip file, extract and run cygwin-install.bat to install cygwin + apt-cyg + packages required for apt-cyg + optional packages.

rem You can edit the batch file to specify which optional packages you'd like installed.

rem Created by wjrogers: https://gist.github.com/wjrogers/1016065.
rem Updated by sickcodes: https://twitter.com/sickcodes/.

rem Suggest this workflow for this project: http://scottchacon.com/2011/08/31/github-flow.html

rem Source URL:
rem https://github.com/rtwolf/cygwin-auto-install/

rem If you've found this project helpful, please support me by buying me a coffee: http://www.mind-manual.com/blog/buy-me-a-coffee/

rem As you may know, "A programmer is just a tool which converts caffeine into code". Thanks in advance!
 
SETLOCAL
 
REM -- Change to the directory of the executing batch file
CD %~dp0

REM -- Download the Cygwin installer
IF NOT EXIST cygwin-setup.exe (
	ECHO cygwin-setup.exe NOT found! Downloading installer...
	bitsadmin /transfer cygwinDownloadJob /download /priority normal https://cygwin.com/setup-x86_64.exe %CD%\\cygwin-setup.exe
) ELSE (
	ECHO cygwin-setup.exe found! Skipping installer download...
)
 
REM -- Configure our paths
SET MIRROR=http://mirror.internode.on.net/pub/cygwin/
SET BACKUP_MIRROR=http://mirror.internode.on.net/pub/cygwin/
SET LOCALDIR=%CD%
SET ROOTDIR=C:/cygwin
SET RUN_SSHD=true
SET SSH_PORT=22
rem SET AUTHORIZED_IPS=10.15.97.0/24,10.17.0.0/16
SET AUTHORIZED_IPS=10.0.0.0/16
 
REM -- These are the packages we will install in addition to the default packages
REM -- Package list here: http://cygwin.com/packages/package_list.html
SET PACKAGES=base-cygwin,base-files,mintty,cron,wget,curl,vim,diffutils,git,bash,bash-completion,openssh,sshpass,zstd,python3,python3-pip,rsync,zip
REM -- These are necessary for apt-cyg install, do not change. Any duplicates will be ignored.
SET PACKAGES=%PACKAGES%,wget,tar,gawk,bzip2,subversion
 
REM -- More info on command line options at: https://cygwin.com/faq/faq.html#faq.setup.cli
REM -- Do it!
ECHO *** INSTALLING DEFAULT PACKAGES
cygwin-setup --quiet-mode --no-desktop --download --local-install --no-verify -s %MIRROR% -l "%LOCALDIR%" -R "%ROOTDIR%" || cygwin-setup --quiet-mode --no-desktop --download --local-install --no-verify -s %BACKUP_MIRROR% -l "%LOCALDIR%" -R "%ROOTDIR%"
ECHO.
ECHO.
ECHO *** INSTALLING CUSTOM PACKAGES
cygwin-setup -q -d -D -L -X -s %MIRROR% -l "%LOCALDIR%" -R "%ROOTDIR%" -P %PACKAGES%
 
REM -- Show what we did
ECHO.
ECHO.
ECHO cygwin installation updated
ECHO  - %PACKAGES%
ECHO.

ECHO apt-cyg installing.
set PATH=%ROOTDIR%/bin;%CD%;%PATH%
%ROOTDIR%/bin/bash.exe -c 'wget https://raw.githubusercontent.com/transcode-open/apt-cyg/master/apt-cyg -O /bin/apt-cyg'
%ROOTDIR%/bin/bash.exe -c 'chmod a+x /bin/apt-cyg'
%ROOTDIR%/bin/bash.exe -c '/bin/apt-cyg --version'

IF "%RUN_SSHD%"=="true" (%ROOTDIR%/bin/bash.exe -c 'mkpasswd'
    %ROOTDIR%/bin/bash.exe -c 'ssh-host-config --port %SSH_PORT% --yes'
    netsh advfirewall firewall add rule name="Open Port %SSH_PORT%" dir=in action=allow protocol=TCP localport=%SSH_PORT% remoteip=%AUTHORIZED_IPS%
    %ROOTDIR%/bin/bash.exe -c '[ "${RUN_SSHD}" ] && cygrunsrv.exe -S cygsshd'
)

ENDLOCAL
 
PAUSE
EXIT /B 0
