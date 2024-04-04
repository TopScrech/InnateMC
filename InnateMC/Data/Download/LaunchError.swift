import Foundation

public enum LaunchError: Error {
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
            NSLocalizedString("error_downloading", comment: "no u")
            
        case .invalidShaHash(_):
            NSLocalizedString("invalid_sha_hash_error", comment: "no u")
            
        case .unknownError(_):
            NSLocalizedString("error_unknown_download", comment: "no u")
            
        case .accessTokenFetchError(_):
            NSLocalizedString("error_fetching_access_token", comment: "no u")
            
        case .errorCreatingFile(_):
            NSLocalizedString("error_creating_file", comment: "no u")
            
        }
    }
}
