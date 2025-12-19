:: cat
(
echo @echo OFF
echo type %*
) > cat.bat

:: clear
(
echo @echo OFF
echo cls
) > clear.bat

:: cp
(
echo @echo OFF
echo copy %*
) > cp.bat

:: grep
(
echo @echo OFF
echo findstr %*
) > grep.bat

:: ls
(
echo @echo OFF
echo dir %*
) > ls.bat

:: mv
(
echo @echo OFF
echo ren %*
) > mv.bat

:: rm
(
echo @echo OFF
echo del %* 2>nul
) > rm.bat

:: vim
(
echo @echo OFF
echo notepad %*
) > vim.bat
