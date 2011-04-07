#!/bin/bash
# see http://github.com/tomaz/appledoc

# Vars
PROJ_NAME="Pixelwave"

SRC_PATH="../Pixelwave"

ATOM_FILE="docset.atom"
DOCSET_FILE="com.spiralstorm.Pixelwave.API_Reference.docset"
XAR_FILE="com.spiralstorm.Pixelwave.API_Reference.xar"
XAR_URL="http://www.pixelwave.org/download/"

ATOM_BIN_PATH="output/Atom_bin"

#rm -rf bin
rm -rf output

# Create the docset
appledoc -p $PROJ_NAME -i $SRC_PATH -o output/appledoc -t ./appledocTemplate

#echo "${XAR_URL}${XAR_FILE}"

mkdir $ATOM_BIN_PATH

# Creating the package and atom feed
/Developer/usr/bin/docsetutil package -output $ATOM_BIN_PATH/$XAR_FILE -atom $ATOM_BIN_PATH/$ATOM_FILE output/$DOCSET_FILE -download-url "${XAR_URL}${XAR_FILE}"