#!/bin/bash
. $(dirname $0)/../store/store.sh

package_type=${PACKAGE_TYPE:-"UPGRADE_RPM"}
download_url=${DOWNLOAD_URL:?}
download_dir=${DOWNLOAD_DIR:-/storage/logs/artifacts/downloads}

file_name=$(basename ${download_url})
target_file_path=${download_dir}/${file_name}

/usr/bin/wget -c -P ${download_dir} ${download_url}
ret=$?
if [ ${ret} -ne 0 ]; then
    echo "Failed to download content from ${download_url}.";
    exit 1;
fi

put_key_value_to_store ${package_type} ${target_file_path}
