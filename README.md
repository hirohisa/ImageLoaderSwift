ImageLoader
===========

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
imageView.setImage(URL)
```

or

```swift

let URL: NSURL = NSURL(string: "http://image")!
imageView.setImage(URL, placeholder: nil, success: { _ in ...}, failure: { _ in ...})
```

or

```swift

let URL: NSURL = NSURL(string: "http://image")!
imageView.setImage(URL, placeholder: nil, completion: { _ in ... })
```


## License

ImageLoader is available under the MIT license.

