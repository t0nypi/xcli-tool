#!/bin/bash

# Helper: list all Xcode devices and simulators
# Outputs lines in format: "Name" identifier (Device|Simulator)
listDevices() {
	xcrun xctrace list devices | awk '
	function printNameAndIdentifier(type) {
			name = ""
			if (match($0, /[^(]*\(/)) {
				name = substr($0, RSTART, RLENGTH-2)
			}

			identifier = substr($NF, 2, length($NF)-2)

			printf("\"%s\" %s (%s)\n", name, identifier, type)
		}

		/== Devices/,/== Simulator/ {
			if(!/(^==|^$)/) {
				printNameAndIdentifier("Device")
			}
		}

		/== Simulator/ {found=1} found {
			if(!/(^==|^$)/) {
				printNameAndIdentifier("Simulator")
			}
		}
	'
}
