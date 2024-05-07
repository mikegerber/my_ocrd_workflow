#!/bin/sh
set -ex

test_id=`basename $0`
cd `mktemp -d /tmp/$test_id-XXXXX`

# Prepare test workspace
wget https://qurator-data.de/examples/actevedef_718448162.first-page+binarization+segmentation.zip
unzip actevedef_718448162.first-page+binarization+segmentation.zip
cd actevedef_718448162.first-page+binarization+segmentation

# Run tests
ocrd-fileformat-transform -I OCR-D-GT-PAGE -O OCR-TEST-CONVERT
