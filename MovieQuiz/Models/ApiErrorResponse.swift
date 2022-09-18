import Foundation

enum ApiError: Error {
    case genericError(message: String)
}

extension ApiError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .genericError(let message):
            return NSLocalizedString(message, comment: "API generic error")
        }
    }
}

struct ApiErrorResponse: Codable {
    let error: String

    private enum CodingKeys: String, CodingKey {
        case error = "errorMessage"
    }
}
