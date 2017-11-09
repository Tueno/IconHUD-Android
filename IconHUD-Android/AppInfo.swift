//
//  AppInfo.swift
//  Summaricon
//
//  Created by tueno on 2017/04/25.
//  Copyright © 2017年 Tomonori Ueno. All rights reserved.
//

final class AppInfo {
    
    class var branchName: String {
        get {
            let branchName = bash(command:"git",
                                  currentDirPath: nil,
                                  arguments: ["rev-parse", "--abbrev-ref", "HEAD"])
            if branchName == "HEAD" {
                // On Travis CI
                return ConsoleIO.environmentVariable(key: .branchNameOnTravisCI)
            } else {
                return branchName
            }
        }
    }

    class var commitId: String {
        get {
            let commitId = bash(command: "git",
                                currentDirPath: nil,
                                arguments: ["rev-parse", "--short", "HEAD"])
            return commitId
        }
    }
    
    class func versionCode(gradleFilePath: String) -> String {
        let buildGradle = bash(command: "cat",
                               currentDirPath: nil,
                               arguments: [gradleFilePath])
        let versionCode = matches(for: "versionCode [0-9]*", in: buildGradle)
            .first?
            .replacingOccurrences(of: "versionCode", with: "")
            .replacingOccurrences(of: " ", with: "") ?? ""
        return versionCode
    }
    
    class func versionName(gradleFilePath: String) -> String {
        let buildGradle = bash(command: "cat",
                               currentDirPath: nil,
                               arguments: [gradleFilePath])
        let versionName = matches(for: "versionName [\'\"][0-9\\.]+[\'\"]", in: buildGradle)
            .first?
            .replacingOccurrences(of: "versionName", with: "")
            .replacingOccurrences(of: "\'", with: "")
            .replacingOccurrences(of: "\"", with: "")
            .replacingOccurrences(of: " ", with: "") ?? ""
        return versionName
    }
    
}
