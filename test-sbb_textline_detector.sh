#!/bin/sh
set -ex

test_id=`basename $0`
cd `mktemp -d /tmp/$test_id-XXXXX`

# Prepare processors
ocrd resmgr download ocrd-sbb-textline-detector default

# Prepare test workspace
wget https://qurator-data.de/examples/actevedef_718448162.first-page+binarization+segmentation.zip
unzip actevedef_718448162.first-page+binarization+segmentation.zip
cd actevedef_718448162.first-page+binarization+segmentation

# Run tests
ocrd-sbb-textline-detector -P models default -I OCR-D-IMG-BIN -O TEST-EYNOLLAH-SEG