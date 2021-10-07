#!/bin/bash

# Exit if any command throws an error
set -e

# Get the project and module names from command line args
# Probably want to make it so that we only need to provide one later
if [ $# != 2 ]
  then
    echo "Run this with two args: the project name and the module name."
    echo "E.g.: ${0} liquidity-bridge LiquidityBridge"
    exit 1
fi
PROJECT_NAME=$1
MODULE_NAME=$2

# Modify the cabal file
CABAL_FILE="${PROJECT_NAME}.cabal"
NEW_GITHUB_LINK="https://github.com/mlabs-haskell/${PROJECT_NAME}"
OLD_GITHUB_LINK="https://github.com/mlabs-haskell/CardStarter-LiquidityBridge"

mv liquidity-bridge.cabal $CABAL_FILE
sed -i "s|${OLD_GITHUB_LINK}|${NEW_GITHUB_LINK}|g" $CABAL_FILE
sed -i "s|liquidity-bridge|${PROJECT_NAME}|g" $CABAL_FILE
sed -i "s|LiquidityBridge|${MODULE_NAME}|g" $CABAL_FILE

# Modify hie.yaml, ci.nix, and integrate.yaml
sed -i "s|liquidity-bridge|${PROJECT_NAME}|g" hie.yaml
sed -i "s|liquidity-bridge|${PROJECT_NAME}|g" nix/ci.nix
sed -i "s|liquidity-bridge|${PROJECT_NAME}|g" .github/workflows/integrate.yaml

# Modify the dummy source file
sed -i "s|LiquidityBridge|${MODULE_NAME}|" src/LiquidityBridge.hs
mv src/LiquidityBridge.hs src/${MODULE_NAME}.hs

# Create the cabal.project.local file with the sodium flag
echo "package cardano-crypto-praos" >> cabal.project.local
echo "  flags: -external-libsodium-vrf" >> cabal.project.local

# Perform initial setup
nix-shell --run "cabal build && cabal test"