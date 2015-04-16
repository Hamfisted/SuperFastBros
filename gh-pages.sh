#!/bin/bash

set -e # Terminate this script as soon as any command fails

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $SCRIPT_DIR

git rebase master

lime build flash
# lime build html5

cp -r Export/flash/bin/* ./demo/flash/
# cp -r Export/html5/bin/* ./demo/html5/

echo "Build successful."
