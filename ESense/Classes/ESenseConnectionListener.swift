//
//  ESenseConnectionListener.swift
//  ESense
//
//  Created by Yuuki Nishiyama on 2019/08/15.
//

import UIKit

public protocol ESenseConnectionListener {
    /**
     * Called when the device with the specified name has been found during a scan
     * @param manager device manager
     */
    func onDeviceFound(_ manager:ESenseManager);
    
    /**
     * Called when the device with the specified name has not been found during a scan
     * @param manager device manager
     */
    func onDeviceNotFound(_ manager:ESenseManager);
    
    /**
     * Called when the connection has been successfully made
     * @param manager device manager
     */
    func onConnected(_ manager:ESenseManager);
    
    /**
     * Called when the device has been disconnected
     * @param manager device manager
     */
    func onDisconnected(_ manager:ESenseManager);
    
}
