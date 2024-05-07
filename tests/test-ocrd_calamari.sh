#!/bin/sh
set -ex

test_id=`basename $0`
cd `mktemp -d /tmp/$test_id-XXXXX`

# Prepare processors
ocrd resmgr download ocrd-calamari-recognize qurator-gt4histocr-1.0

# Prepare test workspace
wget https://qurator-data.de/examples/actevedef_718448162.first-page+binarization+segmentation.zip
unzip actevedef_718448162.first-page+binarization+segmentation.zip
cd actevedef_718448162.first-page+binarization+segmentation

# Run tests
ocrd-calamari-recognize -I OCR-D-SEG-LINE-SBB -O OCR-D-OCR-CALA -P checkpoint_dir qurator-gt4histocr-1.0
