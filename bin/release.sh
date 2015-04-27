#!/usr/bin/env bash
# bin/release <build-dir>

# important directories: https://gist.github.com/fe7f04abbd9538b656c5
BUILD_DIR=$1

# try to find a suitable directory to start the app from
WEB_ROOT="."
if [ ! -d "${BUILD_DIR}/bin" ]; then
  # assume there's only one .sln because we check for that in compile
  SLN=$( find "$BUILD_DIR" -maxdepth 1 -iname "*.sln" )

  if [ "${SLN}" != "" ]; then
    SLN="${SLN##$BUILD_DIR}"
    SLN="${SLN##\.}"
    SLN="${SLN##\/}"
    SLN="${SLN%%\.[sS][lL][nN]}"

    if [ -d "${BUILD_DIR}/${SLN}" ]; then
      WEB_ROOT=/app/$SLN
    fi
  fi
fi

cat <<EOF
---
config_vars:
  PATH: /app/mono/bin:/app/xsp/bin:/usr/local/bin:/usr/bin:/bin
default_process_types:
  web: /app/xsp/bin/xsp4 --nonstop --port \$PORT --root "$WEB_ROOT"
EOF
