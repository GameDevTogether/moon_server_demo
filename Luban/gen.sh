#!/bin/zsh
scriptPath=`pwd`
GEN_CLIENT=$scriptPath/ArmTools/Luban.ClientServer/Luban.ClientServer.dll
rm -r $scriptPath/../static/table
dotnet ${GEN_CLIENT} -j cfg --\
 -d Defines/__root__.xml \
 --input_data_dir Datas \
 --output_data_dir $scriptPath/../static/table \
 --output_code_dir Gen \
 --gen_types code_lua_lua,data_lua \
 -s server 

mv $scriptPath/Gen/Types.lua ../common
rmdir /s /q "$scriptPath/Gen"