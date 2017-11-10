@echo off
setlocal EnableDelayedExpansion

SET UNIX_PREFIX=%CYGWIN_PREFIX:~9%
echo UNIX_PREFIX is %UNIX_PREFIX%

SET _PY=%PYTHON%
SET PYTHON=python

bash configure --prefix %UNIX_PREFIX% --enable-static --enable-shared --disable-documentation ^
               --with-python=%PYTHON% ^
			   --disable-libmount
if errorlevel 1 exit 1

make -j %CPU_COUNT%
if errorlevel 1 exit 1

make install
if errorlevel 1 exit 1

SET PYTHON=%_PY%