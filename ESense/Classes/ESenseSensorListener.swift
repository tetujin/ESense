//
//  ESenseSensorListener.swift
//  ESense
//
//  Created by Yuuki Nishiyama on 2019/08/15.
//

import UIKit

public protocol ESenseSensorListener {
    /**
     * Called when there is new sensor data available
     * @param evt object containing the sensor samples received
     */
    func onSensorChanged(_ evt:ESenseEvent);
}

