::
:: Batch file that excutes a robocopy file synchronization between a local source, and a destination
:: Assumes you have access to an authenticated smtp email server, sends alerts on errors >= level 4
::
:: RJ Kunde
:: rj.kunde@gmail.com
:: 5/11/2020
::
:: Note: With /copyall option, must be run from administrative command prompt

:: Directory where batch file resides
@cd /d "%~dp0"

@echo off
setlocal enableextensions
set LogFile=copylog.log
set LocalSource="C:\Source\Destination\Here"

:: If remote destination is an SMB file share:
:: Use following format as opposed to R:\ drive letter:
:: \\servername\share\directory
set RemoteDestination="R:\Remote\Destination\Here"
set ServerName="NameOfServerWhereCopyingHappens"
set ToEmail="ToEmailAddress@gmail.com"
set FromEmail="FromEmailAddress@gmail.com"
set FromEmailPassword="EmailAccountPassword"
set EmailSubject="Error during robocopy on %ServerName%, please re-run the scheduled task!"
set EmailBody="The robocopy operation from %LocalSource% to %RemoteDestination% has failed. Please run the scheduled task located on %ServerName% again. For detailed information, reference the log at %LogLocation%."

:: Required for stunnel
set OutBoundEmailServer="127.0.0.1:1099"

:: Adjust to number of threads your CPU can support
:: 4 or 8 on most modern desktop CPUS, higher for servers
set CPUThreads="8"

:: Robocopy Switch Information
:: See Microsoft documentation: https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/robocopy
::
:: /COPYALL   - Copies all file information
:: /MIR 	     - Mirrors a directory tree (equivalent to /e plus /purge). Deletes destination files that don't exist on source.
:: /NP 		  - Specifies that the progress of the copying operation (the number of files or directories copied so far) will not be displayed.
:: /NFL 	     - Specifies that file names are not to be logged.
:: /NDL		  - Specifies that directory names are not to be logged.
:: /TEE		  - Writes the status output to the console window, as well as to the log file.
:: /LOG 	     - Writes the status output to the log file (overwrites the existing log file).
:: /R:<N>	  - Specifies the number of retries on failed copies. The default value of N is 1,000,000 (one million retries).
:: /W:<N>	  - Specifies the wait time between retries, in seconds. The default value of N is 30 (wait time 30 seconds).
:: /MT[:N]	  - Creates multi-threaded copies with N threads. N must be an integer between 1 and 128. The default value for N is 8.
:: /XO	     - Excludes older files.
:: /ETA       - Shows the estimated time of arrival (ETA) of the copied files.
:: /XF        - Excludes directories that match the specified names and paths.

:: Error Levels
:: if errorlevel 16 echo ***FATAL ERROR*** & goto end
:: if errorlevel 8 echo **FAILED COPIES** & goto end
:: if errorlevel 4 echo *MISMATCHES* & goto end
:: if errorlevel 2 echo EXTRA FILES & goto end
:: if errorlevel 1 echo Copy successful & goto end
:: if errorlevel 0 echo –no change– & goto end

:: Run file copy with options specified above
robocopy.exe %LocalSource% %RemoteDestination% /ETA /MIR /XO /MT:%CPUThreads% /Rr:1 /XD "C:\Users\User\Pictures\Exclude" /XF ".7z" desktop.ini /log+:%LogFile%%

:: Check error level, email error log if greater than or equal to 8 (level 8 indicates a problem has occured)
if errorlevel 8 (
blat.exe -body %EmailBody% -to %ToEmail% -f %FromEmail% -subject %EmailSubject% -server %OutBoundEmailServer% -u %FromEmail% -pw %FromEmailPassword%
)
exit /b