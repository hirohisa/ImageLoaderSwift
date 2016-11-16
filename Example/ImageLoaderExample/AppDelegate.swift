//
//  AppDelegate.swift
//  ImageLoaderSample
//
//  Created by Hirohisa Kawasaki on 10/17/14.
//  Copyright (c) 2014 Hirohisa Kawasaki. All rights reserved.
//

import UIKit

private let HOST_CPU_LOAD_INFO_COUNT = UInt32(MemoryLayout<host_cpu_load_info_data_t>.size / MemoryLayout<integer_t>.size)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    private func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        return true

    }

    func report() {
        reportMemory()
        reportCPU()
    }

    func reportMemory() {
    }

    func reportCPU() {
    }

    private static let machHost = mach_host_self()

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
