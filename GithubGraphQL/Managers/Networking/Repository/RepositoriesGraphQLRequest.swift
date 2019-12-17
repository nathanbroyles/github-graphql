import Foundation
import Apollo

enum RepositoriesGraphQLRequest: GraphQLRequest {
  
  case searchRepositories

  // MARK: - Conforming methods
  func provideValues()-> (queue: DispatchQueue, cachePolicy: CachePolicy) {

    switch self {
    case .searchRepositories:
      return (queue: DispatchQueue.global(qos: .background), cachePolicy: CachePolicy.fetchIgnoringCacheData)
    }
  }
}
