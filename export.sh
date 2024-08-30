#!/bin/bash

# Define paths and project details
GAME_NAME="YourGame"
LOVE_VERSION="11.3"   # Specify the version of LÖVE you are targeting
GAME_DIR="game"
EXPORT_DIR="export"

# Create export directory if it doesn't exist
mkdir -p $EXPORT_DIR

# Combine the game and engine into a single .love file
echo "Packaging game into ${GAME_NAME}.love..."
cd $GAME_DIR
zip -9 -r ../$EXPORT_DIR/${GAME_NAME}.love . ../engine
cd ..

# Define paths to Love2D binaries
LOVE_WINDOWS="/path/to/love-${LOVE_VERSION}-win32"  # Change this to your Love2D path
LOVE_MACOS="/path/to/love-${LOVE_VERSION}-macos"    # Change this to your Love2D path

# Export for Windows
echo "Exporting for Windows..."
cat ${LOVE_WINDOWS}/love.exe $EXPORT_DIR/${GAME_NAME}.love > $EXPORT_DIR/${GAME_NAME}.exe
cp ${LOVE_WINDOWS}/*.dll $EXPORT_DIR/

# Export for macOS
echo "Exporting for macOS..."
cp -r ${LOVE_MACOS}/love.app $EXPORT_DIR/${GAME_NAME}.app
cp $EXPORT_DIR/${GAME_NAME}.love $EXPORT_DIR/${GAME_NAME}.app/Contents/Resources/

# Additional steps can be added for Linux or other platforms as needed
echo "Export completed. Files are located in the ${EXPORT_DIR} directory."
