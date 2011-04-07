#!/bin/sh

# Store the current path
pwdPath=$PWD

# Project Templates
xcodeSharedPath="${HOME}/Library/Application Support/Developer/Shared/Xcode/"

# Pixelwave

# Project Templates
templatePaths=( "Project Templates/" "File Templates/" )

len=${#templatePaths[*]}

# Pixelwave

for (( i = 0 ; i < len ; ++i ))
do
    templatePath=${templatePaths[i]}
	tmpPath="${xcodeSharedPath}${templatePath}"
    
    # Create the base folder
	mkdir -p "${tmpPath}"
    
    # Go to the base folder
	cd "${tmpPath}"
	
    # Remove any previous symbolic link
    rm -rf ./Pixelwave
	
	if [ "${1}" != "clean" ]
	then
		# Create the symbolic link here
		ln -sv "${pwdPath}/${templatePath}/Pixelwave" ./Pixelwave
	fi
done

# Go back
cd "${pwdPath}"