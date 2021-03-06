#!/bin/sh
# bin/compile <build-dir> <cache-dir>

MONO3_VM_BINARY="http://s3.amazonaws.com/mono3-buildpack/mono-fsharp-nuget3.0.tar.bz2"
NUGET_BINARY="http://s3.amazonaws.com/mono3-buildpack/nuget.tar.bz2"
MONO3_VM_VENDOR="vendor"

NUGET="$1/$MONO3_VM_VENDOR/mono3/bin/NuGet.exe"
MOZROOT="$1/$MONO3_VM_VENDOR/mono3/lib/mono/4.5/mozroots.exe"
XBUILD="$1/$MONO3_VM_VENDOR/mono3/lib/mono/4.5/xbuild.exe"

echo "-----> Copying mono to $1/$MONO3_VM_VENDOR"
mkdir -p "$1/$MONO3_VM_VENDOR"
curl $MONO3_VM_BINARY -o - | tar xj -C "$1/$MONO3_VM_VENDOR" -f -
curl $NUGET_BINARY -o - | tar xj -C "$1/$MONO3_VM_VENDOR/mono3/bin/" -f -

echo "#!/bin/sh\n$1/$MONO3_VM_VENDOR/mono3/bin/mono $1/$MONO3_VM_VENDOR/mono3/lib/mono/4.5/fsc.exe \"\$@\"" > $1/$MONO3_VM_VENDOR/mono3/bin/fsharpc-heroku
chmod +x $1/$MONO3_VM_VENDOR/mono3/bin/fsharpc-heroku

echo "-----> Setting envvars"
export PATH="$PATH:$1/$MONO3_VM_VENDOR/mono3/bin"
export LD_LIBRARY_PATH="$1/$MONO3_VM_VENDOR/mono3/lib"
echo "-----> Importing trusted root certificates"
mono $MOZROOT --sync --import
cd $1

echo "-----> Setting up nuget"
mono $NUGET update -self

if [ -f $1/*/packages.config ]; then
  echo "-----> Installing dependencies with nuget"
  find $1/ -name packages.config | xargs mono $NUGET install -o packages
fi

echo "-----> Compiling application"
mono $XBUILD /property:FscToolExe="$1/$MONO3_VM_VENDOR/mono3/bin/fsharpc-heroku"
