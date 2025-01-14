// RUN: %target-run-simple-swift(%S/Inputs/print.swift -enable-experimental-feature Embedded -runtime-compatibility-version none -wmo -Xfrontend -disable-objc-interop) | %FileCheck %s
// RUN: %target-run-simple-swift(%S/Inputs/print.swift -O -enable-experimental-feature Embedded -runtime-compatibility-version none -wmo -Xfrontend -disable-objc-interop) | %FileCheck %s
// RUN: %target-run-simple-swift(%S/Inputs/print.swift -Osize -enable-experimental-feature Embedded -runtime-compatibility-version none -wmo -Xfrontend -disable-objc-interop) | %FileCheck %s

// REQUIRES: swift_in_compiler
// REQUIRES: executable_test
// REQUIRES: optimized_stdlib
// REQUIRES: OS=macosx

@main
struct Main {
  static func main() {
    var s: Set<Int> = [1, 2, 3]
    s.insert(42)
    s.sorted()
    s.allSatisfy { $0 > 0 }
    s.contains { $0 > 0 }
    s.map { $0 * 2 }
    s.filter { $0 > 0 }
    s.firstIndex(of: 42)
    s.min()
    s.max()
    s.reduce(0, +)
    // s.shuffled()
    // s.randomElement()
    print("OK!")
  }
}

// CHECK: OK!
