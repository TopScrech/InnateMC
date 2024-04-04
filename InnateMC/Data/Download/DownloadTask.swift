import Foundation

public class DownloadTask {
    public let sourceUrl: URL
    public let filePath: URL
    public let sha1: String?
    
    public init(sourceUrl: URL, filePath: URL, sha1: String?) {
        self.sourceUrl = sourceUrl
        self.filePath = filePath
        self.sha1 = sha1
    }
}
