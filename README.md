ImageLoader [![Build Status](https://travis-ci.org/hirohisa/ImageLoaderSwift.svg)](https://travis-ci.org/hirohisa/ImageLoaderSwift)
===========

[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/hirohisa/ImageLoaderSwift?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

ImageLoader is an instrument for asynchronous image loading.

Features
----------

- [x] Simple methods with UIImageView Category.
- [x] A module for cache can be set by yourself.
- [x] Loading images is handled by ImageLoader, not UIImageView.
- [ ] After image view start loading another image, previous loading task is possible to live with caching.
- [ ] Comprehensive Unit Test Coverage
- [ ] Optimize image with frame and scale

Requirements
----------

iOS 7.0+
Xcode 6.1

Installation
----------

It is the way to use this in your project:

- Add ImageLoader as a submodule by opening the Terminal, trying to enter the command
```
git submodule add https://github.com/hirohisa/ImageLoaderSwift.git
```

- Copy ImageLoader class files into your project

Usage
----------

```swift

let URL: NSURL = NSURL(string: "http://image")!
imageView.load(URL)
```

or

```swift

let URL: NSURL = NSURL(string: "http://image")!
imageView.load(URL, placeholder: nil) { _ in ... }
```


## License

ImageLoader is available under the MIT license.

