git clone https://github.com/lecopivo/SciLean.git

# 1. 依存関係の同期（今度は通るはずです）
pixi install
# 2. SciLeanディレクトリへ移動
cd SciLean

# 3. 環境変数を明示的に指定してビルド
# Pixiがインストールした include と lib を、コンパイラ(gcc/clang)に直接教えます
export PIXI_ROOT=$HOME/workspace/YuXiGe/Aquatones-ALETHEIA/.pixi/envs/default
export C_INCLUDE_PATH=$PIXI_ROOT/include
export CPLUS_INCLUDE_PATH=$PIXI_ROOT/include
export LIBRARY_PATH=$PIXI_ROOT/lib
export LD_LIBRARY_PATH=$PIXI_ROOT/lib:$LD_LIBRARY_PATH

# 4. ビルド実行
lake build

cd ../
mkdir physics_engine
cd physics_engine
# 依存関係を管理するための初期化
lake init PhysicsOracle lib

# 既存の TOML 設定を削除（混乱を防ぐため）
rm lakefile.toml

# 新しい lakefile.lean を作成
cat <<EOF > lakefile.lean
import Lake
open Lake DSL

package physics_oracle where
  precompileModules := true

@[default_target]
lean_lib PhysicsOracle where

require scilean from ".." / "SciLean"
EOF

# 依存関係（SciLean）を認識させる
lake update

# 共有ライブラリ (.so) をビルド
lake build PhysicsOracle:shared



# 一時的に LD_LIBRARY_PATH を空にして mathlib のキャッシュ取得コマンドを叩く
LD_LIBRARY_PATH="" lake exe cache get

# 共有ライブラリのビルド
lake build PhysicsOracle:shared

cd ../

cat <<EOF > audit_engine.mojo
from sys import OwnedDLHandle

def main():
    print("--- Aquatones-ALETHEIA: 物理監査エンジン始動 ---")
    try:
        # ドキュメントに基づき、OwnedDLHandle を使用
        var handle = OwnedDLHandle("libPhysicsOracle.so")
        print("✅ 物理Oracle（真理）の接続に成功しました")
        # handle はスコープを抜けると自動的にクローズされます
    except e:
        print("❌ 実行エラー:", e)
    print("--- 監査プロセス終了 ---")
EOF


# 1. パス設定 (Pixi環境、Leanシステム、PhysicsOracle)
PIXI_LIB=$HOME/workspace/YuXiGe/Aquatones-ALETHEIA/.pixi/envs/default/lib
LEAN_SYS_LIB=$HOME/.elan/toolchains/leanprover--lean4---v4.20.1/lib/lean
ORACLE_LIB=$(pwd)/physics_engine/.lake/build/lib

export LD_LIBRARY_PATH=$ORACLE_LIB:$LEAN_SYS_LIB:$PIXI_LIB:$LD_LIBRARY_PATH

# 2. LD_PRELOAD 設定 (依存関係を最優先で解決)
# SciLeanが依存する Batteries も含めます
BATTERIES_SO=$(find $(pwd) -name "libBatteries.so" | head -n 1)
ORACLE_SO=$ORACLE_LIB/libPhysicsOracle.so

export LD_PRELOAD="$LEAN_SYS_LIB/libleanshared.so:$BATTERIES_SO:$ORACLE_SO"

# 3. 監査エンジン始動！
mojo audit_engine.mojo