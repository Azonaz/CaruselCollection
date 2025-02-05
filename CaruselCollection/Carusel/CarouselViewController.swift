import UIKit

class CarouselViewController: UIViewController {
        
    // Array of image names that will be displayed in the carousel
    private let imageNames = ["Image1", "Image2", "Image3", "Image4", "Image5"]
    
    // UICollectionView setup with a custom flow layout
    private lazy var collectionView: UICollectionView = {
        let layout = CarouselFlowLayout() // Custom layout for carousel effect
        layout.scrollDirection = .horizontal
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.showsHorizontalScrollIndicator = false
        view.translatesAutoresizingMaskIntoConstraints = false
        view.register(CarouselCollectionViewCell.self, forCellWithReuseIdentifier: CarouselCollectionViewCell.reuseIdentifier)
        return view
    }()
    
    // Convenience property to access the custom layout
    private var centerFlowLayout: CarouselFlowLayout? {
        return collectionView.collectionViewLayout as? CarouselFlowLayout
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupCollection()
        collectionView.dataSource = self
        collectionView.delegate = self
        // Setting initial size of carousel items based on screen width and height
        centerFlowLayout?.itemSize = CGSize(
            width: view.bounds.width * 0.8,
            height: view.bounds.height * 0.9
        )
    }
    
    private func setupCollection() {
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 90),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -90)
        ])
    }
}

extension CarouselViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageNames.count
    }
    
    // Configuring each cell with the corresponding image
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CarouselCollectionViewCell.reuseIdentifier, for: indexPath) as! CarouselCollectionViewCell
        let imageName = imageNames[indexPath.item]
        let isCentral = (centerFlowLayout?.currentCenteredIndexPath?.row == indexPath.row)
        cell.configure(with: imageName, isCentral: isCentral)
        return cell
    }
}

extension CarouselViewController: UICollectionViewDelegateFlowLayout {
    // Defines the size for each item in the collection view
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        return CGSize(width: screenWidth * 0.85, height: screenHeight * 0.6)
    }
    
    // Adjusts the inset for the section to center the items properly
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let itemCount = imageNames.count
        let horizontalInset: CGFloat = itemCount == 1
        ? (UIScreen.main.bounds.width - UIScreen.main.bounds.width * 0.85) / 2
        : 20
        return UIEdgeInsets(top: 0, left: horizontalInset, bottom: 0, right: horizontalInset)
    }
}

extension CarouselViewController: UIScrollViewDelegate {
    // Detects when the user scrolls and updates the central item accordingly
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let centerIndexPath = centerFlowLayout?.currentCenteredIndexPath else { return }
        // Iterate through visible cells and update their appearance based on whether they are central
        for cell in collectionView.visibleCells {
            guard let indexPath = collectionView.indexPath(for: cell),
                  let characterCell = cell as? CarouselCollectionViewCell else { continue }
            let isCentral = indexPath == centerIndexPath
            characterCell.configure(with: imageNames[indexPath.row], isCentral: isCentral)
        }
    }
}
