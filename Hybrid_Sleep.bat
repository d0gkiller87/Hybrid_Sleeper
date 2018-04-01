@echo off

setlocal ENABLEDELAYEDEXPANSION

:start

REM --Init-- / 初始化
for /f "tokens=2 delims=:" %%a in ('powercfg -GETACTIVESCHEME') do for /f "delims= " %%b in ("%%a") do (set "active_scheme=%%b")
set "AC=-SetACValueIndex %active_scheme% 238c9fa8-0aad-41ed-83f4-97be242c8f20 94ac6d29-73ce-41a6-809f-6363ba21b47e"
set "DC=-SetDCValueIndex %active_scheme% 238c9fa8-0aad-41ed-83f4-97be242c8f20 94ac6d29-73ce-41a6-809f-6363ba21b47e"

REM Get Hybrid_Sleep State / 取得混合式睡眠當前設定
set flag=0
set hybri=0
for /f "skip=15 delims=" %%a in ('powercfg -Q %active_scheme% 238c9fa8-0aad-41ed-83f4-97be242c8f20') do (
	if !flag! lss 2 (
		set process=%%a
		set /a hybri+=!process:~-1!
	)
	set /a flag+=1
)
if %hybri% lss 2 (
	set Hybrid_Sleep_Index=0
	set Hybrid_Sleep=Off
) else (
	set Hybrid_Sleep_Index=1
	set Hybrid_Sleep=On
)

REM Get Hibernate State / 取得休眠當前設定
if exist "%SystemDrive%\hiberfil.sys" (
	set Hibernate=On
	set flag=0
	for /f "skip=4 tokens=4 delims= " %%a in ('dir /A %SystemDrive%\hiberfil.sys') do (
		if "!flag!"=="0" (set "file_size= (%%a Bytes)")
		set /a flag+=1
	)
) else (
	set Hibernate=Off
	set file_size=
)

REM Give Choices & Take Actions / 提供動作選項並進行修改
choice /C 12q /N /M "1=Hibernate[%Hibernate%]%file_size% // 2=Hybrid_Sleep[%Hybrid_Sleep%] // Q=Exit: "
set Opiton=%errorlevel%

if %Hibernate%==Off (set Hibernate=On) else (set Hibernate=Off)
set /a Hybrid_Sleep_Index=1-%Hybrid_Sleep_Index%

if %Opiton%==1 (
	if %Hibernate%==Off (set Hibernate=On) else (set Hibernate=Off)
	powercfg -H %Hibernate%
)
if %Opiton%==2 (
	powercfg %AC% %Hybrid_Sleep_Index%
	powercfg %DC% %Hybrid_Sleep_Index%
)
if %Opiton%==3 (exit /b)

cls
goto start