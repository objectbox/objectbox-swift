#!/usr/bin/env bash
set -eu

# Typical ObjectBox project setup using CocoaPods; see https://swift.objectbox.io/install for details.

pod repo update
pod install
Pods/ObjectBox/setup.rb
