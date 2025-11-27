#!/bin/bash

# Get the list of explicitly installed packages from pacman, ie. xorg-xwud 1.0.7-1, xscreensaver 6.10.1-1, zsh 5.9-5...
packages_lines=$(pacman --query --explicit -nt)

# dictionary of groups by package name, ie. {"xorg-docs": "xorg", "xorg-xinit": "xorg", "xorg-xmessage": "xorg", ...}
declare -A packages_groups

# dictionary of packages by group name, ie. {"xorg": "xorg-docs\nxorg-xinit\n...", "base": ...}
declare -A packages_by_group

# list of groups that have been printed, ie. {"xorg": 1, "base": 1, ...}
declare -A printed_groups

# read $packages_lines (<<< at the end) a first time
while read -r package_line; do
	# extract the package name only (strip version)
	package_name=$(awk '{print $1}' <<< "$package_line")
	# try to get the group name for the package
	group_name=$(pacman --query --explicit --info "$package_name" | grep '^Groups' | awk -F': ' '{print $2}')

	if [ -n "$group_name" ] && [ "$group_name" != "None" ]; then
		# echo "package $package_name [$group_name]"
		packages_groups["$package_name"]="$group_name"
		# Support multiple groups (rare)
		for single_group in $group_name; do
			packages_by_group["$single_group"]+="$package_name"$'\n'
		done
	else
		# echo "$package_name"
		packages_groups["$package_name"]=""
	fi
done <<< "$packages_lines"

# read $packages_lines (<<< at the end) a second time
while read -r package_line; do
	package_name=$(awk '{print $1}' <<< "$package_line")
	group_name="${packages_groups["$package_name"]}"

	# if the package is not in a group, print it
	if [ -z "$group_name" ]; then
		echo "$package_name"
	# otherwise print the group and its packages (if the group has not been printed yet)
	elif [ -z "${printed_groups["$group_name"]}" ]; then
		echo "$group_name"
		while read -r grouped_package; do
			[ -n "$grouped_package" ] && echo "---$grouped_package"
		done <<< "${packages_by_group["$group_name"]}"
		printed_groups["$group_name"]=1
	fi
done <<< "$packages_lines"