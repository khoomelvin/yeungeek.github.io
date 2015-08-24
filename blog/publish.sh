#! /bin/bash
echo "==== start publish blog =====" &&
git add --all &&
git commit -m 'publish blog' &&
git push &&
echo '==== publish blog success ===='
echo
