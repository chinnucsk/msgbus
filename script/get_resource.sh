#!/bin/sh

file_name=$1
file_dir=$2
urls=$3
timeout=$4

valid_urls=""
for url in $urls
do
    is_url_valid=`curl -I $url|head -1|grep "200 OK"|wc -l`
    if [[ $is_url_valid = 1 ]]
    then
	valid_urls="\"$url\" ${valid_urls}"
    fi
done
echo "valid urls: "${valid_urls}

epoch=`date +%s%N`
TMP_PATH="/home/lenovo_/data/tmp/arm/"
TMP_FILE=${TMP_PATH}${epoch}${RANDOM}${file_name}

#rm -f ${TMP_FILE_PATH}
axel_args=`echo -e "${valid_urls} -o ${TMP_FILE}"`
echo $axel_args | xargs ./script/timeout.sh -t $timeout axel || rm -f ${TMP_FILE}
#echo "tmp file path: "${TMP_FILE}
#echo "file dir: "${file_dir}
mv ${TMP_FILE} ${file_dir}
