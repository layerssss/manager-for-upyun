#!/bin/bash -e
echo "nodebob v0.1"
echo "---"
echo
CUR_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


echo "Creating bundle for win32..."
mkdir -p release.win32
rm -f release.win32/app.nw
zip -b app -r release.win32/app.nw app/*
cat buildTools/nw/nw.exe release.win32/app.nw > release.win32/app.exe
if [ ! -f release.win32/nw.pak ]; then
  cp buildTools/nw/nw.pak release.win32/nw.pak
fi
if [ ! -f release.win32/ffmpegsumo.dll ]; then
  cp buildTools/nw/ffmpegsumo.dll release.win32/ffmpegsumo.dll
fi
if [ ! -f release.win32/icudt.dll ]; then
  cp buildTools/nw/icudt.dll release.win32/icudt.dll
fi
if [ ! -f release.win32/libEGL.dll ]; then
  cp buildTools/nw/libEGL.dll release.win32/libEGL.dll
fi
if [ ! -f release.win32/libGLESv2.dll ]; then
  cp buildTools/nw/libGLESv2.dll release.win32/libGLESv2.dll
fi

echo "Deleting temporary files..."
rm -f release.win32/app.nw
echo "Done!"
