#!/usr/bin/env bash

op=$1
shift

if [[ $# != 2 ]]; then
  cat << EOF
	"Incorrect number of parameters provided. The required parameters are versions_file and pipeline_path. 
EOF
  exit 1
fi

versions_file=$1
pipeline_path=$2

source ../common.sh

update_tags() {

	# Modify the tasks tags as defined in the versions file
	while IFS= read -r line; do
		[ -z "$line" ] && continue
		[[ $line == *#* ]] && continue
		[[ $line == *ifeq* || $line == *else* || $line == *endif* ]] && continue
		VERSION_NAME=$(echo $line | cut -d "=" -f 1)
		DOCKER_IMAGE_NAME=$(echo $line | cut -d "=" -f 1 | sed "s/_VERSION//" | tr '[:upper:]' '[:lower:]')
		DOCKER_IMAGE_NAME=$(echo $DOCKER_IMAGE_NAME | sed "s/_ray$/\-ray/" | sed "s/_spark$/\-spark/" | sed "s/_parquet$/\-parquet/")
		DOCKER_IMAGE_VERSION=$(eval echo ${!VERSION_NAME})
		sed -i.back "s/data-prep-kit\/$DOCKER_IMAGE_NAME:.*/data-prep-kit\/$DOCKER_IMAGE_NAME:$DOCKER_IMAGE_VERSION\"/" $pipeline_path
	done <$versions_file
}

check_tags() {
	task_found=0
	# Modify the tasks tags as defined in the versions file
	while IFS= read -r line; do
		[ -z "$line" ] && continue
		[[ $line == *#* ]] && continue
		[[ $line == *ifeq* || $line == *else* || $line == *endif* ]] && continue
		[[ $line == RAY=* ]] && continue
		VERSION_NAME=$(echo $line | cut -d "=" -f 1)
		DOCKER_IMAGE_NAME=$(echo $line | cut -d "=" -f 1 | sed "s/_VERSION//" | tr '[:upper:]' '[:lower:]')
		DOCKER_IMAGE_NAME=$(echo $DOCKER_IMAGE_NAME | sed "s/_ray$/\-ray/" | sed "s/_spark$/\-spark/" | sed "s/_parquet$/\-parquet/")
		DOCKER_IMAGE_VERSION=$(eval echo ${!VERSION_NAME})
		task_name="$(grep $DOCKER_IMAGE_NAME $pipeline_path)"
		
		if [[ $task_name != "" ]]; then
			task_found=1
			task_in_workflow=$(grep "task_image =" $pipeline_path | sed 's%task_image =%%' | sed 's/"//g' | tr '[:upper:]' '[:lower:]' | tr -d ' ')
			expected_task="quay.io/dataprep1/data-prep-kit/$DOCKER_IMAGE_NAME:$DOCKER_IMAGE_VERSION"
			if [[ $task_in_workflow != $expected_task ]]; then
				echo "unexpected tag $task_in_workflow $expected_task"
				exit 1
			fi
		fi
	done <$versions_file
	if [[ $task_found -eq 0 ]]; then
		echo "transform image missing from $pipeline_path"
		exit 1
	fi
}

usage() {
	cat <<EOF
"Usage: ./update_workflow_tags.sh [check_tags|update_tags]"
EOF
}

case "$op" in
check_tags)
	header_text "Check tags in workflow"
	check_tags
	;;
update_tags)
	header_text "Update tags in workflow"
	update_tags
	;;
*)
	usage
	;;
esac
