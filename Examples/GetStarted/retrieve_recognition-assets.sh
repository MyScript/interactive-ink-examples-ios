#!/bin/bash

# MyScript examples recognition assets retriever.
# It should only be used with sample apps.
# Not for commercial use intents.

if [[ $# -eq 0 ]] ; then
    echo "Error: No project root folder argument supplied."
    echo "usage: ./retrieve_recognition-assets.sh path"
    exit 1
fi

ProjectRootFolder=$1

if [ ! -f "$ProjectRootFolder/Resources/recognition-assets/conf/diagram.conf" ] || [ ! -f "$ProjectRootFolder/Resources/recognition-assets/conf/raw-content.conf" ] || [ ! -f "$ProjectRootFolder/Resources/recognition-assets/conf/math.conf" ] || [ ! -f "$ProjectRootFolder/Resources/recognition-assets/conf/en_US.conf" ]; then

echo MyScript en-US recognition assets retriever

curl -O https://s3-us-west-2.amazonaws.com/iink/assets/1.3.0/myscript-iink-recognition-diagram.zip
unzip -o myscript-iink-recognition-diagram.zip -d $ProjectRootFolder/Resources/

curl -O https://s3-us-west-2.amazonaws.com/iink/assets/1.3.0/myscript-iink-recognition-raw-content.zip
unzip -o myscript-iink-recognition-raw-content.zip -d $ProjectRootFolder/Resources/

curl -O https://s3-us-west-2.amazonaws.com/iink/assets/1.3.0/myscript-iink-recognition-math.zip
unzip -o myscript-iink-recognition-math.zip -d $ProjectRootFolder/Resources/

curl -O https://s3-us-west-2.amazonaws.com/iink/assets/1.3.0/myscript-iink-recognition-text-en_US.zip
unzip -o myscript-iink-recognition-text-en_US.zip -d $ProjectRootFolder/Resources/

rm myscript-iink-recognition-diagram.zip
rm myscript-iink-recognition-raw-content.zip
rm myscript-iink-recognition-math.zip
rm myscript-iink-recognition-text-en_US.zip

fi
