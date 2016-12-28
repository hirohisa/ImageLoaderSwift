//
//  UIImageView+ImageLoader.swift
//  ImageLoader
//
//  Created by Hirohisa Kawasaki on 2016/10/31.
//  Copyright © 2016年 Hirohisa Kawasaki. All rights reserved.
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
        return request(with: url, placeholder: nil, options: options, onCompletion: { _ in })
    }

    @discardableResult
    public func request(with url: URLLiteralConvertible, options: [Option] = [], onCompletion: @escaping (UIImage?, Error?, FetchOperation) -> Void) -> Loader? {
        return request(with: url, placeholder: nil, options: options, onCompletion: onCompletion)
    }

    @discardableResult
    public func request(with url: URLLiteralConvertible, placeholder: UIImage?, options: [Option] = [], onCompletion: @escaping (UIImage?, Error?, FetchOperation) -> Void) -> Loader? {
        let imageCompletion: (UIImage?, Error?, FetchOperation) -> Void = { image, error, operation in
            guard let image = image else { return onCompletion(nil, error, operation)  }

            DispatchQueue.main.async {
                if options.contains(.adjustSize) {
                    self.base.image = image.adjust(self.base.frame.size, scale: UIScreen.main.scale, contentMode: self.base.contentMode)
                } else {
                    self.base.image = image

                }
                onCompletion(image, error, operation)
            }
        }

        let task = Task(base, onCompletion: imageCompletion)

        // cancel
        if let requestUrl = base.requestUrl {
            let loader = ImageLoader.loaderManager.getLoader(with: requestUrl.imageLoaderURL)
            loader.operative.remove(task)
            if requestUrl != url.imageLoaderURL, loader.operative.tasks.isEmpty {
                loader.cancel()
            }
        }
        base.requestUrl = url.imageLoaderURL

        // disk
        if let data = ImageLoader.loaderManager.disk.get(url.imageLoaderURL), let image = UIImage(data: data) {
            task.onCompletion(image, nil, .disk)
            return nil
        }

        if let placeholder = placeholder {
            base.image = placeholder
        }

        // request
        let loader = ImageLoader.loaderManager.getLoader(with: url.imageLoaderURL, task: task)
        loader.resume()

        return loader
    }
}
