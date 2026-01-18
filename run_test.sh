#!/bin/bash
set -e

PROJECT_ROOT=$(pwd)
LEAN_SYS_PATH=$(elan which lean | sed 's|/bin/lean||')
LEAN_SYS_LIB="$LEAN_SYS_PATH/lib/lean"

echo "🔨 Re-building Trojan Stub..."
# スタブをコンパイル（physics_engineの下に作成）
clang -shared -fPIC -o "$PROJECT_ROOT/physics_engine/libLeanTrojan.so" "$PROJECT_ROOT/trojan_ultimate.c"

echo "🚀 Launching Strict Bridge Test with Stub Injection..."

# ここが肝：libLeanTrojan.so を先頭に配置
export LD_PRELOAD="$PROJECT_ROOT/physics_engine/libLeanTrojan.so:$LEAN_SYS_LIB/libleanshared.so"
export LD_LIBRARY_PATH=".:$LEAN_SYS_LIB:$LD_LIBRARY_PATH"

mojo test_interface.mojo
