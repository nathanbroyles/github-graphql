//
//  RepoTableViewCellViewModel.swift
//  GithubGraphQL
//
//  Created by Nathan Broyles on 12/16/19.
//  Copyright © 2019 test. All rights reserved.
//

import Foundation

struct RepoTableViewCellViewModel {
    
    let repoName: String
    let ownerName: String
    let ownerAvatarUrl: String
    let starCount: Int
    let repoUrl: String
    
    init(with repoDetails: RepositoryDetails) {
        self.repoName = repoDetails.name
        self.ownerName = repoDetails.owner.login
        self.ownerAvatarUrl = repoDetails.owner.avatarUrl
        self.starCount = repoDetails.stargazers.totalCount
        self.repoUrl = repoDetails.url
    }
}
