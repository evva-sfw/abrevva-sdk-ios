<p align="center">
  <h1 align="center">EVVA Abrevva SDK for Apple Platforms</h1>
</p>

<p align="center">
    <a href="LICENSE"><img src="https://img.shields.io/badge/license-EVVA_License-yellow.svg?color=fce500&logo=data:image/svg+xml;base64,PCEtLSBHZW5lcmF0ZWQgYnkgSWNvTW9vbi5pbyAtLT4KPHN2ZyB2ZXJzaW9uPSIxLjEiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgd2lkdGg9IjY0MCIgaGVpZ2h0PSIxMDI0IiB2aWV3Qm94PSIwIDAgNjQwIDEwMjQiPgo8ZyBpZD0iaWNvbW9vbi1pZ25vcmUiPgo8L2c+CjxwYXRoIGZpbGw9IiNmY2U1MDAiIGQ9Ik02MjIuNDIzIDUxMS40NDhsLTMzMS43NDYtNDY0LjU1MmgtMjg4LjE1N2wzMjkuODI1IDQ2NC41NTItMzI5LjgyNSA0NjYuNjY0aDI3NS42MTJ6Ij48L3BhdGg+Cjwvc3ZnPgo=" alt="EVVA License"></a>
    <a href="https://swiftpackageindex.com/evva-sfw/abrevva-sdk-ios"><img src="https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fevva-sfw%2Fabrevva-sdk-ios%2Fbadge%3Ftype%3Dplatforms" alt="Supported platforms"></a>
    <a href="https://swiftpackageindex.com/evva-sfw/abrevva-sdk-ios"><img src="https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fevva-sfw%2Fabrevva-sdk-ios%2Fbadge%3Ftype%3Dswift-versions" alt="Supported Swift versions"></a>
</p>

The EVVA Abrevva SDK provides tools for working with EVVA access components on Apple platforms, including scanning for and communicating with components over Bluetooth Low Energy (BLE).

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Examples](#examples)

## Features

- Scan for EVVA components over BLE.
- Localize scanned components.
- Disengage scanned components.
- Read and write data over BLE.
- Write or update access data on EVVA identification media with a coding station.

## Requirements

| Platform | Minimum version |
|----------|-----------------|
| iOS      | 16.0+           |
| watchOS  | 10.0+           |

The SDK is built with Swift 6. The `CodingStation` API used in the identification-media example is iOS-only.

## Installation

### Swift Package Manager

Swift Package Manager is the sole supported distribution method. In Xcode, choose **File > Add Package Dependencies…** and enter:

```text
https://github.com/evva-sfw/abrevva-sdk-ios.git
```

Add the `AbrevvaSDK` product to iOS app targets or `AbrevvaSDKWatchOS` to watchOS app targets. The released package supports iOS 16 and later and watchOS 10 and later, and supplies the dependency modules required by each product.

For a Swift package manifest, add the released package and the product matching the app target:

```swift
.package(url: "https://github.com/evva-sfw/abrevva-sdk-ios.git", from: "4.0.0")

// iOS target dependency:
.product(name: "AbrevvaSDK", package: "abrevva-sdk-ios")

// watchOS target dependency:
.product(name: "AbrevvaSDKWatchOS", package: "abrevva-sdk-ios")
```

See the [Swift Package Index listing](https://swiftpackageindex.com/evva-sfw/abrevva-sdk-ios) and [GitHub releases](https://github.com/evva-sfw/abrevva-sdk-ios/releases) for package and release information.

## Examples

The BLE manager and devices are `MainActor`-isolated. Call their APIs from the main actor, as in the examples below.

### Initialize `BleManager`

Create a manager to scan for and connect to EVVA components. The optional callback reports Bluetooth initialization state.

```swift
import AbrevvaSDK

@MainActor
final class Example {
    private let bleManager = BleManager { success, message in
        debugPrint("BleManager initialized: success=\(success), message=\(message ?? "none")")
    }

    private var bleDeviceMap = [String: BleDevice]()
}
```

### Scan for EVVA components

`startScan` accepts callbacks for results and scan start/stop, an optional manufacturer identifier filter, a duplicate-results setting, and an optional timeout in milliseconds. A manager supports one active scan at a time. For each accepted result, the manager reuses the same `BleDevice` instance for that peripheral and refreshes its latest advertisement data.

```swift
extension Example {
    func scanForDevices() {
        bleManager.startScan(
            { device in
                debugPrint("Found device at \(device.address)")
                bleDeviceMap[device.address] = device
            },
            { error in
                debugPrint("Scan start: \(error?.localizedDescription ?? "success")")
            },
            { error in
                debugPrint("Scan stop: \(error?.localizedDescription ?? "success")")
            },
            nil,        // Optional manufacturer identifier filter.
            false,      // Allow duplicate results.
            10_000      // Stop after 10 seconds.
        )
    }
}
```

### Read EVVA component advertisement

A scanned device exposes its latest received signal strength and parsed manufacturer data through `advertisementData`.

```swift
let advertisement = device.advertisementData
print(advertisement?.rssi as Any)
print(advertisement?.isConnectable as Any)

let manufacturerData = advertisement?.manufacturerData
print(manufacturerData?.batteryStatus as Any)
print(manufacturerData?.isOnline as Any)
print(manufacturerData?.officeModeEnabled as Any)
print(manufacturerData?.officeModeActive as Any)
```

`BleDeviceAdvertisementData` provides `rssi`, `isConnectable`, and optional `manufacturerData`. `BleDeviceManufacturerData` includes the company identifier, component and firmware versions, battery and online state, office-mode flags, identifier, and optional subcomponent fields.

### Localize an EVVA component

`signalize` connects to the scanned device and asks it to emit a melody to help locate it. It returns `false` if the operation fails.

```swift
extension Example {
    func signalizeDevice(_ deviceID: String) async {
        guard let device = bleDeviceMap[deviceID] else { return }
        let succeeded = await bleManager.signalize(device)
        debugPrint("Signalized: \(succeeded)")
    }
}
```

### Disengage an EVVA component

Disengagement requires credentials from the relevant Xesar medium data. The current `disengageWithXvnResponse` API accepts the `mobileID` string without pre-hashing it; the SDK hashes it while building the access frame. The legacy `disengage` API is deprecated and expects a SHA-256-hashed, hex-encoded `mobileID`.

```swift
extension Example {
    func disengageDevice(_ deviceID: String) async {
        guard let device = bleDeviceMap[deviceID] else { return }

        let mobileID = ""              // `xsMobileId` from the medium data.
        let mobileDeviceKey = ""       // `xsMOBDK` from the medium data.
        let mobileGroupID = ""         // `xsMOBGID` from the medium data.
        let mediumAccessData = ""      // `mediumDataFrame` from the medium data.
        let isPermanentRelease = false // Whether to request a permanent release.

        let (status, xvnData) = await bleManager.disengageWithXvnResponse(
            device,
            mobileID,
            mobileDeviceKey,
            mobileGroupID,
            mediumAccessData,
            isPermanentRelease
        )
        debugPrint("Status=\(status), XVN data=\(String(describing: xvnData))")
    }
}
```

`DisengageStatusType` includes component outcomes such as `AUTHORIZED` and `UNAUTHORIZED`, as well as interface errors such as `UNABLE_TO_CONNECT`, `TIMEOUT`, and `ACCESS_CIPHER_ERROR`. The XVN response is optional and is returned as `Data?`.

### Code an EVVA identification medium

Use `AuthManager` to retrieve coding-station MQTT options, then connect a `CodingStation` and start an NFC writing session. This example requires a coding-station URL, client ID, and login credentials; provide values for your installation.

```swift
import AbrevvaSDK
import Foundation

@MainActor
final class CodingStationExample {
    func writeMedium() async throws {
        guard let url = URL(string: "https://coding-station.example") else { return }
        guard let options = try await AuthManager.getMqttConfigForXS(
            url: url,
            clientId: "<coding-station-id>",
            username: "<username>",
            password: "<password>"
        ) else { return }

        let codingStation = CodingStation()
        defer { codingStation.disconnect() }

        try await codingStation.connect(options)
        try await codingStation.write()
    }
}
```
