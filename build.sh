#!/bin/bash -ex
npm install
bower install
bundle install
bundle exec middleman build
rm -Rf nodebob/app
cp -Rf build nodebob/app
cp -Rf node_modules nodebob/app
VERSION=`node -e "console.log(require('./package.json').version);"`
node <<"EOF"
var pkg = require('./package.json'); 
pkg.main = 'index.html'; 
pkg.window.toolbar = false; 
require('fs').writeFileSync('nodebob/app/package.json', JSON.stringify(pkg), 'utf8');
EOF
cd nodebob
rm -Rf release.* manager-for-upyun-*
./build.linux.sh
./build.osx.sh
mv release.linux-ia32/app release.linux-ia32/upyun_manager
mv release.linux-x64/app release.linux-x64/upyun_manager
mv release.osx/app.app release.osx/UpYun\ Manager.app

cd release.linux-ia32 && zip -r ../manager-for-upyun-$VERSION-linux-ia32.zip * && cd ..
cd release.linux-x64 && zip -r ../manager-for-upyun-$VERSION-linux-x64.zip * && cd ..
cd release.osx && zip -r ../manager-for-upyun-$VERSION-osx.zip * && cd ..

