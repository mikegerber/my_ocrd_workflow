#!/bin/sh
set -ex

test_id=`basename $0`
cd `mktemp -d /tmp/$test_id-XXXXX`

# Prepare processors
ocrd resmgr download ocrd-sbb-binarize default-2021-03-09

# Prepare test workspace
wget https://qurator-data.de/examples/actevedef_718448162.first-page+binarization+segmentation.zip
unzip actevedef_718448162.first-page+binarization+segmentation.zip
cd actevedef_718448162.first-page+binarization+segmentation

# Run tests
ocrd-sbb-binarize -P model default-2021-03-09 -I OCR-D-IMG -O TEST-OCRD-SBB-BINARIZE
