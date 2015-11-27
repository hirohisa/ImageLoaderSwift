//
//  AppDelegate.swift
//  ImageLoaderSample
//
//  Created by Hirohisa Kawasaki on 10/17/14.
//  Copyright (c) 2014 Hirohisa Kawasaki. All rights reserved.
//

import UIKit

private let HOST_CPU_LOAD_INFO_COUNT = UInt32(sizeof(host_cpu_load_info_data_t) / sizeof(integer_t))

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        return true

    }

    func report() {
        reportMemory()
        reportCPU()
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
        } else {
            print("Error with task_info(): " +
                (String.fromCString(mach_error_string(kerr)) ?? "unknown error"))
        }
    }

    func reportCPU() {
        usageCPU()
    }

    // Reference: https://github.com/beltex/SystemKit/blob/master/SystemKit/System.swift
    func usageCPU() {
        if let CPULoadInfo = AppDelegate.hostCPULoadInfo() {
            print(CPULoadInfo.cpuTicks)
            print(CPULoadInfo.userUsageRatio)
            print(CPULoadInfo.systemUsageRatio)
        }
    }

    private static let machHost = mach_host_self()

    static func hostCPULoadInfo() -> host_cpu_load_info? {

        var size     = HOST_CPU_LOAD_INFO_COUNT
        let hostInfo = host_cpu_load_info_t.alloc(1)

        let result = host_statistics(machHost, HOST_CPU_LOAD_INFO, UnsafeMutablePointer(hostInfo), &size)

        let data = hostInfo.move()
        hostInfo.dealloc(1)

        if result != KERN_SUCCESS {
            return nil
        }

        return data
    }

}

extension host_cpu_load_info {

    var cpuTicks: (user: natural_t, system: natural_t, idle: natural_t, nice: natural_t) {
        return cpu_ticks
    }

    var totalTick: UInt32 {
        let ticks = cpuTicks
        return ticks.user + ticks.system + ticks.idle + ticks.nice
    }

    var userUsageRatio: Double {
        return (Double(cpuTicks.user)/Double(totalTick)) * 100
    }
    var systemUsageRatio: Double {
        return (Double(cpuTicks.user)/Double(totalTick)) * 100
    }
}