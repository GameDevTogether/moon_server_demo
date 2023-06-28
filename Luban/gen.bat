set scriptPath=%~dp0
set GEN_CLIENT=dotnet %scriptPath%\Tools\Luban.ClientServer\Luban.ClientServer.dll
set ASSETS_PATH=%scriptPath%..\static\table

set TYPELUAPATH=%ASSETS_PATH%\..\common\

%GEN_CLIENT% -j cfg --^
 -d Defines\__root__.xml ^
 --input_data_dir Datas ^
 --output_code_dir %TYPELUAPATH% ^
 --output_data_dir %ASSETS_PATH% ^
 --gen_types code_lua_lua,data_lua ^
 -s server 


move %TYPELUAPATH%Types.lua %ASSETS_PATH%\..\..\common
rmdir /s /q "%TYPELUAPATH%"

pause