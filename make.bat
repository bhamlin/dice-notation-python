@ECHO OFF

REM Makefile-like batch file for the Python project.
REM It supports creating distribution files, and deploying them to Pypi and Pypitest or installing them locally
REM
REM A Python interpreter is required, and it should be accessible from the command line.
REM This file should be run from the project's root folder.
REM
REM To deploy or register to Pypi or Pypitest a valid .pypirc file should be accessible on the default location.

REM Sets the variables
REM Sets the Python executable.
REM It will be the executable for the interpreter set up for the command line.
if "%PYTHON%" == "" (
	set PYTHON=python
)

REM Sets the distribution folder.
REM It will be the 'dist' folder.
if "%DISTDIR%" == "" (
	set DISTDIR=dist
)

REM Sets the .egg file path.
REM The file will be located at the project's root.
if "%EGGDIR%" == "" (
	set EGGDIR=dice_notation.egg-info
)

REM Sets the tox folder path.
REM It will be the '.tox' folder.
if "%TOXDIR%" == "" (
	set TOXDIR=.tox
)

REM Sets the docs output folder path.
REM It will be in the 'docs' folder.
if "%DOCBUILDDIR%" == "" (
	set DOCDIR="docs"
	set DOCBUILDDIR="build"
)

REM If no parameters are received, the help is shown
if "%1" == "" goto help

REM Help option
REM Shows the allowed commands to be received as parameters
if "%1" == "help" (
	:help
	echo.Please use `make ^<target^>` where ^<target^> is one of
	echo.  clean          to remove the distribution folders
	echo.  build          to build the distribution
	echo.  install        to install the project
	echo.  requirements   to install the project requirements
	echo.  register       to register on pypi
	echo.  register-test  to register on pypi-test
	echo.  deploy         to deploy to pypi
	echo.  deploy-test    to upload to pypi-test
	echo.  test           to run tests
	goto end
)

REM Clean option
REM Removes the distribution folder and the .egg file
if "%1" == "clean" (
	if exist %DISTDIR% (
		rd /S /Q %DISTDIR%
	)
	if exist %EGGDIR% (
		rd /S /Q %EGGDIR%
	)
	if exist %TOXDIR% (
		rd /S /Q %TOXDIR%
	)
	if exist "%DOCDIR%/%DOCBUILDDIR%" (
		cd %DOCDIR%
		rd /S /Q %DOCBUILDDIR%
		cd ..
	)
	goto end
)


REM Checks if the interpreter is available.
%PYTHON% -V> nul
if errorlevel 9009 goto missing_interpreter
goto interpreter_ok

REM Missing interpreter.
REM The process will end and a warning will be shown.
:missing_interpreter

echo.
echo.The '%PYTHON%' command was not found. Make sure you have a
echo.version of the python interpreter installed, then add the
echo.directory where it was installed to the PATH.
echo.
exit /b 1

:interpreter_ok


REM Distribution.
if "%1" == "build" (
	%PYTHON% setup.py sdist
	if errorlevel 1 exit /b 1
	echo.
	echo.Generated source distribution. It can be found in the
	echo.%DISTDIR% folder.
	goto end
)

REM Install in local libraries repository.
if "%1" == "install" (
	%PYTHON% setup.py install
	if errorlevel 1 exit /b 1
	echo.
	echo.Installed the project into the local repository.
	goto end
)

REM Install the project requirements
if "%1" == "requirements" (
	pip install --upgrade -r requirements.txt
)

REM Pypi registration.
if "%1" == "register" (
	%PYTHON% setup.py register -r pypi
	if errorlevel 1 exit /b 1
	echo.
	echo.Registered project on pypi.
	goto end
)

REM Pypitest registration.
if "%1" == "register-test" (
	%PYTHON% setup.py register -r pypitest
	if errorlevel 1 exit /b 1
	echo.
	echo.Registered project on pypitest.
	goto end
)

REM Pypi deployment.
if "%1" == "deploy" (
	%PYTHON% setup.py sdist
	twine upload dist/*
	if errorlevel 1 exit /b 1
	echo.
	echo.Uploaded project to pypi.
	goto end
)

REM Pypitest deployment.
if "%1" == "deploy-test" (
	%PYTHON% setup.py sdist upload -r pypitest
	if errorlevel 1 exit /b 1
	echo.
	echo.Uploaded project to pypitest.
	goto end
)

REM Tests suite.
if "%1" == "test" (
	tox
)

:end
