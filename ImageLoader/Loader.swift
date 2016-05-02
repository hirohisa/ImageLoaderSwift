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
    let task: NSURLSessionDataTask
    var receivedData = NSMutableData()
    var blocks: [Block] = []

    init (task: NSURLSessionDataTask, delegate: Manager) {
        self.task = task
        self.delegate = delegate
        resume()
    }

    var state: NSURLSessionTaskState {
        return task.state
    }

    public func completionHandler(completionHandler: CompletionHandler) -> Self {
        let identifier = (blocks.last?.identifier ?? 0) + 1
        return self.completionHandler(identifier, completionHandler: completionHandler)
    }

    public func completionHandler(identifier: Int, completionHandler: CompletionHandler) -> Self {
        let block = Block(identifier: identifier, completionHandler: completionHandler)
        return appendBlock(block)
    }

    func appendBlock(block: Block) -> Self {
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

    func remove(identifier: Int) {
        // needs to queue with sync
        blocks = blocks.filter{ $0.identifier != identifier }
    }

    func receive(data: NSData) {
        receivedData.appendData(data)
    }

    func complete(error: NSError?, completionHandler: () -> Void) {

        if let URL = task.originalRequest?.URL {
            if let error = error {
                failure(URL, error: error, completionHandler: completionHandler)
                return
            }

            dispatch_async(delegate.decompressingQueue) { [weak self] in
                guard let wSelf = self else {
                    return
                }

                wSelf.success(URL, data: wSelf.receivedData, completionHandler: completionHandler)
            }
        }
    }

    private func success(URL: NSURL, data: NSData, completionHandler: () -> Void) {
        let image = UIImage.decode(data)
        _toCache(URL, data: data)

        for block in blocks {
            block.completionHandler(URL, image, nil, .None)
        }
        blocks = []
        completionHandler()
    }

    private func failure(URL: NSURL, error: NSError, completionHandler: () -> Void) {
        for block in blocks {
            block.completionHandler(URL, nil, error, .None)
        }
        blocks = []
        completionHandler()
    }

    private func _toCache(URL: NSURL, data: NSData?) {
        if let data = data {
            delegate.cache[URL] = data
        }
    }
}