import Foundation

public struct Http {
    private static let session = URLSession(configuration: .default)
    
    public static func `get`(_ url: String) -> RequestBuilder {
        .init(url: URL(string: url)!, method: .get)
    }
    
    public static func post(_ url: String) -> RequestBuilder {
        .init(url: URL(string: url)!, method: .post)
    }
    
    public static func `get`(url: URL) -> RequestBuilder {
        .init(url: url, method: .get)
    }
    
    public static func post(url: URL) -> RequestBuilder {
        .init(url: url, method: .post)
    }
    
    public struct RequestBuilder {
        private var urlRequest: URLRequest
        
        init(url: URL, method: InnateHttpMethod) {
            urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = method.rawValue
            urlRequest.setValue("InnateMC", forHTTPHeaderField: "User-Agent")
        }
        
        func header(_ value: String?, field: String) -> RequestBuilder {
            var builder = self
            builder.urlRequest.setValue(value, forHTTPHeaderField: field)
            
            return builder
        }
        
        @discardableResult
        func json<T: Encodable>(_ body: T) throws -> RequestBuilder {
            var builder = self
            let jsonData = try JSONEncoder().encode(body)
            
            builder.urlRequest.httpBody = jsonData
            builder.urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            return builder
        }
        
        @discardableResult
        func string(_ body: String) -> RequestBuilder {
            var builder = self
            
            builder.urlRequest.httpBody = body.data(using: .utf8)
            builder.urlRequest.setValue("text/plain", forHTTPHeaderField: "Content-Type")
            
            return builder
        }
        
        @discardableResult
        func body(_ body: Data?) -> RequestBuilder {
            var builder = self
            builder.urlRequest.httpBody = body
            
            return builder
        }
        
        func request() async throws -> (Data, URLResponse?) {
            let (data, urlResponse) = try await Http.session.data(for: urlRequest)
            
            return (data, urlResponse)
        }
    }
}
