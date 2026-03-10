[![Swift 6](https://img.shields.io/badge/Swift-6.0-orange.svg?style=flat)](https://swift.org) [![Platform](https://img.shields.io/badge/Platform-iOS_17+-blue.svg)](https://developer.apple.com/ios/) [![License](https://img.shields.io/badge/License-Proprietary-lightgrey.svg)](LICENSE)
# Todoer
[![Download on the App Store](https://developer.apple.com/assets/elements/badges/download-on-the-app-store.svg)](https://apps.apple.com/es/app/todoer/id6476218460?l=en-GB)

A modern task management app built with Swift 6 using Redux architecture and Firebase Firestore.

| ![Image1](/docs/media/00.gif) | ![Image2](/docs/media/01.png) | ![Image3](/docs/media/02.png) | ![Image4](/docs/media/03.png) |
|:---------------------:|:---------------------:|:---------------------:|:---------------------:|

## Table of Contents
- [🚀 Features](#-features)
- [📦 Installation](#-installation)
- [⚙️ Requirements](#️-requirements)
- [🏗 Architecture](#-architecture)
- [🧪 Testing](#-testing)
- [🌎 Web](#-web)
- [👨💻 Author](#-author)
- [© License](#-license)

## 🚀 Features
- Real-time data synchronization with Firebase Firestore
- Apple and Google Sign-In integration
- Redux-based state management
- Crash reporting with Crashlytics

## 📦 Installation

### Development Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/username/Todoer.git
   ```
2. Install dependencies using Xcode 15+ (SPM packages will resolve automatically)

3. Configure Firebase: for security reasons the GoogleService-Info.plist can't be provided, add your GoogleService-Info.plist to Todoer/Resources.

4. Build & run using ⌘R

## ⚙️ Requirements
- Xcode 15+ (Swift 6 toolchain)
- iOS 17+ deployment target
- Active Firebase project configuration

## 🏗 Architecture
### Redux Implementation
The app follows a unidirectional data flow pattern:
   ```swift
View → Action → Reducer → State → View
   ```
##### Key components:

- Store: Central state container
- Reducers: Pure functions handling state transitions

##### Dependencies
| **Package**            | **Version** | **Purpose**                   |
|-------------------------|------------|--------------------------------|
| [xRedux](https://github.com/xvicient/xRedux) [![Propietary](https://img.shields.io/badge/Proprietary-lightgrey.svg)](Propietary) | 1.0+      | Feature state management architecture  |
| [FirebaseFirestore](https://firebase.google.com/docs/firestore) | 10.0+      | Real-time database           |
| [FirebaseAuth](https://firebase.google.com/docs/auth)         | 10.0+      | User authentication          |
| [FirebaseCrashlytics](https://firebase.google.com/docs/crashlytics) | 10.0+      | Crash reporting               |
| [GoogleSignIn](https://developers.google.com/identity/sign-in/ios) | 7.0+       | Google authentication         |


## 🧪 Testing
### Test Includes:

- Unit tests for Redux reducers (95% coverage)
- Integration tests for Firebase Firestore.
- Performance tests for critical paths

## 🌎 Web
### Installation

1. Navigate to the `Web` directory.
2. Create a `config.js` file based on your Firebase Console settings:
   ```javascript
   export const firebaseConfig = {
     apiKey: "YOUR_API_KEY",
     authDomain: "your-project.firebaseapp.com",
     projectId: "your-project",
     // ... rest of config
   };
3. Open the index.html using a live server.

## 👨💻 Author

Xavier Vicient Manteca

[GitHub](https://github.com/xvicient) • [LinkedIn](https://www.linkedin.com/in/xvicient/)

## © License

This project is proprietary software. All rights reserved © 2025 Xavier Vicient Manteca. Unauthorized distribution is prohibited.