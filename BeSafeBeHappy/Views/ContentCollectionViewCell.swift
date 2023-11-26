import UIKit
protocol ContentCollectionViewCellDelegate: AnyObject {
    func contentCellDidTapDelete(_ cell: ContentCollectionViewCell)
}

class ContentCollectionViewCell: UICollectionViewCell {

    static var identifier: String { "\(Self.self)" }
    
    weak var delegate: ContentCollectionViewCellDelegate?
    
        private var imageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleToFill
        iv.clipsToBounds = true
        return iv
    }()
    
    private var titleLabel = UILabel()
    let deleteButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Constants.Offsets.medium)
            make.left.equalToSuperview().offset(Constants.Offsets.medium)
            make.right.equalToSuperview().offset(-Constants.Offsets.medium)
            make.bottom.equalToSuperview().offset(-Constants.Offsets.medium)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(Constants.Offsets.small)
            make.centerX.equalTo(imageView.snp.centerX)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    override func layoutSubviews() {
        imageView.roundCorners()
    }
    
    @objc func deleteButtonTapped() {
        delegate?.contentCellDidTapDelete(self)
    }
    
    func configure(model: CellModel) {
        if model.isAlbum  {
            imageView.image = UIImage(systemName: "folder.fill")
            imageView.contentMode = .scaleAspectFit
            titleLabel.text = model.title
        } else {
            imageView.image = DataManager.shared.loadImage(fileName: model.imageName)
            titleLabel.text = model.title
        }
    }
    
    func startEditingMode() {
        deleteButton.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
        contentView.addSubview(deleteButton)
        deleteButton.frame = CGRect(x: imageView.frame.maxX - Constants.Sizes.MainController.deleteButtonSide,
                                    y: imageView.frame.minY,
                                    width: Constants.Sizes.MainController.deleteButtonSide,
                                    height: Constants.Sizes.MainController.deleteButtonSide)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    }
    
    func endEditingMode() {
        deleteButton.removeFromSuperview()
    }
}
