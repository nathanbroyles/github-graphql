import Foundation
import Apollo

struct RepositoriesGraphQLClient: GraphQLClient {
  // MARK: - Public methods
  static func searchRepositories<Query: GraphQLQuery>(query: Query, _ completionHandler: @escaping GraphQLCompletionHandler<Query>) {
    GQLClient.runQuery(request: RepositoriesGraphQLRequest.searchRepositories, query: query) { result in
      switch result {
      case .success(let data):
        self.handle(result: data, error: nil, completionHandler: completionHandler)
      case .failure(let error):
        self.handle(result: nil, error: error, completionHandler: completionHandler)
      }
    }
  }
}
