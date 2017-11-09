//
//  IconConverter.swift
//  Summaricon
//
//  Created by tueno on 2017/04/24.
//  Copyright © 2017年 tueno Ueno. All rights reserved.
//

import Foundation

final class IconConverter {
    
    static let Version = "0.1"
    
    func staticMode() {        
        if ConsoleIO.optionsInCommandLineArguments().contains(.help) {
            ConsoleIO.printUsage()
        } else if ConsoleIO.optionsInCommandLineArguments().contains(.version) {
            ConsoleIO.printVersion()
        } else {
            let ignoreDebugBuild = ConsoleIO.optionsInCommandLineArguments().contains(.ignoreDebugBuild)
            let flavor           = ConsoleIO.optionArgument(option: .flavorName) ?? ""
            let buildType        = ConsoleIO.optionArgument(option: .buildTypeName)!
            let outputPath       = ConsoleIO.optionArgument(option: .outputPath)!
            modifyIcon(ignoreDebugBuild: ignoreDebugBuild,
                       flavor: flavor,
                       buildType: buildType,
                       outputPath: outputPath)
        }
    }
    
    private func modifyIcon(ignoreDebugBuild: Bool, flavor: String, buildType: String, outputPath: String) {
        guard buildType != "release" && !(buildType == "debug" && ignoreDebugBuild) else {
            print("\(ConsoleIO.executableName) stopped because it is running for \(buildType) build.")
            return
        }
        
        print(String(format: "Target: %@%@", flavor, buildType))
        
        let manager = FileManager.default
        guard manager.fileExists(atPath: outputPath) else {
            print("Target apk file does not exists.")
            return
        }
        
        let outputDir = outputPath
            .components(separatedBy: "/")
            .dropLast()
            .joined(separator: "/")
        let outputFilename = outputPath
            .components(separatedBy: "/")
            .last!
            .components(separatedBy: ".")
            .first!
        let appDir = outputPath
            .components(separatedBy: "/")
            .dropLast().dropLast().dropLast().dropLast()
            .joined(separator: "/")
        
        // Extract apk
        _ = bash(command: "apktool",
                 currentDirPath: outputDir,
                 arguments: ["d", "-f", outputPath])
        
        // Find icon filename
        let iconFilename = findIconFilename(manifestPath: String(format: "%@/%@/AndroidManifest.xml", outputDir, outputFilename),
                                            iconAttrName: "icon")
        let roundIconFilename = findIconFilename(manifestPath: String(format: "%@/%@/AndroidManifest.xml", outputDir, outputFilename),
                                                 iconAttrName: "roundIcon")
        
        // Find icon image file by filename
        let resourceDirPath = String(format: "%@/%@/res", outputDir, outputFilename)
        let enumerator = manager.enumerator(atPath: resourceDirPath)
        let iconImagePathsArray = enumerator?
            .map({ (path) -> String in path as? String ?? "" })
            .filter({ (path: String) -> Bool in
                // FIXME: 部分一致なので判定が甘いが一旦これで
                // FIXME: It should be changed partial match to backward match.
                return path.contains(iconFilename) || path.contains(roundIconFilename)
            })
            .map({ (path) -> String in
                return String(format: "%@/%@", resourceDirPath, path)
            }) ?? []
        
        let branchName: String    = AppInfo.branchName
        let commitId: String      = AppInfo.commitId
        let versionCode: String   = AppInfo.versionCode(gradleFilePath: String(format: "%@/build.gradle", appDir))
        let versionName: String   = AppInfo.versionName(gradleFilePath: String(format: "%@/build.gradle", appDir))
        let dateStr: String       = currentDate()

        iconImagePathsArray
            .forEach { (path) in
                let imageWidthStr = bash(command: "identify",
                                      currentDirPath: nil,
                                      arguments: ["-format", "%w", path])
                let hudWidth        = Int(imageWidthStr) ?? 0
                let topHUDHeight    = 20
                let bottomHUDHeight = 48
                _ = bash(command: "convert",
                         currentDirPath: nil,
                         arguments: ["-channel", "rgb",
                                     "-background", "black",
                                     "-fill", "white",
                                     "-gravity", "center",
                                     "-size", String(format: "%dx%d", hudWidth, topHUDHeight),
                                     "caption:\(dateStr)",
                                     path,
                                     "+swap",
                                     "-gravity", "north" ,
                                     "-composite", path])
                _ = bash(command: "convert",
                         currentDirPath: nil,
                         arguments: ["-channel", "rgb",
                                     "-background", "black",
                                     "-fill", "white",
                                     "-gravity", "center",
                                     "-size", String(format: "%dx%d", hudWidth, bottomHUDHeight),
                                     "caption:\(versionName)(\(versionCode)) \(flavor) \n\(branchName) \n\(commitId)",
                                     path,
                                     "+swap",
                                     "-gravity", "south" ,
                                     "-composite", path])
            }
        
        // Recompose apk
        _ = bash(command: "apktool",
                 currentDirPath: outputDir,
                 arguments: ["b", outputFilename, "-o", String(format:"%@.apk", outputFilename)])
        _ = bash(command: "jarsigner",
                 currentDirPath: "~/",
                 arguments: ["-keystore", ".android/debug.keystore",
                             "-storepass", "android",
                             String(format:"%@/%@.apk", outputDir, outputFilename), "androiddebugkey"])
        print("Icon processing finished.")
    }
    
    private func findIconFilename(manifestPath: String, iconAttrName: String) -> String {
        // Find icon filename
        let output = bash(command: "xpath",
                          currentDirPath: nil,
                          arguments: [manifestPath,
                                      String(format: "/manifest/application/@android:%@",
                                             iconAttrName)])
        let strToRemove = matches(for: String(format: "android:%@=.*\\/",
                                              iconAttrName),
                                  in: output)
            .first ?? ""
        let iconFilename = output.replacingOccurrences(of: strToRemove,
                                                       with: "")
            .replacingOccurrences(of: "\"", with: "")
            .replacingOccurrences(of: " ", with: "")
        return iconFilename
    }
    
    private func currentDate() -> String {
        let cal = Calendar(identifier: .gregorian)
        let dateComp = cal.dateComponents([.year, .month, .day, .minute, .hour],
                                          from: Date())
        return String(format: "%02d:%02d %02d/%02d %04d", dateComp.hour!,
                      dateComp.minute!,
                      dateComp.month!,
                      dateComp.day!,
                      dateComp.year!)
    }
    
}
