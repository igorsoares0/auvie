#!/usr/bin/env bash
# Local CI: codegen → format → analyze → Dart tests → Kotlin JVM tests.
# Device-bound suites (connectedDebugAndroidTest, patrol) are separate because
# they need an emulator; see docs/PLANO-IMPLEMENTACAO-ANDROID.md §5.
#
# Usage: tool/ci.sh            (FLUTTER/DART override the binaries if needed)
set -euo pipefail

cd "$(dirname "$0")/.."
FLUTTER="${FLUTTER:-flutter}"
DART="${DART:-dart}"

step() { printf '\n== %s\n' "$1"; }

step "pub get"
"$FLUTTER" pub get

step "codegen"
"$DART" run build_runner build -d

step "format"
"$DART" format --output=none --set-exit-if-changed lib test

step "analyze"
"$FLUTTER" analyze

step "dart tests"
"$FLUTTER" test --coverage

step "kotlin unit tests"
(cd android && ./gradlew :app:testDebugUnitTest)
