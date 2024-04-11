import Foundation

enum LaunchError: Error {
    case errorDownloading(error: Error?)
    case invalidShaHash(error: Error?)
    case unknownError(error: Error?)
    case accessTokenFetchError(error: Error?)
    case errorCreatingFile(error: Error?)
    
    var cause: Error? {
        switch(self) {
        case .errorDownloading(let error),
                .invalidShaHash(let error),
                .unknownError(let error),
                .accessTokenFetchError(let error),
                .errorCreatingFile(let error):
            return error
        }
    }
    
    var localizedDescription: String {
        switch(self) {
        case .errorDownloading(_):
            NSLocalizedString("Failed to download specified file", comment: "no u")
            
        case .invalidShaHash(_):
            NSLocalizedString("Invalid SHA hash found", comment: "no u")
            
        case .unknownError(_):
            NSLocalizedString("An unknown error occurred while downloading. This is a bug!", comment: "no u")
            
        case .accessTokenFetchError(_):
            NSLocalizedString("Couldn't fetch Minecraft access token", comment: "no u")
            
        case .errorCreatingFile(_):
            NSLocalizedString("Failed to create file/directory", comment: "no u")
            
        }
    }
}
