//
//  main.swift
//  ToolTestProject
//
//  Created by Uli Kusterer on 11.12.18.
//  Copyright © 2018 Uli Kusterer. All rights reserved.
//

import Foundation

do {
    exit(try main(CommandLine.arguments))
} catch {
    print("error: \(CommandLine.arguments[1]): Uncaught exception \(error)")
    exit(777)
}
