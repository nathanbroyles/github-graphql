import UIKit
import Apollo
import SafariServices

class RepoListViewController: UIViewController {

    var viewModel = RepoListViewModel()
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.repoFetchCompleted = {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        viewModel.repoFetchError = { (query, error) in
            DispatchQueue.main.async {
                let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                let retryAction = UIAlertAction(title: "Retry", style: .default) { (_) in
                    self.viewModel.fetchRepos(with: query)
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alertController.addAction(retryAction)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
        
        let gqlQuery = SearchRepositoriesQuery.init(first: viewModel.itemFetchCount, query: viewModel.query, type: SearchType.repository)
        viewModel.fetchRepos(with: gqlQuery)
    }
}

extension RepoListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.cellViewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RepoTableViewCell.self), for: indexPath) as! RepoTableViewCell
        cell.viewModel = viewModel.cellViewModels[indexPath.row]
        return cell
    }
}

extension RepoListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let repoUrl = URL(string: viewModel.cellViewModels[indexPath.row].repoUrl) else { return }
        let safariViewController = SFSafariViewController(url: repoUrl)
        present(safariViewController, animated: true, completion: nil)
    }
}

extension RepoListViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // scrollViewDidScroll gets called right away, prevent fetch by checking that we have cell view models
        guard viewModel.cellViewModels.count > 0 else { return }
        
        // if the user scrolls within 100pts of the list bottom, fetch more
        if scrollView.contentOffset.y + UIScreen.main.bounds.height > scrollView.contentSize.height - 100 {
            let gqlQuery = SearchRepositoriesQuery.init(first: viewModel.itemFetchCount, after: viewModel.nextPageCursor, query: viewModel.query, type: SearchType.repository)
            viewModel.fetchRepos(with: gqlQuery)
        }
    }
}
