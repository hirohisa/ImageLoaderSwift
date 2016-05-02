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
0.3.x | 6.4 | 1.2
0.4+ | 7.0+ | 2.0

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

### Manually

If you prefer not to use either of the aforementioned dependency managers, you can integrate ImageLoader into your project manually.

#### Embedded Framework

- Open up Terminal, `cd` into your top-level project directory, and run the following command "if" your project is not initialized as a git repository:

- Add ImageLoader as a git [submodule](http://git-scm.com/docs/git-submodule) by running the following command:

```bash
$ git submodule add https://github.com/hirohisa/ImageLoaderSwift.git
```

Usage
----------

#### ImageLoader

**load**
```swift
import ImageLoader

ImageLoader.load("http://image").completionHandler { _ in }
```

**suspend**
```swift
import ImageLoader

ImageLoader.suspend("http://image")
```


#### UIImageView Category

```swift
import ImageLoader

imageView.load("http://image")
```

or

```swift
import ImageLoader

imageView.load("http://image", placeholder: nil) { _ in ... }
```


## License

ImageLoader is available under the MIT license.
