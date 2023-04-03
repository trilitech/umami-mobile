# Umami Mobile

## Overview

A mobile version of the Umami Tezos wallet.

## Initial setup

You need to make sure that all the dependencies are installed. Please make sure that you are using yarn v1 (e.g. v1.22.19).

```sh
yarn install
```

If you are going to build and run your app on an iOS then please also make sure that cocoapods are installed and then run this command from the ios folder

```sh
pod install
```

## Commands

Compile rescript source to javascript:

```sh
yarn res:build

```

Compile rescript source to javascript in watch mode:

```sh
yarn res:watch
```

Run app in IOS Sim (Mac Only)

```sh
yarn ios
```

Run app in simulator with a specified device. See [this answser](https://stackoverflow.com/a/37329896/6797267):

```sh
npx react-native run-ios --simulator="iPhone 8"
```

Run tests in watch mode:

```sh
yarn test:watch
```

## iOS build errors

When archiving the app after a fresh `pod install`, you probably will get the following error:

> Multiple commands produce 'path/AccessibilityResources.bundle

To fix this error, just delete `React-Core.common-AccessibilityResources` in the Pods project as described [here](https://stackoverflow.com/a/65083990/6797267).
