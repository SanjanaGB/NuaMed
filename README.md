# NuaMed

iOS app for allergy detection in your daily life. This project uses **Firebase** for backend services and **UIKit** for UI development.

---

## Table of Contents

- [Prerequisites](#prerequisites)
- [Setup Instructions](#setup-instructions)
- [Running the App](#running-the-app)
- [Contributing](#contributing)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

Before running the project, ensure you have the following installed:

- Xcode 15 or higher
- CocoaPods 1.12 or higher
- GitHub account to clone the repository
- Access to the Firebase project

---

## Setup Instructions

1. **Clone the Repository**

```bash
git clone https://github.com/SanjanaGB/NuaMed.git
cd NuaMed
````

2. **Request Firebase Configuration**

   * Contact the project owner to get access to Firebase
   * Get the `GoogleService-Info.plist` from Firebase.
   * Place it in the root of the Xcode project (next to the `.xcodeproj` file).
                
3. **Firebase Setup**

   *. Ensure you have access to the Firebase project.
   *. Place the `GoogleService-Info.plist` file in the Xcode project root.
   *. Confirm that the plist file is included in all necessary targets.

3. **Install Dependencies**

```bash
pod install
```

4. **Open the Workspace**

```bash
open NuaMed.xcworkspace
```

> Always open the `.xcworkspace` file instead of the `.xcodeproj` file after installing pods.

---

Dependencies include:

* `FirebaseCore`
* `FirebaseAuth`
* `FirebaseFirestore`

> If CocoaPods is outdated, update it with:

```bash
sudo gem install cocoapods
```

---

## Running the App

*. Open the `.xcworkspace` file in Xcode.
*. Select a simulator or a connected device.
*. Build and run the project with `Cmd + R`.

> Ensure the simulator or device has internet access to connect to Firebase.

---

## Contributing

1. Fork the repository.
2. Create a feature branch:

```bash
git checkout -b feature/<feature-name>
```

3. Make your changes and commit:

```bash
git commit -m "Add feature XYZ"
```

4. Push your branch:

```bash
git push origin feature/<feature-name>
```

5. Open a Pull Request in the main repository.

---

## Troubleshooting

* **White screen or build errors**: Ensure `GoogleService-Info.plist` is correctly placed and target membership is checked.
* **Pods not installing**: Run `pod repo update` then `pod install`.
* **Firebase not connecting**: Confirm the plist corresponds to the correct Firebase project and that the device has network access.

---

## Recommended `.gitignore` (for iOS + Firebase)


```bash
# Xcode
DerivedData/
*.xcuserdata
*.xccheckout
*.moved-aside
*.xcuserstate

# CocoaPods
Pods/
Podfile.lock

# Firebase config file
GoogleService-Info.plist

# Build
build/
*.ipa

# macOS
.DS_Store
```

