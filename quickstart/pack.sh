#!/bin/bash

# Create the quickstart directory
mkdir -p quickstart

# Copy files and folder into quickstart
cp main.lua readme.md quickstart/
cp -r trails quickstart/

# Create a zip archive of the quickstart folder
zip -r quickstart.zip quickstart/

rm -rf quickstart

echo "Files packed into quickstart.zip"
