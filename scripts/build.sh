#!/bin/bash

set -e

basepath=$(dirname $0)
server_prefix=/zent/zenticon

# temporaryly discard
# convert relative path to absolute path
# function abspath() {
#   pushd . > /dev/null; if [ -d "$1" ]; then cd "$1"; dirs -l +0; else cd "`dirname \"$1\"`"; cur_dir=`dirs -l +0`; if [ "$cur_dir" == "/" ]; then echo "$cur_dir`basename \"$1\"`"; else echo "$cur_dir/`basename \"$1\"`"; fi; fi; popd > /dev/null;
# }

function relpath() {
  echo ${1#$basepath/};
}

command_exists () {
    type "$1" >/dev/null 2>&1
}

if ! command_exists superman-cdn ; then
  echo '[warning] superman-cdn not found'
fi

fontname() {
  if command_exists superman-cdn ; then
    echo "https://b.yzcdn.cn$server_prefix/$(basename $basepath/../build/font/zenticon-*.$1)"
  else
    echo "$(relpath $basepath/../build/font/zenticon-*.$1)"
  fi
}

rm -rf build lib

# generate font files from sketch file
$basepath/extract-svg.sh
$basepath/generate-font.sh

# copy assets
cp -a $basepath/../build/css/zenticon-codes.css $basepath/../assets/_zenticon-codes.scss
cp -a $basepath/../build/LICENSE.txt $basepath/../assets

# generate fontface style
eot=$(fontname eot)
cat > $basepath/../assets/_fontface.scss <<EOF
/* DO NOT EDIT!! Auto genetated. */

@font-face {
  font-family: 'zenticon';
  src: url('$eot');
  src: url('$eot?#iefix') format('embedded-opentype'),
      url('$(fontname woff2)') format('woff2'),
      url('$(fontname woff)') format('woff'),
      url('$(fontname ttf)') format('truetype')
}
EOF

# build css
sass --no-source-map assets/index.scss lib/zenticons.css

# copy assets
cp -a $basepath/../build/codes.json $basepath/../lib

if command_exists superman-cdn ; then
  # upload to cdn
  superman-cdn $server_prefix $basepath/../build/font/zenticon-*
fi
