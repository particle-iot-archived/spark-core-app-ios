# Spark iOS Application

This is the open source version of the iOS app from Spark Labs, Inc. for controlling the Spark Core. It provides key functionality of SmartConfig and Tinker.

## Building

*USERS MUST DOWNLOAD THE SMART CONFIG LIBRARY FROM TEXAS INSTRUMENTS, AGREE TO THAT LICENSE, AND ADD IT TO THIS APP. MORE THOROUGH INSTRUCTIONS WILL BE PROVIDED IN THE FUTURE.  FEEL FREE TO SUBMIT PULL REQUESTS WITH GOOD BUILD INSTRUCTIONS.* :smile:

This project is designed to be build againt iOS 7 SDK and will not work with others. It does makes use of third-party
libraries which are bundled. Those include GCDAsyncSocket and CocoaLumberjack.

## Design

This application does not save any data locally expect account information (which is saved in Keychain). All data is
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
