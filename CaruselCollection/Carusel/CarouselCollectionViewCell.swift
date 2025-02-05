import UIKit

class CarouselCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "CarouselCollectionViewCell"
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private var blurView: UIVisualEffectView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setupView() {
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 20.0
        contentView.layer.masksToBounds = true
        contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
        addWhiteShadowAround()
    }
    
    func configure(with imageName: String, isCentral: Bool) {
        imageView.image = UIImage(named: imageName)
        if blurView == nil {
            let blurEffect = UIBlurEffect(style: .light)
            let newBlurView = UIVisualEffectView(effect: blurEffect)
            newBlurView.frame = contentView.bounds
            newBlurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            contentView.addSubview(newBlurView)
            blurView = newBlurView
        }
        UIView.animate(withDuration: 0.2) {
            self.blurView?.alpha = isCentral ? 0 : 0.8
        }
    }
    
    private func addWhiteShadowAround() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 10.0
        layer.masksToBounds = false
    }
}
