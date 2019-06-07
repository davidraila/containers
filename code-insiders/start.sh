#!/bin/bash
set -e
set -o pipefail
code-insiders -n --wait $*
#wait $(pgrep code-insiders)
