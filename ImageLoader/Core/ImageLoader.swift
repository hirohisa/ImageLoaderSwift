//
//  ImageLoader.swift
//  ImageLoader
//
//  Created by Hirohisa Kawasaki on 10/16/14.
//  Copyright © 2014 Hirohisa Kawasaki. All rights reserved.
//

import Foundation
import UIKit

public struct ImageLoader {

    @discardableResult
    public static func request(with url: URLLiteralConvertible, onCompletion: @escaping (UIImage?, Error?, FetchOperation) -> Void) -> Loader {
        let task = Task(nil, onCompletion: onCompletion)
        let loader = ImageLoader.loaderManager.getLoader(with: url.imageLoaderURL, task: task)
        loader.resume()

        return loader
    }
}

extension ImageLoader {

    static let loaderManager = LoaderManager()
    static let sessionManager = SessionManager()

    class SessionManager: NSObject, URLSessionDataDelegate {

        func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
            guard let loader = getLoaderFromLoaderManager(with: dataTask) else { return }
            loader.operative.receiveData.append(data)
        }

        func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
            completionHandler(.allow)
        }

        func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
            guard let loader = getLoaderFromLoaderManager(with: task) else { return }
            loader.complete(with: error)
        }

        func getLoaderFromLoaderManager(with dataTask: URLSessionTask) -> Loader? {
            guard let url = dataTask.originalRequest?.url else { return nil }
            return loaderManager.storage[url]
        }
    }

    class LoaderManager {

        let session: URLSession
        let storage = HashStorage<URL, Loader>()
        var disk = Disk()

        init(configuration: URLSessionConfiguration = .default) {
            self.session = URLSession(configuration: configuration, delegate: sessionManager, delegateQueue: nil)
        }

        func getLoader(with url: URL) -> Loader {
            if let loader = storage[url] {
                return loader
            }

            let loader = Loader(session.dataTask(with: url), url: url, delegate: self)
            storage[url] = loader
            return loader
        }

        func getLoader(with url: URL, task: Task) -> Loader {
            let loader = getLoader(with: url)
            loader.operative.update(task)
            return loader
        }

        func remove(_ loader: Loader) {
            guard let url = storage.getKey(loader) else { return }

            storage[url] = nil
        }
    }
}
