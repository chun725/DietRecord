# 食話實說
<img src="https://user-images.githubusercontent.com/80617086/208041216-6ab5108b-aa89-4dde-9e0f-9a50c7222167.png"/>

![image](https://img.shields.io/badge/platform-iOS-lightgrey) ![image](https://img.shields.io/badge/release-v1.2.1-green) ![image](https://img.shields.io/badge/license-MIT-yellow)

[<img height="100" src="https://user-images.githubusercontent.com/80617086/208040529-9c0dfc86-314f-4b82-ac27-6ad3b53d4a1f.png"/>](https://reurl.cc/MX2qp4)

# About
This App helps users record diet and automatically calculate nutrient intake, allowing them to keep track of their meals and make better food choices. In addition, users can share their diet records with their followers via the social community in the App.

# Table of Contents
1. [Features](#Features)
1. [Techniques](#Techniques)
1. [Requirements](#Requirements)
1. [Limitations](#Limitations)
1. [Release Notes](#Release-Notes)
1. [Libraries](#Libraries)
1. [Contact](#Contact)
1. [License](#License)


## Features
* **Diet Record**
    * Input the diet information of date, meal, foods, image and comment
    * Allow users record their diet and automatically calculate nutrient intake

    <img src="https://user-images.githubusercontent.com/80617086/208040655-bfca5b9c-bbfc-4eaf-9d9c-fc7b6ed19437.png"/>

* **Profile Page**
    * Browse diet records
    * Follow other users to browse their diet records
    * Communicate with other users via liking and responsing
    * Edit personal information

    <img height="400" src="https://user-images.githubusercontent.com/80617086/208040761-06ca37df-f5e1-4dac-85b5-aee15d99d5ef.png"/>
    
* **Water Page**
    * Input the water intake
    * Create water drinking reminders allowing the app send notifications to remind user
    * Browse the history records of water intake

    <img height="400" src="https://user-images.githubusercontent.com/80617086/208040810-5ec6b4fb-2bc1-4e3a-b24f-dc8063ad55a3.png"/>

* **Report Page**
    * Apply the histogram to display the difference in calories intake over 7 days
    * Gain the intake of various nutrients over 7 days
    * Set dietary goals by entering them directly or entering personal informations allowing the app calculate it for use

    <img height="400" src="https://user-images.githubusercontent.com/80617086/208040871-3ed1fddc-8b0d-44cc-9742-aae8e1d70bcd.png"/>
    
* **Weight Page**                                                                          
    * Visualize the weight changes with a line chart
    
    <img height="400" src="https://user-images.githubusercontent.com/80617086/208040933-bb48f204-f127-4b50-9293-3114d1a5e462.png"/> 

* **Widget**
    * Establish the widgets allowing users to place on the home screen for quick browsing

    <img height="400" src="https://user-images.githubusercontent.com/80617086/208041007-ffadc389-a792-4088-b6d3-8d07b1fd9194.png"/>

## Techniques
* Synchronized the weight records with Apple Health by [`HealthKit`](https://developer.apple.com/documentation/healthkit)
* Visualized users' water intake, nutrient intake and weight records via the third party library `Charts`
* Implemented local notifications reminding users to drink water
* Created a [`Widget`](https://developer.apple.com/documentation/swiftui/widget) extension with the water intake chart and the diet intake chart, which allowed users to place on the home screen for quick browsing
* Used `Firebase Firestore` to store users' weight, water and diet records
* Applied `Firebase Authentication` and Sign in with Apple for login flow
* Provided valuable dietary information based on the food nutrition database of Taiwan Food and Drug Administration

## Requirements 

| Item                  | Supported         |
| -------------         |:-------------:    |
| Xcode version         | 13.4+             |
| iPhone version        | iOS 14+           |
| Swift version         | 5+                |

## Limitations
| Item                  | Limitations       |
| -------------         |:-------------:    |
| Dark / Light mode     | Light mode only   |
| Orientation           | Portrait only     |

## Release Notes
![image](https://img.shields.io/badge/current-v1.2.1-green)

| Version       |       Date        |    Note                                                     |
| :-----------: |:-------------:    |-------------------------------------------------------------|
| 1.2.1         | 2022/12/15        | Fixed minor bugs                                            |
| 1.2.0         | 2022/12/08        | Fixed the animation and the feature of redirecting page     |
| 1.0.2         | 2022/12/02        | First released on App Store                                 |

## Libraries
* [Firebase](https://github.com/firebase/firebase-ios-sdk)
* [Kingfisher](https://github.com/onevcat/Kingfisher)
* [Charts](https://github.com/danielgindi/Charts)
* [IQKeyboardManager](https://github.com/hackiftekhar/IQKeyboardManager)
* [JGProgressHUD](https://github.com/JonasGessner/JGProgressHUD)
* [lottie-ios](https://github.com/airbnb/lottie-ios)
* [SwiftJWT](https://github.com/Kitura/Swift-JWT)
* [KeychainSwift](https://github.com/evgenyneu/keychain-swift)
* [SwiftLint](https://github.com/realm/SwiftLint)

## Contact 
- E-mail | chibo0725@gmail.com
- Linkedin | [chun725](https://www.linkedin.com/in/chun725)

## License
食話實說 is licensed under the terms of the MIT license. See [LICENSE](https://github.com/chun725/DietRecord/blob/LicenseAndReadme/LICENSE) for details.
