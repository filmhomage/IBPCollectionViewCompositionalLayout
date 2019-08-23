import UIKit
import DiffableDataSources
import IBPCollectionViewCompositionalLayout

typealias NSDiffableDataSourceSnapshot = DiffableDataSourceSnapshot
typealias UICollectionViewDiffableDataSource = CollectionViewDiffableDataSource

extension UIColor {
    static var systemBackground: UIColor {
        return .white
    }
    static var placeholderText: UIColor {
        return .lightGray
    }
    static var systemGray2: UIColor {
        return .gray
    }
}

extension UIImage {
    convenience init?(systemName: String) {
        self.init(named: systemName)
    }
}

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    let viewControllers: [UIViewController.Type] = [
        SupplementaryAndDecorationViewController.self,
    ]

    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ListCell.self, forCellWithReuseIdentifier: ListCell.reuseIdentifier)
        return collectionView
    }()
    lazy var collectionViewLayout: UICollectionViewLayout = {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(44))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)

        let layout = UICollectionViewCompositionalLayout(section: section)

        return layout
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.indexPathsForSelectedItems?.forEach{ collectionView.deselectItem(at: $0, animated: true) }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewControllers.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ListCell.reuseIdentifier, for: indexPath) as? ListCell else { fatalError("Could not create new cell") }

        let viewController = viewControllers[indexPath.row]
        cell.label.text = String(describing: viewController)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let viewControllerClass = viewControllers[indexPath.row]
        let viewController = viewControllerClass.init()

        if let viewController = viewController as? MosaicReduxViewController {
            if indexPath.row % 2 == 0 {
                viewController.layoutFractionalConfig = .small
            } else {
                viewController.layoutFractionalConfig = .big
            }
        }

        if let viewController = viewController as? TileGalleryViewController {
            if indexPath.row % 2 == 0 {
                viewController.layoutBehavior = .verticallyContinuous
            } else {
                viewController.layoutBehavior = .orthogonalMagnet
            }
        }
        
        let navigationController = UINavigationController(rootViewController: viewController)

        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(dismissViewController))
        viewController.navigationItem.leftBarButtonItem = barButtonItem

        present(navigationController, animated: true)
    }

    @objc
    func dismissViewController() {
        dismiss(animated: true)
    }
}
