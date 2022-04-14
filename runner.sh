#!/bin/bash

if [ $# -ne 4 ]; then
    echo $#
    echo "Parameter not ok"
    exit -1
fi

OUTPUT_DIR=$1
TEST_NAME=$2
PREFETCHER_EXE=$3
TRACE2_GZ=$4

if [ ! -d "$OUTPUT_DIR" ]; then
    mkdir -p "$OUTPUT_DIR"
fi

if [ ! -f "$PREFETCHER_EXE" ]; then
    echo "$PREFETCHER_EXE does not exist."
    exit -1
fi

if [ ! -f "$TRACE2_GZ" ]; then
    echo "$TRACE2_GZ does not exist."
    exit -1
fi

LOG_NAME=$TEST_NAME-$(date +%Y%m%d%H%M%S).log

script $OUTPUT_DIR/$LOG_NAME -c "zcat $TRACE2_GZ | $PREFETCHER_EXE"
