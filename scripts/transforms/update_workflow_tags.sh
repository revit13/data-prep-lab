#!/usr/bin/env bash

op=$1; shift
set -x
source ../common.sh

update_tags() {
versions_file=$1
pipeline_path=$2

# Modify the tasks tags as defined in the versions file
while IFS= read -r line; do 
	[ -z "$line" ] && continue
	[[ $line == *#* ]] && continue
	[[ $line == *ifeq* || $line == *else* || $line == *endif* ]] && continue
	VERSION_NAME=$(echo $line |cut -d "=" -f 1)
	DOCKER_IMAGE_NAME=$(echo $line |cut -d "=" -f 1 |sed "s/_VERSION//" |tr '[:upper:]' '[:lower:]')
	DOCKER_IMAGE_NAME=$(echo $DOCKER_IMAGE_NAME |sed "s/_ray$/\-ray/" | sed "s/_spark$/\-spark/" | sed "s/_parquet$/\-parquet/")
	DOCKER_IMAGE_VERSION=$(eval echo ${!VERSION_NAME})
	sed -i.back "s/data-prep-kit\/$DOCKER_IMAGE_NAME:.*/data-prep-kit\/$DOCKER_IMAGE_NAME:$DOCKER_IMAGE_VERSION\"/" $pipeline_path
done < $versions_file
}

check_tags(){
versions_file=$1
pipeline_path=$2

# Modify the tasks tags as defined in the versions file
while IFS= read -r line; do
        [ -z "$line" ] && continue
        [[ $line == *#* ]] && continue
        [[ $line == *ifeq* || $line == *else* || $line == *endif* ]] && continue
	echo $line
        VERSION_NAME=$(echo $line |cut -d "=" -f 1)
	echo "hi"
        DOCKER_IMAGE_NAME=$(echo $line |cut -d "=" -f 1 |sed "s/_VERSION//" |tr '[:upper:]' '[:lower:]')
	echo "hi"
        echo "hi"
	DOCKER_IMAGE_NAME=$(echo $DOCKER_IMAGE_NAME |sed "s/_ray$/\-ray/" | sed "s/_spark$/\-spark/" | sed "s/_parquet$/\-parquet/")
	echo "hi"
        DOCKER_IMAGE_VERSION=$(eval echo ${!VERSION_NAME})
	echo "hi5"
	echo $DOCKER_IMAGE_NAME
	echo $pipeline_path
	task_name="$(grep $DOCKER_IMAGE_NAME $pipeline_path)"
	echo $task_name "task_name"
	if [[ $task_name != "" ]]; then
		task_in_workflow=$(grep "task_image =" $pipeline_path | sed 's%task_image =%%'|sed 's/"//g' |tr '[:upper:]' '[:lower:]')
		expected_task="quay.io/dataprep1/data-prep-kit/$DOCKER_IMAGE_NAME:$DOCKER_IMAGE_VERSION"
		if [[ $task_in_workflow != $expected_task ]]; then
			echo $task_in_workflow $expected_task
		else
			echo $task_in_workflow $expected_task
		fi	
	fi
done < $versions_file
}



usage(){
        cat <<EOF
"Usage: ./update_workflow_tags.sh [check_tags|update_tags]"
EOF
}

case "$op" in
check_tags)
  header_text "Check tags in workflow"
  check_tags $1 $2
  ;;
update_tags)
  header_text "Update tags in workflow"
  update_tags
  ;;
 *)
  usage
  ;;
esac
