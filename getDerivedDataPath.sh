#!/bin/bash

getDerivedDataPath() {
	folder=$(basename $PWD)
	branch=$(git rev-parse --abbrev-ref HEAD )
	derivedDataFolder="$XCODE_CUSTOM_DERIVED_DATA/$folder/$branch"

	mkdir -p $derivedDataFolder

	echo $derivedDataFolder
}
