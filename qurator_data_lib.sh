check_data_subdir() {
  result=0

  if git submodule status $DATA_SUBDIR | grep -q '^-'; then
    echo "$DATA_SUBDIR/ is not an initialized submodule"; result=1
  fi
  if ! [ -e $DATA_SUBDIR/.git/annex ]; then
    echo "$DATA_SUBDIR/ is not a git annex repository"; result=1
  fi
  if ! (cd $DATA_SUBDIR && git annex version | grep -q 'local repository version: 7'); then
    echo "$DATA_SUBDIR/ is not a git annex repository version 7"; result=1
  fi
  if ! (cd $DATA_SUBDIR && git remote | grep -q '^nfs$'); then
    echo "$DATA_SUBDIR/ has no git remote 'nfs'"; result=1
  fi

  return $result
}

annex_get() {
  file_pattern="$1"

  (
    cd data
    git annex get $file_pattern

    # fsck seems to be necessary to fix the files if we're in a submodule
    git annex fsck $file_pattern
  )
}

download_to() {
  download_source="$1"
  unpack_to="$2"

  (
    cd data
    tmpf=`mktemp 'tmp.XXXXX'`
    wget -O $tmpf "$download_source"
    mkdir -p "$unpack_to"
    # Unpacking relies on tar -a unpacking any tar compression
    tar -C "$unpack_to" -af $tmpf -xv
    rm -f $tmpf
  )
}

suggest_commands() {
  echo "Suggested commands:"
  echo
  echo "git submodule update --init"
  echo "(cd $DATA_SUBDIR && git annex init --version=7)"
  echo "(cd $DATA_SUBDIR && git remote add nfs /<... path to ...>/GitNX-Repository/qurator/qurator-data)"
}

handle_data() {
  if [ -n "$FORCE_DOWNLOAD" ]; then
    get_from_web
  elif ! check_data_subdir; then
    select choice in "Abort to manually fix $DATA_SUBDIR submodule" "Download data files from the web"; do
      if [ $REPLY = 1 ]; then
        suggest_commands
        exit
      else
        get_from_web
        break
      fi
    done
  else
    get_from_annex
  fi
}