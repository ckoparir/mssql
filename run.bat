::--------------------------------------------------------
:: This script calls needs the required params from user 
:: to be able to connect to the sql server & database  
:: then excutes the altertable.sql in the root
::
::  Example  : 
::  ______________________________________________________________
::
::   ./run.bat 
::
::   Enter Server IP or Hostname   : example.com
::   Enter database name           : testdb
::   Enter username                : <database username>
::
::   Connecting example.com...
::
::   Password                      : <Password for testdb database>
::
::______________________________________________________________
::
:: Date     : 20.12.2022
:: Filname  : run.bat
:: Author   : ckoparir@gmail.com
::
::--------------------------------------------------------

@echo off

set /p server="Enter Server IP or Hostname: "
set /p database="Enter database name: "
set /p user="Enter username: "

echo connecing %server%...

call sqlcmd -S %server% -U %user% -d %database% -i altertable.sql

if %ERRORLEVEL% EQU 0 (
    echo Sql command finished successfully...
) else (
    echo Error occoured while executing sql command...! Please check the hostname, database name, username or password and try again. 
)