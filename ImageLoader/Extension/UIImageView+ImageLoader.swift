//
//  UIImageView+ImageLoader.swift
//  ImageLoader
//
//  Created by Hirohisa Kawasaki on 2016/10/31.
//  Copyright © 2016 Hirohisa Kawasaki. All rights reserved.
//

import UIKit

private var ImageLoaderRequestUrlKey = 0
private let _ioQueue = DispatchQueue(label: "swift.imageloader.queues.io", attributes: .concurrent)

extension UIImageView {
    fileprivate var requestUrl: URL? {
        get {
            var requestUrl: URL?
            _ioQueue.sync {
                requestUrl = objc_getAssociatedObject(self, &ImageLoaderRequestUrlKey) as? URL
            }

            return requestUrl
        }
        set(newValue) {
            _ioQueue.async {
                objc_setAssociatedObject(self, &ImageLoaderRequestUrlKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
}

extension Loadable where Base: UIImageView {

    @discardableResult
    public func request(with url: URLLiteralConvertible, options: [Option] = []) -> Loader? {
        return request(with: url, placeholder: nil, options: options, onCompletion: { _,_,_  in })
    }

    @discardableResult
    public func request(with url: URLLiteralConvertible, options: [Option] = [], onCompletion: @escaping (UIImage?, Error?, FetchOperation) -> Void) -> Loader? {
        return request(with: url, placeholder: nil, options: options, onCompletion: onCompletion)
    }

    @discardableResult
    public func request(with url: URLLiteralConvertible, placeholder: UIImage?, options: [Option] = [], onCompletion: @escaping (UIImage?, Error?, FetchOperation) -> Void) -> Loader? {
        guard let imageLoaderUrl = url.imageLoaderURL else { return nil }

        let imageCompletion: (UIImage?, Error?, FetchOperation) -> Void = { image, error, operation in
            guard var image = image else { return onCompletion(nil, error, operation)  }

            DispatchQueue.main.async {
                if options.contains(.adjustSize) {
                    image = image.adjust(self.base.frame.size, scale: UIScreen.main.scale, contentMode: self.base.contentMode)
                }
                if let images = image.images, images.count > 0, let gif = UIImage.animatedImage(with: images, duration: 1) {
                    image = gif
                }
                self.base.image = image
                onCompletion(image, error, operation)
            }
        }

        let task = Task(base, onCompletion: imageCompletion)

        // cancel
        if let requestUrl = base.requestUrl {
            let loader = ImageLoader.manager.getLoader(with: requestUrl)
            loader.operative.remove(task)
            if requestUrl != imageLoaderUrl, loader.operative.tasks.isEmpty {
                loader.cancel()
            }
        }
        base.requestUrl = url.imageLoaderURL

        // disk
        base.image = placeholder ?? nil
        if let data = ImageLoader.manager.disk.get(imageLoaderUrl), let image = UIImage.process(data: data) {
            task.onCompletion(image, nil, .disk)
            return nil
        }

        // request
        let loader = ImageLoader.manager.getLoader(with: imageLoaderUrl, task: task)
        loader.resume()

        return loader
    }
}
