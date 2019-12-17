import Foundation
import Apollo

///GraphQL request returns a GraphQLResult object
public typealias GraphQLCompletionHandler<Operation: GraphQLOperation> = (Result<Operation>) -> Void

/// The base URL for connecting to the Github GraphQL endpoint
let githubGQL = "https://api.github.com/graphql"
let githubToken = "8fdf9f0f2f34fa544df9473ade4fa433fcbe5cba"

/// HTTP method definitions.
/// See https://tools.ietf.org/html/rfc7231#section-4.3
public enum HTTPMethod: String {
  case options = "OPTIONS"
  case get     = "GET"
  case head    = "HEAD"
  case post    = "POST"
  case put     = "PUT"
  case patch   = "PATCH"
  case delete  = "DELETE"
  case trace   = "TRACE"
  case connect = "CONNECT"
}

struct MimeType {
  static let json = "application/json"
}

struct HttpHeaders {
  static let contentType = "Content-Type"
  static let authorization = "Authorization"
}

struct GraphQLParams {
  static let variables  = "variables"
  static let id         = "id"
  static let query      = "query"
}

protocol GraphQLRequest {
  
  /// Provides all the information required to make the API call from Apollo
  func provideValues()-> (queue: DispatchQueue, cachePolicy: CachePolicy)
  
  var queue: DispatchQueue      { get }
  var cachePolicy: CachePolicy  { get }
}

extension GraphQLRequest {
  var queue: DispatchQueue        { return provideValues().queue }
  var cachePolicy: CachePolicy    { return provideValues().cachePolicy }
}


/// Types that conform to this can return results from the GraphQL API
protocol GraphQLClient {
  static func handle<Operation: GraphQLOperation>(result: GraphQLResult<Operation.Data>?, error: Error?, completionHandler: GraphQLCompletionHandler<Operation>?)
}

extension GraphQLClient {
  static func handle<Operation>(result: GraphQLResult<Operation.Data>?,
                                error: Error?,
                                completionHandler: ((Result<Operation>) -> Void)?) where Operation : GraphQLOperation {
    
    guard let completionHandler = completionHandler else {
      return
    }
    
    if let error = error {
      completionHandler(Result.failure(error))
      return
    }
    
    if let result = result {
      
      if let errors = result.errors, let error = errors.first {
        completionHandler(Result.failure(error))
        return
      }
      
      completionHandler(Result.success(result))
    }
    else {
      completionHandler(Result.failure(nil))
    }
  }
}
