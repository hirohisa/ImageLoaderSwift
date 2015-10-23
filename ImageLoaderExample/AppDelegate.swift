//
//  AppDelegate.swift
//  ImageLoaderSample
//
//  Created by Hirohisa Kawasaki on 10/17/14.
//  Copyright (c) 2014 Hirohisa Kawasaki. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        return true

    }

    func reportMemory() {
        var info = task_basic_info()
        var count = mach_msg_type_number_t(sizeofValue(info))/4

        let kerr: kern_return_t = withUnsafeMutablePointer(&info) {

            task_info(mach_task_self_,
                task_flavor_t(TASK_BASIC_INFO),
                task_info_t($0),
                &count)

        }

        if kerr == KERN_SUCCESS {
            print("Memory in use (in bytes): \(info.resident_size)")
        }
        else {
            print("Error with task_info(): " +
                (String.fromCString(mach_error_string(kerr)) ?? "unknown error"))
        }
    }

}

