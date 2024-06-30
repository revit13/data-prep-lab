#!/usr/bin/env bash

# update ray version in dockerfile.

op=$1
shift

if [[ $# != 1 ]]; then
  cat <<EOF
        "Incorrect number of parameters provided. The required parameter is ray version.
EOF
  exit 1
fi

ray=$1
source ../common.sh

update_dockerfile() {
  first_line=$(head -n 1 Dockerfile)
  if [[ $first_line == *" AS "* ]]; then
    as_expr=$(echo $first_line | grep -Eo "AS ([a-z]+)")
    sed -i.back "s%FROM docker.io/rayproject/ray:.*%FROM docker.io/rayproject/ray:$ray\-py310 $as_expr%" Dockerfile
  else
    sed -i.back "s%FROM docker.io/rayproject/ray:.*%FROM docker.io\/rayproject/ray:$ray\-py310%" Dockerfile
  fi
}

check_dockerfile() {
  first_line=$(head -n 1 Dockerfile)
  if [[ $first_line == *" AS "* ]]; then
    as_expr=$(echo $first_line | grep -Eo "AS ([a-z]+)")
    expected_task="FROM docker.io/rayproject/ray:$ray-py310 $as_expr"
    if [[ $first_line != $expected_task ]]; then
				echo $first_line $expected_task
				exit 1
			fi
  else
    expected_task="FROM docker.io/rayproject/ray:$ray-py310"
    if [[ $first_line != $expected_task ]]; then
				echo $first_line $expected_task
				exit 1
			fi
  fi
}

usage() {
  cat <<EOF
"Usage: ./update_dokcerfiles.sh [check_dokcerfile|update_dokcerfile]"
EOF
}

case "$op" in
check_dockerfile)
  header_text "Check dokcerfile in workflow"
  check_dokcerfile $1
  ;;
update_dockerfile)
  header_text "Update dokcerfile in workflow"
  update_dockerfile $1
  ;;
*)
  usage
  ;;
esac
