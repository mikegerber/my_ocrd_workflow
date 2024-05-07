#!/bin/sh
set -e

count_ok=0
count_failed=0

for test in tests/*.sh; do
    echo "== $test"
    $test && result=$? || result=$?

    if [[ $result = 0 ]]; then
        echo "✔"
        count_ok=$((count_ok+1))
    else
        echo "❌"
        count_failed=$((count_failed+1))
    fi
    echo
done

echo "$count_ok ok, $count_failed failed"
if [[ $count_failed -gt 0 ]]; then
    exit 1
fi
