#!/bin/bash

parseDestination() {
	selectedDestination=$1
	simulator=1

	if [[ "${selectedDestination}" =~ \(Device\)$ ]]; then
		simulator=0
	fi

	if [[ $(echo $selectedDestination) =~ "^Name: " ]]; then
		trimmed=$(echo $selectedDestination | sed "s/Name: \"\(.*\)\"/\1/" | sed "s/\((Simulator)|(Device)\)//")
		echo "platform=$([[ $simulator == 1 ]] && echo "iOS Simulator" || echo "iOS"),name=$trimmed"
	else
		trimmed=$(echo $selectedDestination | awk '{ print $(NF-1) }')
		echo "platform=$([[ $simulator == 1 ]] && echo "iOS Simulator" || echo "iOS"),id=$trimmed"
	fi
}
