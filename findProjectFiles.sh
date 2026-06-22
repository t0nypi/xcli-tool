#!/bin/bash

# Find all project files and cache them

find . \( -name "*.xcodeproj" -o -name "*.xcworkspace" \) -a \( -not -path "*.xcodeproj*.xcworkspace" \) > $XCLI_FOLDER/projects
