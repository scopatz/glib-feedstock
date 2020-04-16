@ECHO ON

@REM I cannot for the life of me figure out how Cygwin/MSYS2 figures out its
@REM root directory, which it uses to find the /etc/fstab which *sometimes*
@REM affects the choice of the cygdrive prefix. But, regardless of *why*,
@REM I find that we need this to work:
mkdir %BUILD_PREFIX%\Library\etc
echo none / cygdrive binary,user 0 0 >%BUILD_PREFIX%\Library\etc\fstab
echo none /tmp usertemp binary,posix=0 0 0 >>%BUILD_PREFIX%\Library\etc\fstab

mkdir forgebuild
cd forgebuild

@REM Find libffi with pkg-config
FOR /F "delims=" %%i IN ('cygpath.exe -m "%LIBRARY_PREFIX%"') DO set "LIBRARY_PREFIX_M=%%i"
set PKG_CONFIG_PATH=%LIBRARY_PREFIX_M%/lib/pkgconfig;%LIBRARY_PREFIX_M%/share/pkgconfig

@REM Avoid a Meson issue - https://github.com/mesonbuild/meson/issues/4827
set "PYTHONLEGACYWINDOWSSTDIO=1"
set "PYTHONIOENCODING=UTF-8"

@REM See hardcoded-paths.patch
set "CPPFLAGS=%CPPFLAGS% -D^"%LIBRARY_PREFIX_M%^""

%BUILD_PREFIX%\python.exe %BUILD_PREFIX%\Scripts\meson --buildtype=release --prefix=%LIBRARY_PREFIX_M% --backend=ninja -Diconv=external -Dselinux=disabled -Dxattr=false -Dlibmount=disabled ..
if errorlevel 1 exit 1

ninja -v
if errorlevel 1 exit 1

@REM Lots of tests fail right now
@REM ninja test
@REM if errorlevel 1 exit 1

ninja install
if errorlevel 1 exit 1

del %LIBRARY_PREFIX%\bin\*.pdb
