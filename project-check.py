#!/usr/bin/env python

import os

appDotNetContents = os.listdir("AppDotNet")
pngFiles = [x for x in appDotNetContents if x.endswith(".png")]
xibFiles = [x for x in appDotNetContents if x.endswith(".xib")]

if len(pngFiles) != 0:
	print "Found PNG files in AppDotNet/, they should be in Resources/Images!"
	print pngFiles

if len(xibFiles) != 0:
	print "Found XIB files in AppDotNet/, they should be in Resources/Nibs!"
	print xibFiles

net3000Contents = os.listdir("Net 3000")
pngFiles = [x for x in appDotNetContents if x.endswith(".png")]
xibFiles = [x for x in appDotNetContents if x.endswith(".xib")]

if len(pngFiles) != 0:
	print "Found PNG files in NET 3000/, they should be in Resources/Images!"
	print pngFiles

if len(xibFiles) != 0:
	print "Found XIB files in NET 3000/, they should be in Resources/Nibs!"
	print xibFiles