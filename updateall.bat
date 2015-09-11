@echo off
where /q tee
if %ERRORLEVEL% equ 0 (
	updateall_impl.bat | tee updateall.log
) else (
	updateall_impl.bat > updateall.log
)
