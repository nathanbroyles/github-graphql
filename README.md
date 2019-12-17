# The Peek iOS Coding Challenge

<img src="https://cdn.worldvectorlogo.com/logos/graphql.svg" width="100" height="100" /><img src="https://d2z5w7rcu7bmie.cloudfront.net/assets/images/logo.png" width="100" height="100" />

## How I Solved It

### View Models
I created a `RepoListViewModel` class to handle functionality of fetching repos, storing cell view models, and to keep the `RepoListViewController` clean. The view controller has access to 2 closures, `repoFetchCompleted` and `repoFetchError`. `repoFetchCompleted` is used to refresh the table view and `repoFetchError` is used to display an error message and allow the user to retry the failed query. 

`RepoCellViewModel` is used for the table view cells and is initialized with `RepositoryDetails`. Setting the `viewModel` property on my `RepoTableViewCell` will call `configure(with viewModel: RepoCellViewModel)` and display the relevant data in the cell.

### Interaction
- If a user scrolls within 100pts of the list bottom, more repos will be fetched.
- If a user selects a cell, a `SFSafariViewController` will present the repo on GitHub.

### Libraries
I used Kingfisher to download and cache the user's avatar images. 

### With More Time I Would've...
- Added UI and Unit tests to automatically verify functionality.
- Created a different layout for iPads.
- Allowed a user to interact with a repo by becoming a stargazer.
