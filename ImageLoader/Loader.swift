//
//  Loader.swift
//  ImageLoader
//
//  Created by Hirohisa Kawasaki on 5/2/16.
//  Copyright © 2016 Hirohisa Kawasaki. All rights reserved.
//

import UIKit
import Foundation

/**
 Responsible for sending a request and receiving the response and calling blocks for the request.
 */
public class Loader {

    unowned let delegate: Manager
    let task: URLSessionDataTask
    var receivedData = Data()
    var blocks: [Block] = []

    init (task: URLSessionDataTask, delegate: Manager) {
        self.task = task
        self.delegate = delegate
        resume()
    }

    var state: URLSessionTask.State {
        return task.state
    }

    public func completionHandler(_ completionHandler: @escaping CompletionHandler) -> Self {
        let identifier = (blocks.last?.identifier ?? 0) + 1
        return self.completionHandler(identifier, completionHandler: completionHandler)
    }

    public func completionHandler(_ identifier: Int, completionHandler: @escaping CompletionHandler) -> Self {
        let block = Block(identifier: identifier, completionHandler: completionHandler)
        return appendBlock(block)
    }

    func appendBlock(_ block: Block) -> Self {
        blocks.append(block)
        return self
    }

    // MARK: task

    public func suspend() {
        task.suspend()
    }

    public func resume() {
        task.resume()
    }

    public func cancel() {
        task.cancel()
    }

    func remove(_ identifier: Int) {
        // needs to queue with sync
        blocks = blocks.filter{ $0.identifier != identifier }
    }

    func receive(_ data: Data) {
        receivedData.append(data)
    }

    func complete(_ error: Error?, completionHandler: @escaping () -> Void) {

        if let url = task.originalRequest?.url {
            if let error = error {
                failure(url, error: error, completionHandler: completionHandler)
                return
            }

            delegate.decompressingQueue.async { [weak self] in
                guard let wSelf = self else { return }

                wSelf.success(url, data: wSelf.receivedData as Data, completionHandler: completionHandler)
            }
        }
    }

    private func success(_ url: URL, data: Data, completionHandler: () -> Void) {
        let image = UIImage.decode(data)
        _toCache(url, data: data)

        for block in blocks {
            block.completionHandler(url, image, nil, .none)
        }
        blocks = []
        completionHandler()
    }

    private func failure(_ url: URL, error: Error, completionHandler: () -> Void) {
        for block in blocks {
            block.completionHandler(url, nil, error, .none)
        }
        blocks = []
        completionHandler()
    }

    private func _toCache(_ url: URL, data: Data?) {
        if let data = data {
            delegate.cache[url] = data
        }
    }
}
