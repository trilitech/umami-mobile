# Umami Mobile

## Overview

A mobile version of the Umami Tezos wallet.

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
