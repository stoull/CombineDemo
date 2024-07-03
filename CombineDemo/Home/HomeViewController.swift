//
//  HomeViewController.swift
//  CombineDemo
//
//  Created by hut on 2024/7/2.
//

import UIKit
import Combine



class HomeViewController: UIViewController {

    enum Section: Hashable {
        case main
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    private let refreshControl = UIRefreshControl()
    
    private var bindings = Set<AnyCancellable>()
    
    private let viewModel: HomeViewModel
    
    typealias DataSource = UITableViewDiffableDataSource<Section, Flower>
    typealias SnapShot = NSDiffableDataSourceSnapshot<Section, Flower>
    
    
    private lazy var dataSource = makeDatasource()
    private lazy var snapshot = SnapShot()
    private var cellIdientier = "HomeCell"
    
    var flowers: [Flower] = []
    
    private lazy var searchBarTextSubject = PassthroughSubject<String, Never>()
    
    init(viewModel: HomeViewModel = HomeViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = HomeViewModel()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Home"
        
        setupTableView()
        setupBindings()
        
        applySnapshot()
        
        viewModel.search(keywords: "")
    }
    
    func applySnapshot(animatingDifferences: Bool = true) {
        snapshot.appendSections([.main])
        snapshot.appendItems(flowers)

        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
    
    func setupBindings() {
        func bindViewToViewModel() {
            // UISearchBar doesn't support combine
            searchBarTextSubject
                .debounce(for: 0.5, scheduler: RunLoop.main)
                .sink { [weak self] keywords in
                    self?.viewModel.search(keywords: keywords)
                }
                .store(in: &bindings)
        }
        
        func bindViewModelToView() {
            viewModel.$flowers
                .receive(on: DispatchQueue.main)
                .sink { [weak self] newValue in
                    if let sSelf = self {
                        var newS = SnapShot()
                        newS.appendSections([.main])
                        newS.appendItems(newValue)
                        sSelf.snapshot = newS
                        sSelf.dataSource.apply(newS, animatingDifferences: true)
                    }
                }
                .store(in: &bindings)
            
            viewModel.$status
                .receive(on: DispatchQueue.main)
                .delay(for: .seconds(2), scheduler: RunLoop.main, options: .none)
                .sink { [weak self] status in
                    switch status {
                    case .loading:
                        self?.refreshControl.beginRefreshing()
                    case .finishedLoading:
                        self?.refreshControl.endRefreshing()
                    case .error(let error):
                        self?.refreshControl.endRefreshing()
                        self?.showAlert(msg: error.des)
                    }
                }
                .store(in: &bindings)
        }
        
        bindViewToViewModel()
        bindViewModelToView()
    }
    
    private func showAlert(msg: String) {
        let alertVC = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { action in
            alertVC.dismiss(animated: true)
        }))
        self.present(alertVC, animated: true)
    }
    

    private func setupTableView() {
        searchBar.searchTextField.addTarget(self, action: #selector(searchBarTextDidChange(_:)), for: .editingChanged)
        
        tableView.rowHeight = 60.0
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshValueChanged(_:)), for: .valueChanged)
    }
    
    @objc
    func searchBarTextDidChange(_ sender: UISearchTextField) {
        searchBarTextSubject.send(sender.text ?? "")
    }
    
    @objc
    func refreshValueChanged(_ sender: UIRefreshControl) {
        viewModel.search(keywords: "")
    }
    
    private func makeDatasource() -> DataSource {
        let dataSource = DataSource(tableView: tableView) { [self] tableView, indexPath, itemIdentifier in
            if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdientier, for: indexPath) as? HomeCell {
                cell.flower = itemIdentifier
                return cell
            } else {
                return UITableViewCell()
            }
        }
        return dataSource
    }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}
