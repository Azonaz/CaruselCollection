import UIKit

class CarouselFlowLayout: UICollectionViewFlowLayout {
    
    // Computable property to find the current centre index
    var currentCenteredIndexPath: IndexPath? {
        guard let collectionView = self.collectionView else { return nil }
        // Find the centre point of the screen taking into account the offset of the collection
        let currentCenteredPoint = CGPoint(x: collectionView.contentOffset.x + collectionView.bounds.width / 2,
                                           y: collectionView.contentOffset.y + collectionView.bounds.height / 2)
        // Get the index of the element that is in the centre of the screen
        return collectionView.indexPathForItem(at: currentCenteredPoint)
    }
    
    // Parameters defining scale and displacement of elements in the carousel
    private var sideItemScale: CGFloat = 0.8
    private var sideItemShift: CGFloat = 0.0
    private var sideItemHorizontalShift: CGFloat = 100.0
    
    // State of the current layout, stores the size of the collection
    private var state = LayoutCharacterListState(size: CGSize.zero)
    
    // Structure for storing the layout state
    private struct LayoutCharacterListState {
        var size: CGSize
        
        func hasEqualSizeAs(_ otherState: LayoutCharacterListState) -> Bool {
            return self.size.equalTo(otherState.size)
        }
    }
    
    override func prepare() {
        super.prepare()
        guard let collectionView = self.collectionView else { return }
        let currentState = LayoutCharacterListState(size: collectionView.bounds.size)
        // If the size of the collection has changed, update the layout
        if !self.state.hasEqualSizeAs(currentState) {
            updateFlowLayout()
            self.state = currentState
        }
    }

    // Is called when the collection boundaries are changed
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

    // Obtaining attributes of all elements within a given rectangle
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let superAttributes = super.layoutAttributesForElements(in: rect),
              let attributes = NSArray(array: superAttributes, copyItems: true) as? [UICollectionViewLayoutAttributes]
        else { return nil }
        return attributes.map({ adjustLayoutAttributes($0) })
    }

    // Calculate the offset of the collection contents to scroll to the nearest element
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView, !collectionView.isPagingEnabled,
              let layoutAttributes = self.layoutAttributesForElements(in: collectionView.bounds)
        else { return super.targetContentOffset(forProposedContentOffset: proposedContentOffset) }
        // Find the centre of the screen
        let midSide = collectionView.bounds.width / 2
        let proposedCenterOffset = proposedContentOffset.x + midSide
        // Search for the closest element to the centre of the screen
        let closest = layoutAttributes.min(by: { abs($0.center.x - proposedCenterOffset) < abs($1.center.x - proposedCenterOffset) }) ?? UICollectionViewLayoutAttributes()
        // Return a new targetContentOffset that scrolls the collection to the nearest element
        let targetContentOffset = CGPoint(x: floor(closest.center.x - midSide), y: proposedContentOffset.y)
        return targetContentOffset
    }
}

private extension CarouselFlowLayout {
    // Update layout settings when the collection size changes
    func updateFlowLayout() {
        guard let collectionView = self.collectionView else { return }
        // Calculating clearances for element centring
        let collectionSize = collectionView.bounds.size
        let yInset = (collectionSize.height - self.itemSize.height) / 2
        let xInset = (collectionSize.width - self.itemSize.width) / 2
        self.sectionInset = UIEdgeInsets(top: yInset, left: xInset, bottom: yInset, right: xInset)
        // Updating the minimum distance between elements
        let scaledItemOffset = (self.itemSize.width - self.itemSize.width * sideItemScale) / 2
        let visibleOffset: CGFloat = 70
        let inset = xInset
        self.minimumLineSpacing = inset - (visibleOffset + scaledItemOffset)
    }
    
    // Adjusting attributes for elements
    func adjustLayoutAttributes(_ attributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        guard let collectionView = self.collectionView else { return attributes }
        let collectionCenter = collectionView.frame.width / 2
        let offset = collectionView.contentOffset.x
        let normalizedCenter = attributes.center.x - offset
        
        let maxDistance = self.itemSize.width + self.minimumLineSpacing
        let distance = min(abs(collectionCenter - normalizedCenter), maxDistance)
        let ratio = (maxDistance - distance) / maxDistance
        let scale = ratio * (1 - sideItemScale) + sideItemScale
        attributes.alpha = 1.0
        
        // Scaling an element
        attributes.transform3D = CATransform3DScale(CATransform3DIdentity, scale, scale, 1)
        attributes.zIndex = Int(scale * 10)
        
        // Vertical displacement of elements
        attributes.center.y += (1 - ratio) * sideItemShift
        // Horizontal displacement of elements
        attributes.center.x += (ratio - 1) * sideItemHorizontalShift * (normalizedCenter > collectionCenter ? 1 : -1)
        
        return attributes
    }
}
