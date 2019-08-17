# eSense iOS Library

[![CI Status](https://img.shields.io/travis/tetujin/ESense.svg?style=flat)](https://travis-ci.org/tetujin/ESense)
[![Version](https://img.shields.io/cocoapods/v/ESense.svg?style=flat)](https://cocoapods.org/pods/ESense)
[![License](https://img.shields.io/cocoapods/l/ESense.svg?style=flat)](https://cocoapods.org/pods/ESense)
[![Platform](https://img.shields.io/cocoapods/p/ESense.svg?style=flat)](https://cocoapods.org/pods/ESense)

This library allows us to use [eSense](http://www.esense.io/) (earable computing platform) on iOS easily. This library is inspired by eSense library for Android which is developed by Pervasive Systems team at [Nokia Bell Labs](https://www.bell-labs.com/) Cambridge.

Yuuki Nishiyama, 

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements
iOS 10 or later

## Installation

ESense is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'ESense'
```

## Use eSense Library
1. Import the library in your iOS project
```swift
import ESense
```

2. Implement `ESenseconnectionListener` on your class
```swift
extension YOUR_CLASS:ESenseconnectionListener{
    func onDeviceFound(_ manager: ESenseManager) {
        // YOUR CODE HERE
    }

    func onDeviceNotFound(_ manager: ESenseManager) {
        // YOUR CODE HERE
    }

    func onConnected(_ manager: ESenseManager) {
        manager.setDeviceReadyHandler { device in
            manager.removeDeviceReadyHandler()
            // YOUR CODE HERE
        }
    }

    func onDisconnected(_ manager: ESenseManager) {
        // YOUR CODE HERE
    }
}
```

3. Create the ESenseManager instance
Prepare a variable for `ESenseManager` as a class or static variable.
```swift
var manager:ESenseManager? = nil
```
Initialize an `ESenseManager` class using a target device name and a class which is implemented the `ESenseconnectionListener`.
```swift
manager = ESenseManager(deviceName: "YOUR_ESENSE_NAME", listener: YOUR_CLASS)
```

4. Scan and connect an eSense device
For scanning an _eSense_ device, you can use `scan(timeout)` method. If `ESenseManager` finds an eSense device, `onDeviceFind(manager)`  method on `ESenseconnectionListener` is called. 
```swift
manager.scan(timeout: SECOND)
```

5. Handling sensor update events
After connecing the device, you listen the sensor change events via `ESenseSensrListener`. Please implement `ESenseSensorListener` on your class just like below. 
```swift
extension YOUR_CLASS:ESenseSensorListener{
    func onSensorChanged(_ evt: ESenseEvent) {
        // YOUR CODE HERE
    }
}
```
Finally, you can set the `ESenseSensorListener` to your `ESenseManager` with a sampling late (`hz`).
```swift
manager.registerSensorListener(YOUR_CLASS, hz: 10)
```

6. Handling eSense device events
In addition, you can handle _eSense_ other events (battery, button, and config related events) using `ESenseEventListener`. Please implement `ESenseEventListener` on your class. 
```swift
extension YOUR_CLASS:ESenseEventListener{
    func onBatteryRead(_ voltage: Double) {
        // YOUR CODE HERE
    }

    func onButtonEventChanged(_ pressed: Bool) {
        // YOUR CODE HERE
    }

    func onAdvertisementAndConnectionIntervalRead(_ minAdvertisementInterval: Int, _ maxAdvertisementInterval: Int, _ minConnectionInterval: Int, _ maxConnectionInterval: Int) {
        // YOUR CODE HERE
    }

    func onDeviceNameRead(_ deviceName: String) {
        // YOUR CODE HERE
    }

    func onSensorConfigRead(_ config: ESenseConfig) {
        // YOUR CODE HERE
    }

    func onAccelerometerOffsetRead(_ offsetX: Int, _ offsetY: Int, _ offsetZ: Int) {
        // YOUR CODE HERE
    }
}
```

Also, you can registe the implement listener by `registerEventListener(ESenseEventListener)` method on `ESenseManager` class.
```swift
manager.registerEventListener(self)
```

Executing read operations will trigger events on `ESenseEventListener`.
```swift
manager.getBatteryVoltage()
manager.getAccelerometerOffset()
manager.getDeviceName()
manager.getSensorConfig()
manager.getAdvertisementAndConnectionInterval()
```

## Author

**eSense Library for iOS** is developed by [Yuuki Nishiyama](http://www.yuukinishiyama.com) (The University of Tokyo, Japan) <yuukin@iis.u-tokyo.ac.jp>.

## License

ESense is available under the MIT license. See the LICENSE file for more info.
