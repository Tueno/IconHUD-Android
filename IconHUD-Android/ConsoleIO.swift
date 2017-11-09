//
//  ConsoleIO.swift
//  Summaricon
//
//  Created by tueno on 2017/04/24.
//  Copyright © 2017年 tueno Ueno. All rights reserved.
//

import Foundation

final class ConsoleIO {
    
    // MARK: Input
    
    class func optionsInCommandLineArguments() -> [OptionType] {
        let arguments = CommandLine.arguments
        let containingOptions = OptionType.allValues
            .filter { (option) -> Bool in
                return option.values
                    .filter({ (value) -> Bool in
                        return arguments.contains(value)
                    })
                    .count > 0
            }
        return containingOptions
    }
    
    class func optionArgument(option: OptionType) -> String? {
        let arguments = CommandLine.arguments
        let index = arguments
            .enumerated()
            .filter { (index: Int, argument: String) -> Bool in
                return option.values.contains(argument)
            }
            .first?
            .offset
        guard let i = index, i+1 < arguments.count, !arguments[i+1].hasPrefix("-") else {
            return nil
        }
        return arguments[i+1]
    }
    
    class func environmentVariable(key: EnvironmentVariable) -> String {
        return ProcessInfo().environment[key.rawValue] ?? ""
    }
    
    class var executableName: String {
        get {
            return CommandLine.arguments.first!
                .components(separatedBy: "/")
                .last!
        }
    }
    
    // MARK: Output
    
    class func printVersion() {
        print(IconConverter.Version)
    }
    
    class func printUsage() {
        print("Usage:")
        print("")
        print("     Add the script below to app.gradle of your AndroidStudio project.")
        print("")
        print("// iconhud")
        print("task iconhud {")
        print("    doLast {")
        print("        android.applicationVariants.all { variant ->")
        print("            variant.outputs.each { output ->")
        print("                exec {")
        print("                    executable \"/usr/local/bin/iconhud-android\"")
        print("                    args \"--build-type-name\", variant.buildType.name, \"--build-flavor-name\", variant.flavorName, \"--output-path\", output.outputFile")
        print("                    ignoreExitValue true")
        print("                }")
        print("            }")
        print("        }")
        print("    }")
        print("}")
        print("gradle.buildFinished { result ->")
        print("    if (!result.failure) {")
        print("        iconhud.execute()")
        print("    }")
        print("}")
        print("")
        print("Options:")
        print("")
        OptionType.allValues
            .forEach { (option) in
                let argumentsStr = option.valuesToPrint
                print("     [\(argumentsStr)]\(option.usage)")
            }
        printNotice()
    }
    
    class func printNotice() {
        print("")
        print("*** IMPORTANT ***")
        print("\(executableName) currently uses BuildType name to detect Relase build.")
        print("So if you change Release BuildType name, \(executableName) will process icon even if you want to build for release.")
        print("")
    }
    
}
