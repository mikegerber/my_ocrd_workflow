#!/bin/sh
set -ex

test_id=`basename $0`
cd `mktemp -d /tmp/$test_id-XXXXX`

OCRD_CIS_OCROPY_MODEL=fraktur.pyrnn.gz

# Prepare processors
ocrd resmgr download ocrd-cis-ocropy-recognize $OCRD_CIS_OCROPY_MODEL

# Prepare test workspace
wget https://qurator-data.de/examples/actevedef_718448162.first-page.zip
unzip actevedef_718448162.first-page.zip
cd actevedef_718448162.first-page

# XXX ocrd-cis-ocropy-segment wasn't happy with the binarized input (no
# "binarized" AlternativeImage?!), so we do it here again
ocrd-skimage-binarize -I OCR-D-IMG -O OCR-D-IMG-BIN

# Run tests
ocrd-cis-ocropy-segment \
   -I OCR-D-IMG-BIN -O TEST-CIS-OCROPY-SEG-LINE \
   -P level-of-operation page
test "$(grep TextLine TEST-CIS-OCROPY-SEG-LINE/*.xml | wc -l)" -gt 50

ocrd-cis-ocropy-recognize \
   -I TEST-CIS-OCROPY-SEG-LINE -O TEST-CIS-OCROPY-OCR \
   -P model $OCRD_CIS_OCROPY_MODEL
test "$(grep Unicode TEST-CIS-OCROPY-OCR/*.xml | wc -l)" -gt 50
