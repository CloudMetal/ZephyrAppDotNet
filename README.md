## AppDotNet
Fast. Powerful. Clean. [Zephyr](http://getzephyrapp.net) is an App.net client for iOS. This universal app can be enjoyed on all of your devices - iPhone, iPod touch, and iPad. 

## iOS App.net Client
This is the open-source release of Zephyr. If anyone wants to take it and
improve it, please go right ahead. We won't be supporting this release. Please feel free to [fork the code](https://github.com/enderlabs/ZephyrAppDotNet), and submit pull requests for any new features or fixes.

## Important
Zephyr uses a number of API keys that are not included in this repository.
You can find them defined in Keys.h. At minimum, you must supply the app.net
API key in order to sign into the app. The defined values should take the
form of Objective-C strings, with an @ at the front.

## Compiling
Use the AppDotNet xcode project, and build the NET 3000 target. Yeah, it's named
confusingly, but that's how it goes. The NET 3000 xcode project was distributed via GitHub during development to save our device tokens. The Python scripts would generate a static library ( libAppDotNetBinary.a ), that was placed in the NET 3000 project before each beta build was released.

## Licence
There isn't a license, but some people like to see some legal looking text: 

Ender Labs waives all claim of copyright in this work and immediately places it in the public domain; it may be used, distorted or destroyed in any manner whatsoever without further attribution or notice to the creator. We'd love to hear what you do with the code though, [so let us know](http://enderlabs.com/contact)!