//
//  AssetIndex.swift
//  InnateKit
//
//  Created by Shrish Deshpande on 11/21/22.
//

import Foundation
import InnateJson

public class AssetIndex {
    private let version: String
    private let json: String
    private let objects: [String: InnateValue]
    
    init(version: String, json: String, objects: [String: InnateValue]) {
        self.version = version
        self.json = json
        self.objects = objects
    }
    
    public static func download(version: String, urlStr: String) throws -> AssetIndex {
        if let url = URL(string: urlStr) {
            let contents = try String(contentsOf: url)
            let json = InnateParser.readJson(contents)!
            let objects = json["objects"]!.asObject()!
            return AssetIndex(version: version, json: contents, objects: objects)
        } else {
            fatalError("Not possible")
        }
    }
    
    public func download(progress: inout DownloadProgress) throws {
        progress.total = objects.count
        progress.current = 0
        let assetsRoot: URL = DataHandler.getOrCreateFolder("Assets")
        let indexes: URL = assetsRoot.appendingPathComponent("indexes", isDirectory: true)
        let fm = FileManager.default
        if !fm.fileExists(atPath: indexes.path) {
            try fm.createDirectory(at: indexes, withIntermediateDirectories: true)
        }
        let objects: URL = assetsRoot.appendingPathComponent("objects", isDirectory: true)
        if !fm.fileExists(atPath: objects.path) {
            try fm.createDirectory(at: objects, withIntermediateDirectories: true)
        }
        let indexesFile: URL = indexes.appendingPathComponent(self.version + ".json", isDirectory: false)
        if !fm.fileExists(atPath: indexesFile.path) {
            fm.createFile(atPath: indexesFile.path, contents: self.json.data(using: .utf8))
        }
        for (_, v) in self.objects {
            let hash = v.asObject()!["hash"]!.asString()!
            let hashPre = String(hash.substring(to: hash.index(after: hash.index(after: hash.startIndex))))
            let hashFolder = objects.appendingPathComponent(hashPre)
            if !fm.fileExists(atPath: hashFolder.path) {
                try fm.createDirectory(at: hashFolder, withIntermediateDirectories: true)
            }
            let file = hashFolder.appendingPathComponent(hash)
            if !fm.fileExists(atPath: file.path) {
                let url = URL(string: "http://resources.download.minecraft.net/" + hashPre + "/" + hash)!
                let contents = try Data(contentsOf: url)
                fm.createFile(atPath: file.path, contents: contents)
            }
            progress.current += 1
        }
    }
}