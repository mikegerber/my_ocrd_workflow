#!/bin/sh
set -ex

test_id=`basename $0`
cd `mktemp -d /tmp/$test_id-XXXXX`

# Prepare processors

# Prepare test workspace
wget https://qurator-data.de/examples/actevedef_718448162.first-page.zip
unzip actevedef_718448162.first-page.zip
cd actevedef_718448162.first-page

# Run tests
ocrd-anybaseocr-binarize -I OCR-D-IMG -O OCR-D-BIN -P operation_level page -P threshold 0.3
ocrd-anybaseocr-deskew -I OCR-D-BIN -O OCR-D-DESKEW -P maxskew 5.0 -P skewsteps 20 -P operation_level page
