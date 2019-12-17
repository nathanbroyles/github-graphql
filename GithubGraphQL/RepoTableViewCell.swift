//
//  RepoTableViewCell.swift
//  GithubGraphQL
//
//  Created by Nathan Broyles on 12/16/19.
//  Copyright © 2019 test. All rights reserved.
//

import UIKit
import Kingfisher

class RepoTableViewCell: UITableViewCell {

    var viewModel: RepoCellViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            configure(with: viewModel)
        }
    }
    
    @IBOutlet weak var repoNameLabel: UILabel!
    @IBOutlet weak var starCountLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var ownerNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.width / 2
    }

    func configure(with viewModel: RepoCellViewModel) {
        repoNameLabel.text = viewModel.repoName
        starCountLabel.text = "★ \(viewModel.starCount)"
        avatarImageView.kf.setImage(with: URL(string: viewModel.ownerAvatarUrl))
        ownerNameLabel.text = viewModel.ownerName
    }
}
