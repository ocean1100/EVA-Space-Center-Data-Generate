#!/bin/bash

local_dataset_path='/data/Dataset_all_random'
single_img_folder='/home/eva/space_center/moon_8K/Single_Image/'
object="Moon_8K.obj"

git pull
echo 'Start checking original dataset'
rm "../generate_single_image.py"
cp "generate_single_image.py" "../"
rm "../config.py"
cp "config.py" "../"

for i in $(seq 5 5)
do
  for j in $(seq 0 0)
  do
    for img in "${local_dataset_path}/$i/${i}_$j"/*.png
#    for img in $(ls "${local_dataset_path}/$i/${i}_$j/")
    do
      OIFS="$IFS"
      IFS='/'
      read -r -a new_string <<< "${img}"
      IFS="$OIFS"
      echo "${new_string[5]}"
      pngcheck -q "${new_string[5]}"
      retval=$?
      if [ $retval -ne 0 ]; then
        echo "${img}"
        cd "../" && python "generate_single_image.py ${object} ${img}"
#        rm "${local_dataset_path}/$i/${i}_$j/$img"
#        cp "${single_img_folder}/$img" "${local_dataset_path}/$i/${i}_$j/"
      fi
    done
  done
done

#echo 'End checking original dataset'
#
#img="Dataset_all_random_50377.png"
#pngcheck -q "${local_dataset_path}/5/5_0/${img}"
#retval=$?
#if [ $retval -ne 0 ]; then
#  echo "${img}"
#fi