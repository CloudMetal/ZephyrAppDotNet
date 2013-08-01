#!/usr/bin/env python

import os

os.popen("xcodebuild -project AppDotNet.xcodeproj -scheme AppDotNetBinary -configuration Release")
os.popen("zip -r 'Zephyr.zip' 'README.md' 'NET 3000' 'NET 3000.xcodeproj' 'TextExpander.framework' 'Resources'")
