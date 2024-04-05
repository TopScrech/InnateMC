import Foundation
import Zip

extension Instance {
    public func getLibrariesAsTasks() -> [DownloadTask] {
        var tasks: [DownloadTask] = []
        
        for library in libraries {
            tasks.append(library.asDownloadTask())
        }
        
        if self.minecraftJar.type == .remote {
            tasks.append(.init(sourceUrl: self.minecraftJar.url!, filePath: self.getMcJarPath(), sha1: self.minecraftJar.sha1))
        }
        
        return tasks
    }
    
    public func appendClasspath(args: inout [String]) {
        let libString = self.libraries
            .map { lib in
                return lib.getAbsolutePath().path
            }
            .joined(separator: ":")
        
        args.append("\(getMcJarPath().path):\(libString)")
    }
    
    public func extractNatives(progress: TaskProgress) {
        if !FileManager.default.fileExists(atPath: getNativesFolder().path) {
            try! FileManager.default.createDirectory(at: getNativesFolder(), withIntermediateDirectories: true)
        }
        
        let nativeLibraries = self.libraries.filter {
            $0.path.contains("natives")
        }
        
        logger.debug("Found \(nativeLibraries.count) natives to extract")
        
        for i in nativeLibraries.map({ $0.getAbsolutePath().path }) {
            print(i)
        }
        
        var extractTasks: [() -> Void] = []
        
        for nativeLibrary in nativeLibraries {
            extractTasks.append({
                let nativeLibraryPath = nativeLibrary.getAbsolutePath()
                logger.info("Extracting natives in \(nativeLibraryPath.path)")
                
                Instance.extractNativesFrom(library: nativeLibraryPath, output: self.getNativesFolder())
            })
        }
        
        ParallelExecutor.run(extractTasks, progress: progress)
    }
    
    private static func extractNativesFrom(library input: URL, output: URL) {
        do {
            let unzipDirectory = try Zip.quickUnzipFile(input)
            
            let fileManager = FileManager.default
            let files = fileManager.enumerator(atPath: unzipDirectory.path)
            
            while let filePath = files?.nextObject() as? String {
                if !shouldExtract(filePath) {
                    logger.debug("Skipping extracing \(filePath)")
                    continue
                }
                
                let fileURL = URL(fileURLWithPath: filePath, relativeTo: unzipDirectory)
                let outputURL = output.appendingPathComponent(fileURL.lastPathComponent)
                
                do {
                    try fileManager.copyItem(at: fileURL, to: outputURL)
                } catch {
                    ErrorTracker.instance.error(description: "Failed to copy \(fileURL.path) to \(outputURL.path)")
                }
            }
            
            try fileManager.removeItem(at: unzipDirectory)
        } catch {
            ErrorTracker.instance.error(description: "Failed to extract zip file: \(error)")
        }
    }
    
    private static func shouldExtract(_ path: String) -> Bool {
        path.hasSuffix("dylib") || path.hasSuffix("jnilib")
    }
    
    public func downloadLibs(progress: TaskProgress, onFinish: @escaping () -> Void, onError: @escaping (LaunchError) -> Void) -> URLSession {
        let tasks = getLibrariesAsTasks()
        
        return ParallelDownloader.download(tasks, progress: progress, onFinish: onFinish, onError: onError)
    }
    
    public func downloadAssets(progress: TaskProgress, onFinish: @escaping () -> Void, onError: @escaping (LaunchError) -> Void) -> URLSession? {
        var index: AssetIndex
        
        do {
            index = try AssetIndex.get(version: self.assetIndex.id, urlStr: self.assetIndex.url)
        } catch {
            onError(LaunchError.errorDownloading(error: error))
            return nil
        }
        
        return index.downloadParallel(progress: progress, onFinish: onFinish, onError: onError)
    }
}