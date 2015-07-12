ImageLoader [![Build-Status](https://img.shields.io/travis/hirohisa/ImageLoaderSwift/master.svg)](https://travis-ci.org/hirohisa/ImageLoaderSwift) [![GitHub-version](https://img.shields.io/github/tag/hirohisa/ImageLoaderSwift.svg)](https://github.com/hirohisa/ImageLoaderSwift/tags) []([![Test-Coverage](https://img.shields.io/coveralls/hirohisa/ImageLoaderSwift/master.svg)](https://coveralls.io/r/hirohisa/ImageLoaderSwift)) [![license](https://img.shields.io/badge/license-MIT-000000.svg)](https://github.com/hirohisa/ImageLoaderSwift/blob/master/LICENSE)
=======

ImageLoader is an instrument for asynchronous image loading written in Swift. It is a lightweight and fast image loader for iOS.

Features
----------

- [x] Simple methods with UIImageView Category.
- [x] A module for cache can be set by yourself.
- [x] Diskcache for default settings, the module for cache use on disk and unused on memory.
- [x] Loading images is handled by ImageLoader, not UIImageView.
- [ ] After image view start loading another image, previous loading task is possible to live with caching.
- [ ] Comprehensive Unit Test Coverage
- [x] Optimize image with frame and scale
- [x] Control Loader to resume, suspend and cancel with URL.
- [x] Enable to set `NSURL` and `String` on `.load(URL)`

Requirements
----------

- iOS 7.0+
- Xcode 6.1+ Swift 1.1+

ImageLoader | Xcode | Swift | travis-ci
----------- | ----- | ----- | ---------
0.2.x | 6.1, 6.2 | 1.1 | [![Build-Status](https://img.shields.io/travis/hirohisa/ImageLoaderSwift/0.2.1.svg)](https://travis-ci.org/hirohisa/ImageLoaderSwift)
0.3.x | 6.3, 6.4 | 1.2 | [![Build-Status](https://img.shields.io/travis/hirohisa/ImageLoaderSwift/master.svg)](https://travis-ci.org/hirohisa/ImageLoaderSwift)

If your project's target need to support iOS5.x or 6.x, use [ImageLoader](https://github.com/hirohisa/ImageLoader). It's A lightweight and fast image loader for iOS written in Objective-C.

Installation
----------

It is the way to use this in your project:

- Add ImageLoader as a submodule by opening the Terminal, trying to enter the command
```
git submodule add https://github.com/hirohisa/ImageLoaderSwift.git
```

- Install with CocoaPods to write Podfile

```ruby
pod 'ImageLoader'
```

- Copy ImageLoader class files into your project

Usage
----------

#### ImageLoader

**load**
```swift

ImageLoader.load("http://image").completionHandler { _ in }
```

**suspend**
```swift

ImageLoader.suspend("http://image")
```


#### UIImageView Category

```swift

imageView.load("http://image")
```

or

```swift

imageView.load("http://image", placeholder: nil) { _ in ... }
```


## License

ImageLoader is available under the MIT license.
