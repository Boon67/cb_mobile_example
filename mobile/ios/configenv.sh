#!/usr/bin/env bash

cd Frameworks
rm -rf iOS
rm -rf macOS
rm -rf tvOS
curl https://packages.couchbase.com/releases/couchbase-lite-ios/3.0.0-beta02/couchbase-lite-swift_xc_enterprise_3.0.0-beta02.zip
unzip -n cbl.zip
rm -rf cbl.zip
rm -rf cbl