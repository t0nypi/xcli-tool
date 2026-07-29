#!/bin/bash

# Find all project files and cache them

find . \( -name "*.xcodeproj" -o -name "*.xcworkspace" \) -d 1 | sed "s/^\.\///" > $XCLI_FOLDER/projects
for project in $(cat $XCLI_FOLDER/projects); do
	if [[ "$project" == *.xcworkspace ]]; then
		workspace_file="$project/contents.xcworkspacedata"
		if [[ -f "$workspace_file" ]]; then
			# Read the Dependencies group and extract FileRef locations
			xmllint --xpath "//Group[@name='Dependencies']/FileRef/@location" "$workspace_file" 2>/dev/null | \
				sed 's/ location="//g' | sed 's/"//g' | sed 's/^group://' | sed 's/^container://' | \
				while IFS= read -r dep; do
					if [[ -n "$dep" && -d "$dep" ]]; then
						echo "$dep" >> "$XCLI_FOLDER/projects"
					fi
				done
		fi
	fi
done
# Remove any duplicates
sort -u -o "$XCLI_FOLDER/projects" "$XCLI_FOLDER/projects"
