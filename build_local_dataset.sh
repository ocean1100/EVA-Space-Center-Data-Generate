#!/bin/bash

dataset_name=$1
big_partition=$2
small_partition=$3
dataset_amount=$4
remote_dataset_path="/data/${dataset_name}"
remote_IP='eva@140.113.86.59'
local_dataset_path="/data/space/${dataset_name}"
local_private_key="$HOME/.ssh/eva_58"
file_type=('train' 'test' 'validation' 'compressed_file')
data_type=('images' 'labels')

# ----------------------------------------------
conda_dir="$HOME/anaconda3/etc/profile.d/"
# shellcheck source=/dev/null
source "${conda_dir}/conda.sh"
conda activate "base"
git pull
# ----------------------------------------------

#reindex_test_valid_small_partition_folder(){
#  big_partition=$1
#  small_partition_index=$2
#  OIFS="$IFS"
#  IFS='_'
#  read -r -a new_list <<< "${small_partition_index}"
#  IFS="$OIFS"
#  new_small_partition="${big_partition}_${new_list[1]}"
#}


decompresse_partical_dataset(){
  type=$1
  index=$2
  counter=$3
  image_file="${local_dataset_path}/${type}/${data_type[0]}"
  mkdir -m 777 -v "${image_file}/${counter}"
  label_file="${local_dataset_path}/${type}/${data_type[1]}"
  mv "${local_dataset_path}/target_${index}.json"  "${label_file}"
  for j in $(seq 0 "$((small_partition - 1))")
  do
    mkdir -m 777 -v "${image_file}/${counter}/${counter}_$j"
    tar -C "${image_file}/${counter}/${counter}_$j" -xzf "${local_dataset_path}/${file_type[3]}/${index}_$j.tar.gz"
#    for img in "${image_file}/${counter}/${counter}_$j"/*.png
#    do
#      echo "$img"
#      pngcheck -v -q "$img"
#      retval=$?
#      if [ $retval == 0 ]; then
#        echo "image pass pngcheck!"
#      fi
#      if [ $retval -ne 0 ]; then
#        echo "Error: Defect Image"
#        echo "$img" && replace_defect_img "$img"
#      fi
#    done
  done
}


#replace_defect_img(){
#  local_image_path=$1
#  OIFS="$IFS"
#  IFS='/'
#  read -r -a new_list <<< "${local_image_path}"
#  IFS="$OIFS"
#  image_index="${new_list[8]}"
#  if [ "${new_list[4]}" == "train" ]; then
#    remote_image_path="${remote_IP}:${remote_dataset_path}/${new_list[6]}/${new_list[7]}/${image_index}"
#  elif [ "${new_list[4]}" == "test" ]; then
#    reindex_test_valid_small_partition_folder "8" "${new_list[7]}"
#    echo "${image_index}"
#    remote_image_path="${remote_IP}:${remote_dataset_path}/8/${new_small_partition}/${image_index}"
#  else
#    reindex_test_valid_small_partition_folder "9" "${new_list[7]}"
#    echo "${image_index}"
#    remote_image_path="${remote_IP}:${remote_dataset_path}/9/${new_small_partition}/${image_index}"
#  fi
#  echo "${remote_image_path}"
#  scp -i "${local_private_key}" "${remote_image_path}" "${local_image_path}"
#  echo "Error ${img} replaced!"
#}
# ----------------------------------------------

echo 'Start building local dataset'
mkdir -m 777 -v "${local_dataset_path}"
mkdir -m 777 -v "${local_dataset_path}/${file_type[3]}"
scp -i "${local_private_key}" "${remote_IP}:${remote_dataset_path}/${file_type[3]}/*.tar.gz" "${local_dataset_path}/${file_type[3]}"
scp -i "${local_private_key}" "${remote_IP}:${remote_dataset_path}/target*" "${local_dataset_path}"
# ----------------------------------------------

echo 'Start decompressing'

for i in $(seq 0 2)
do
  mkdir -m 777 -v "${local_dataset_path}/${file_type[i]}"
  mkdir -m 777 -v "${local_dataset_path}/${file_type[i]}/${data_type[0]}"
  mkdir -m 777 -v "${local_dataset_path}/${file_type[i]}/${data_type[1]}"
done

counter=0
echo "decompressing train dataset"
for i in $(seq 0 "$((big_partition - 3))"); do decompresse_partical_dataset "${file_type[0]}" "$i" "${counter}" && counter=$((counter+1)); done

counter=0
echo "decompressing test dataset"
decompresse_partical_dataset "${file_type[1]}" "$((big_partition - 2))" "${counter}"

counter=0
big_partition=$2
echo "decompressing validation dataset"
decompresse_partical_dataset "${file_type[2]}" "$((big_partition - 1))" "${counter}"

echo 'End decompressing'
# ----------------------------------------------

echo "Start checking dataset"
python "check_local_dataset.py" -dn "${dataset_name}" -bp "${big_partition}" -sp "${small_partition}" -n "${dataset_amount}"

echo 'End building local dataset'

#train_image_file="${local_dataset_path}/${file_type[0]}/${data_type[0]}"
#tar -C "${train_image_file}/4/4_6" -zxf "${local_dataset_path}/compressed_file/4_6.tar.gz"
#tar -C "${train_image_file}/7/7_6" -zxf "${local_dataset_path}/compressed_file/7_6.tar.gz"
#tar -C "${image_file}/4/4_5" -zxf "${local_dataset_path}/compressed_file/4_5.tar.gz"
#tar -C "${image_file}/6/6_3" -zxf "${local_dataset_path}/compressed_file/6_3.tar.gz"
#tar -C "${image_file}/6/6_4" -zxf "${local_dataset_path}/compressed_file/6_4.tar.gz"
#echo 'End decompressing'
#pngcheck -q "/data/space/Dataset_six_random/train/images/4/4_6/Dataset_six_random_92664.png"
#pngcheck -q "/data/space/Dataset_six_random/train/images/7/7_6/Dataset_six_random_152692.png"
#pngcheck -q "/data/space/Dataset_six_random/train/images/4/4_5/Dataset_six_random_90538.png"
#pngcheck -q "/data/space/Dataset_six_random/train/images/6/6_3/Dataset_six_random_127609.png"
#pngcheck -q "/data/space/Dataset_six_random/train/images/6/6_4/Dataset_six_random_128244.png"