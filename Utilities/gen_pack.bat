:: Batch file for generating CMSIS-FreeRTOS pack
:: This batch file uses:
::    7-Zip for packaging
::    Doxygen version 1.8.2 and Mscgen version 0.20 for generating html documentation.
:: The generated pack and pdsc file are placed in folder %RELEASE_PATH% (../../Local_Release)
@ECHO off

SETLOCAL

:: Tool path for zipping tool 7-Zip
SET ZIPPATH=C:\Program Files\7-Zip

:: Tool path for doxygen
SET DOXYGENPATH=C:\Program Files\doxygen\bin

:: Tool path for mscgen utility
SET MSCGENPATH=C:\Program Files (x86)\Mscgen

:: These settings should be passed on to subprocesses as well
SET PATH=%ZIPPATH%;%DOXYGENPATH%;%MSCGENPATH%;%PATH%

:: Pack Path (where generated pack is stored)
SET RELEASE_PATH=..\..\Local_Release

:: !!!!!!!!!!!!!!!!!
:: DO NOT EDIT BELOW
:: !!!!!!!!!!!!!!!!! 

:: Remove previous build
IF EXIST %RELEASE_PATH% (
  ECHO removing %RELEASE_PATH%
  RMDIR /Q /S  %RELEASE_PATH%
)

:: Create build output directory
MKDIR %RELEASE_PATH%


:: Copy PDSC file
COPY .\..\ARM.CMSIS-FreeRTOS.pdsc %RELEASE_PATH%\ARM.CMSIS-FreeRTOS.pdsc

:: Copy LICENSE file
REM COPY .\..\LICENSE.txt %RELEASE_PATH%\LICENSE.txt

:: Copy various root files
COPY .\..\readme.txt %RELEASE_PATH%\readme.txt
COPY .\..\links_to_doc_pages_for_the_demo_projects.url %RELEASE_PATH%\links_to_doc_pages_for_the_demo_projects.url

:: Copy CMSIS folder
XCOPY /Q /S /Y .\..\CMSIS\*.* %RELEASE_PATH%\CMSIS\*.*

:: Copy Config folder
XCOPY /Q /S /Y .\..\Config\*.* %RELEASE_PATH%\Config\*.*

:: Copy Demo folder
XCOPY /Q /S /Y .\..\Demo\*.* %RELEASE_PATH%\Demo\*.*

:: Copy License folder
XCOPY /Q /S /Y .\..\License\*.* %RELEASE_PATH%\License\*.*

:: Copy Source folder
XCOPY /Q /S /Y .\..\Source\*.* %RELEASE_PATH%\Source\*.*


:: Generate Documentation 
:: -- Generate doxygen files 
PUSHD ..\DoxyGen

:: -- Delete previous generated HTML files
ECHO.
ECHO Delete previous generated HTML files

PUSHD ..\Documentation
RMDIR /S /Q General
REM FOR %%A IN (Core, DAP, Driver, DSP, General, Pack, RTOS, RTOS2, SVD) DO IF EXIST %%A (RMDIR /S /Q %%A)
POPD

:: -- Generate HTML Files
ECHO.
ECHO Generate HTML Files

pushd General
doxygen general.dxy
popd

:: -- Copy search style sheet
ECHO.
ECHO Copy search style sheets
copy /Y Doxygen_Templates\search.css ..\Documentation\General\html\search\. 
  
ECHO.
POPD

:: -- Copy generated doxygen files 
XCOPY /Q /S /Y ..\Documentation\*.* %RELEASE_PATH%\CMSIS\Documentation\*.*

:: -- Remove generated doxygen files
PUSHD ..\Documentation
RMDIR /S /Q General
REM FOR %%A IN (Core, DAP, Driver, DSP, General, Pack, RTOS, RTOS2, SVD) DO IF EXIST %%A (RMDIR /S /Q %%A)
POPD


:: Checking 
Win32\PackChk.exe %RELEASE_PATH%\ARM.CMSIS-FreeRTOS.pdsc -n %RELEASE_PATH%\PackName.txt -x M353 -x M364

:: --Check if PackChk.exe has completed successfully
IF %errorlevel% neq 0 GOTO ErrPackChk

:: Packing 
PUSHD %RELEASE_PATH%

:: -- Pipe Pack's Name into Variable
SET /P PackName=<PackName.txt
DEL /Q PackName.txt

:: Pack files
ECHO Creating pack file ...
7z.exe a %PackName% -tzip > zip.log
ECHO Packaging complete
POPD
GOTO End

:ErrPackChk
ECHO PackChk.exe has encountered an error!
EXIT /b

:End
ECHO Removing temporary files and folders
RMDIR /Q /S  %RELEASE_PATH%\CMSIS
RMDIR /Q /S  %RELEASE_PATH%\Config
RMDIR /Q /S  %RELEASE_PATH%\Demo
RMDIR /Q /S  %RELEASE_PATH%\License
RMDIR /Q /S  %RELEASE_PATH%\Source
DEL %RELEASE_PATH%\links_to_doc_pages_for_the_demo_projects.url
DEL %RELEASE_PATH%\readme.txt
DEL %RELEASE_PATH%\zip.log

ECHO gen_pack.bat completed successfully
