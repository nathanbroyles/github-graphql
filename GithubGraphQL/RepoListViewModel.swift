//
//  RepoListViewModel.swift
//  GithubGraphQL
//
//  Created by Nathan Broyles on 12/17/19.
//  Copyright © 2019 test. All rights reserved.
//

import Foundation

class RepoListViewModel {
    
    let query = "graphql"
    let itemFetchCount = 20
    private var isLoading = false
    private(set) var cellViewModels = [RepoCellViewModel]()
    private(set) var nextPageCursor: String? = nil
    
    var repoFetchCompleted: (() -> Void)?
    var repoFetchError: ((SearchRepositoriesQuery, Error) -> Void)?
    
    func fetchRepos(with query: SearchRepositoriesQuery) {
        guard isLoading == false else { return }
        isLoading = true
        
        RepositoriesGraphQLClient.searchRepositories(query: query) { (result) in
            self.isLoading = false
            
            switch result {
            case .success(let data):
                if let gqlResult = data {
                    if let pageInfo = gqlResult.data?.search.pageInfo {
                        self.nextPageCursor = pageInfo.endCursor
                    }

                    gqlResult.data?.search.edges?.forEach { edge in
                        guard let repository = edge?.node?.asRepository?.fragments.repositoryDetails else { return }
                        let cellViewModel = RepoCellViewModel(with: repository)
                        self.cellViewModels.append(cellViewModel)
                    }

                    self.repoFetchCompleted?()
                }
            case .failure(let error):
                if let error = error {
                    self.repoFetchError?(query, error)
                }
            }
        }
    }
}
