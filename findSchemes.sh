#!/bin/bash

# Find all schemes, excluding derived data and build artifacts
echo "" > $XCLI_FOLDER/schemes

find . -name "*.xcscheme" -not -path "*/DerivedData/*" -not -path "*/Build/*" | while IFS= read -r line; do
	schemeFile=$(basename "$line")
	scheme=$(echo "$schemeFile" | cut -f 1 -d "." )
	echo $scheme >> $XCLI_FOLDER/schemes
done

