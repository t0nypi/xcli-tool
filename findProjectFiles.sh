#!/bin/bash

# Find all project files and cache them

find . \( -name "*.xcodeproj" -o -name "*.xcworkspace" \) -d 1 | sed "s/^\.\///" > $XCLI_FOLDER/projects
