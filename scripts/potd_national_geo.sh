#!/bin/sh
# This Script downloads National Geographic Photo of the day.

image_dir=$1
if [[ -z $image_dir ]]; then
    echo "$1 <dir>"
    exit 1
fi

[[ -d $image_dir ]] && mkdir -p $image_dir

# getting the image URL
img="$(curl -s http://www.nationalgeographic.com/photography/photo-of-the-day/ | grep -oP '(?<='\''aemLeadImage'\'': '\'')[^'\'']*')"

#check to see if there is any wallpaper to download
if [ -n "$img" ]
then
    img_base=`basename $img`
    img_md5=`echo -n $img_base | md5sum | cut -f1 -d" "`
	img_file="${image_dir}/${img_md5}.jpg"

	if [ -f "$img_file" ]
	then
		echo "File already exists"
	else
        curl "$img" > $img_file
		echo "Wallpaper downloaded successfully and saved as $img_file"
	fi
else
	echo "No Wallpaper today"
fi
