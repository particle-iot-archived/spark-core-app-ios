# Spark iOS Application

This is official application of Spark Devices for the Spark Core. It provides key functionality of SmartConfig and Tinker.

## Building

This project is designed to be build againt iOS 7 SDK and will not work with others. It does makes use of third-party
libraries which are bundled. Those include GCDAsyncSocket and CocoaLumberjack.

## Design

This application does not sure any data locally expect account information (which is saved in Keychain). All data is
retrieved from the Spark Core API at launch.

Key classes include

### Logic

* SPKSpark - Singleton class that manages the list of Cores, active Core and SmartConfig
* SPKWebClient - All API calls are made and processed here
* SPKSmartConfig / SPKSmartConfigPayload - TI SmartConfig custom implementation and logic
* SPKUser - Spark account management

### UI

* Storyboard - All UI is implement via a Storyboard
* SPKCorePinView - Programatic view implemented for all pin functionality / display
