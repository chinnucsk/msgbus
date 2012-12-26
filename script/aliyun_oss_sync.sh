#!/bin/bash
pool=$1
swf_filename=`basename $2`
echo "/opt/oss_python_cmd/osscmd put $2 oss://lenovodataent/$pool/$swf_filename" 
/opt/oss_python_cmd/osscmd put $2 oss://lenovodataent/$pool/$swf_filename &
