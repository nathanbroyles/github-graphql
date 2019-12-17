import UIKit
import Apollo
import SafariServices

class ViewController: UIViewController {

    /// Prevent multiple fetches occuring by keeping track of current state.
    enum State {
        case fetching
        case normal
    }
    /// Common constants to use throughout the code.
    struct Constants {
        static let query = "graphql"
        static let itemsToFetch = 20
    }
    /// Store and set initial state.
    var state = State.normal
    /// Array of current cell view models.
    var repoCellViewModels = [RepoTableViewCellViewModel]()
    /// Store next page cursor for infinite scroll fetching. If nil, activity indicator will hide.
    var nextPageCursor: String? = nil {
        didSet {
            if nextPageCursor == nil {
                activityIndicator.stopAnimating()
            }
        }
    }
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        let gqlQuery = SearchRepositoriesQuery.init(first: Constants.itemsToFetch, query: Constants.query, type: SearchType.repository)
        
        fetchRepos(with: gqlQuery)
    }
    
    func fetchRepos(with query: SearchRepositoriesQuery) {
        guard state == .normal else { return }
        state = .fetching
        
        RepositoriesGraphQLClient.searchRepositories(query: query) { (result) in
            self.state = .normal
            
            switch result {
            case .success(let data):
                if let gqlResult = data {
                    if let pageInfo = gqlResult.data?.search.pageInfo {
                        self.nextPageCursor = pageInfo.endCursor
                    }

                    gqlResult.data?.search.edges?.forEach { edge in
                        guard let repository = edge?.node?.asRepository?.fragments.repositoryDetails else { return }
                        let cellViewModel = RepoTableViewCellViewModel(with: repository)
                        self.repoCellViewModels.append(cellViewModel)
                    }

                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            case .failure(let error):
                if let error = error {
                    let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                    let retryAction = UIAlertAction(title: "Retry", style: .default) { (_) in
                        self.fetchRepos(with: query)
                    }
                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    alertController.addAction(retryAction)
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repoCellViewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RepoTableViewCell.self), for: indexPath) as! RepoTableViewCell
        cell.viewModel = repoCellViewModels[indexPath.row]
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let repoUrl = URL(string: repoCellViewModels[indexPath.row].repoUrl) else { return }
        let safariViewController = SFSafariViewController(url: repoUrl)
        present(safariViewController, animated: true, completion: nil)
    }
}

extension ViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard repoCellViewModels.count > 0 else { return }
        if scrollView.contentOffset.y + UIScreen.main.bounds.height > scrollView.contentSize.height - 100 {
            let gqlQuery = SearchRepositoriesQuery.init(first: Constants.itemsToFetch, after: nextPageCursor, query: Constants.query, type: SearchType.repository)
            fetchRepos(with: gqlQuery)
        }
    }
}
