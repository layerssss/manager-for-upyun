cd nodebob
del /Q release
call build.bat
copy ..\registerurl.cmd release\registerurl.cmd
del /Q manager-for-upyun-win32.7z
cd release
rename nw.exe UpYunManager.exe
..\buildTools\7z\7z.exe a ..\manager-for-upyun-win32.7z *
cd ..
call "c:\Program Files (x86)\7z SFX Builder\7z SFX Builder.exe" y:\manager_for_upyun\7zsfxbuilder.txt
