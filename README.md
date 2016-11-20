ImageLoader
=======
[![Build-Status](https://api.travis-ci.org/hirohisa/ImageLoaderSwift.svg?branch=master)](https://travis-ci.org/hirohisa/ImageLoaderSwift)
[![CocoaPods](https://img.shields.io/cocoapods/v/ImageLoader.svg)](https://cocoapods.org/pods/ImageLoader)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![codecov.io](https://codecov.io/github/hirohisa/ImageLoaderSwift/coverage.svg?branch=master)](https://codecov.io/github/hirohisa/ImageLoaderSwift?branch=master)
[![license](https://img.shields.io/badge/license-MIT-000000.svg)](https://github.com/hirohisa/ImageLoaderSwift/blob/master/LICENSE)

ImageLoader is an instrument for asynchronous image loading written in Swift. It is a lightweight and fast image loader for iOS.

Features
----------

- [x] Simple methods with UIImageView Category.
- [x] Control Loader to resume, suspend and cancel with URL.
- [x] A module for cache can be set by yourself and default cache (Disk) uses disk spaces and un-uses memory.
- [x] Loading images is handled by ImageLoader, not UIImageView.
- [x] After image view start loading another image, previous loading task is possible to live with caching.
- [x] Support `NSURL`, `String` and `NSURLComponents` by `URLLiteralConvertible`
- [ ] Optimize to use memory when image is set.
- [x] Support image type .jpeg, .png
- [x] Comprehensive Unit Test Coverage

Requirements
----------

- iOS 8.0+
- Xcode 7.0+ Swift 2.0

ImageLoader | Xcode | Swift
----------- | ----- | -----
0.9.x       | 7.3.1 | 2.2
0.10.0      | 8.0+  | 2.3
0.11.+      | 8.0+  | 3.0
0.12.+      | 8.1+  | 3.0.1

If your project's target need to support iOS5.x or 6.x, use [ImageLoader](https://github.com/hirohisa/ImageLoader). It's A lightweight and fast image loader for iOS written in Objective-C.

Installation
----------

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects.

To integrate ImageLoader into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

pod 'ImageLoader'
```

Then, run the following command:

```bash
$ pod install
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that automates the process of adding frameworks to your Cocoa application.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate ImageLoader into your Xcode project using Carthage, specify it in your `Cartfile`:

```
github "hirohisa/ImageLoaderSwift" ~> 0.6.0
```

Usage
----------

#### ImageLoader

**load**
```swift
ImageLoader.request(with: url, onCompletion: { _ in })
```

#### UIImageView

```swift
imageView.load.request(with: url)
```

or

```swift
imageView.load.request(with: url, onCompletion: { _ in })
```


## License

ImageLoader is available under the MIT license.
