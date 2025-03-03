<p align="center">
  <h1 align="center">EVVA Abrevva iOS SDK</h1>
</p>

<p align="center">
  <a href="https://github.com/evva-sfw/abrevva-sdk-ios-pod"><img src="https://img.shields.io/github/v/tag/evva-sfw/abrevva-sdk-ios-pod?color=fce500" alt="Package managers"></a>
  <a href="https://cocoapods.org/pods/AbrevvaSDK"><img src="https://img.shields.io/badge/-CocoaPods-fce500?logo=CocoaPods" alt="Package managers"></a>
    <a href="LICENSE"><img src="https://img.shields.io/badge/license-EVVA_License-yellow.svg?color=fce500&logo=data:image/svg+xml;base64,PCEtLSBHZW5lcmF0ZWQgYnkgSWNvTW9vbi5pbyAtLT4KPHN2ZyB2ZXJzaW9uPSIxLjEiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgd2lkdGg9IjY0MCIgaGVpZ2h0PSIxMDI0IiB2aWV3Qm94PSIwIDAgNjQwIDEwMjQiPgo8ZyBpZD0iaWNvbW9vbi1pZ25vcmUiPgo8L2c+CjxwYXRoIGZpbGw9IiNmY2U1MDAiIGQ9Ik02MjIuNDIzIDUxMS40NDhsLTMzMS43NDYtNDY0LjU1MmgtMjg4LjE1N2wzMjkuODI1IDQ2NC41NTItMzI5LjgyNSA0NjYuNjY0aDI3NS42MTJ6Ij48L3BhdGg+Cjwvc3ZnPgo=" alt="EVVA License"></a>
    <a href="https://swiftpackageindex.com/evva-sfw/abrevva-sdk-ios-pod"><img src="https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fevva-sfw%2Fabrevva-sdk-ios-pod%2Fbadge%3Ftype%3Dplatforms" alt="Package managers" notes="https://swiftpackageindex.com/api/packages/daveverwer/LeftPad/badge?type=platforms"></a>
    <a href="https://swiftpackageindex.com/evva-sfw/abrevva-sdk-ios-pod"><img src="https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fevva-sfw%2Fabrevva-sdk-ios-pod%2Fbadge%3Ftype%3Dswift-versions" alt="Package managers"></a>
</p>

The EVVA Abrevva iOS SDK is a collection of tools to work with electronical EVVA access components. It allows for scanning and connecting via BLE.

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Examples](#examples)

## Features

- BLE Scanner for EVVA components
- Localize scanned EVVA components
- Disengage scanned EVVA components
- Read / Write data via BLE

## Requirements

| Platform      | Minimum Swift Version | Installation            | Status                   |
| ------------- | --------------------- | ----------------------- | ------------------------ |
| iOS 15.0+     | 5.7.1 / Xcode 14.1    | [CocoaPods](#cocoapods) | Fully Tested             |
| watchOS 10.0+ | 5.7.1 / Xcode 14.1    | [CocoaPods](#cocoapods) | Fully Tested             |
| Android       | see [EVVA Abrevva Android SDK](https://github.com/evva-sfw/abrevva-sdk-android)

## Installation

### Cocoapods

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website. To integrate EVVA Abrevva iOS SDK into your Xcode project using CocoaPods, specify the pod in your `Podfile`:

```ruby
pod 'AbrevvaSDK'
```

### Swift Package Manager

See [swiftpackageindex.com](https://swiftpackageindex.com/evva-sfw/abrevva-sdk-ios-pod)

## Examples

### Initialize BleManager

To start off first initialize the SDK BleManager. You can pass an init callback closure for success indication.

```swift
import AbrevvaSDK

public class Example {

    private var bleManager: BleManager?
    private var bleDeviceMap = [String: BleDevice]()

    func initialize() {
        self.bleManager = BleManager { success, message in
            debugPrint("BleManager initialized /w success=\(success)")
        }
    }
}
```

### Scan for EVVA components

Use the BleManager to scan for components in range. You can pass several callback closures to react to the different events when scanning or connecting to components.

```swift
func scanForDevices() {
    let timeout = 10_000

    self.bleManager?.startScan(
        { device in
            debugPrint("Found device /w address=\(device.address)")
            self.bleDeviceMap[device.address] = device
        },
        { error in
            debugPrint("Scan started /w \(error ?? "success")")
        },
        { error in
            debugPrint("Scan stopped /w \(error ?? "success")")
        }, 
        nil,        // mac filter
        false,      // allow duplicates
        timeout
    )
}
```

### Read EVVA component advertisement

Get the EVVA advertisement data from a scanned EVVA component.

```swift
let ad = device.advertisementData
debugPrint(ad?.rssi)
debugPrint(ad?.isConnectable)

let md = ad?.manufacturerData
debugPrint(md?.batteryStatus)
debugPrint(md?.isOnline)
debugPrint(md?.officeModeEnabled)
debugPrint(md?.officeModeActive)
// ...
```

There are several properties that can be accessed from the advertisement.

```swift
public struct BleDeviceAdvertisementData {
    public let rssi: Int
    public let isConnectable: Bool?
    public let manufacturerData: BleDeviceManufacturerData?
}

public struct BleDeviceManufacturerData {
    public let companyIdentifier: UInt16
    public let version: UInt8
    public let componentType: UInt8
    public let mainFirmwareVersionMajor: UInt8
    public let mainFirmwareVersionMinor: UInt8
    public let mainFirmwareVersionPatch: UInt16
    public let componentHAL: Int
    public let batteryStatus: Bool
    public let mainConstructionMode: Bool
    public let subConstructionMode: Bool
    public let isOnline: Bool
    public let officeModeEnabled: Bool
    public let twoFactorRequired: Bool
    public let officeModeActive: Bool
    public let reservedBits: Int?
    public let identifier: String
    public let subFirmwareVersionMajor: UInt8?
    public let subFirmwareVersionMinor: UInt8?
    public let subFirmwareVersionPatch: UInt16?
    public let subComponentIdentifier: String?
}

```

### Localize EVVA component

With the signalize method you can localize scanned EVVA components. On a successful signalization the component will emit a melody indicating its location.

```swift
 func signalizeDevice(_ deviceId: String) async {
    guard let device = self.bleDeviceMap[deviceId] else { return }

    let success = await self.bleManager?.signalize(device)
    debugPrint("Signalized /w success=\(success)")
}
```
### Disengage EVVA components

For the component disengage you have to provide access credentials to the EVVA component. Those are generally acquired in the form of access media metadata from the Xesar software.

```swift
 func disengageDevice(_ deviceId: String) async {
    guard let device = self.bleDeviceMap[deviceId] else { return }

    let mobileId = ""               // sha256-hashed hex-encoded version of `xsMobileId` found in blob data.
    let mobileDeviceKey = ""        // mobileDeviceKey mobile device key string from `xsMOBDK` found in blob data.
    let mobileGroupId = ""          // mobileGroupId mobile group id string from `xsMOBGID` found in blob data.
    let mediumAccessData = ""       // mediumAccessData access data string from `mediumDataFrame` found in blob data.
    let isPermanentRelease = false  // office mode flag.
    let timeout = 10_000

    let status = await self.bleManager?.disengage(
        device,
        mobileId,
        mobileDeviceKey,
        mobileGroupId,
        mediumAccessData,
        isPermanentRelease,
        timeout
    )
    debugPrint("Disengage /w status=\(status)")
}
```
There are several access status types upon attempting the component disengage.
```swift
public enum DisengageStatusType: String {
    /// Component
    case AUTHORIZED
    case AUTHORIZED_PERMANENT_ENGAGE
    case AUTHORIZED_PERMANENT_DISENGAGE
    case AUTHORIZED_BATTERY_LOW
    case AUTHORIZED_OFFLINE
    case UNAUTHORIZED
    case UNAUTHORIZED_OFFLINE
    case SIGNAL_LOCALIZATION
    case MEDIUM_DEFECT_ONLINE
    case MEDIUM_BLACKLISTED
    case ERROR

    /// Interface
    case UNKNOWN_STATUS_CODE
    case UNABLE_TO_CONNECT
    case TIMEOUT
    case UNABLE_TO_SET_NOTIFICATIONS
    case UNABLE_TO_READ_CHALLENGE
    case ACCESS_CIPHER_ERROR
}
```
### Coding Identification Media
Use the CodingStation to write or update access data onto an EVVA identification medium.

```swift
class ExampleClass {
    private let cs = CodingStation()

    private let url = URL(string: "")!
    private let clientId = ""
    private let username = ""
    private let password = ""

    public func writeMedium() async throws {
        let cf: MqttConnectionOptions?
        
        cf = try await AuthManager.getMqttConfigForXS(
            url: url, clientId: clientId, username: username, password: password)
        try await cs.connect(cf!)
        try await cs.write()
        cs.disconnect()
    }
}
```
