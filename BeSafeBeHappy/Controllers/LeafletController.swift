import UIKit
import SnapKit

protocol EditPhotoDelegate: AnyObject {
    func saveDate(photoList: [PhotoMetaData])
}

class LeafletController: UIViewController {
    
    weak var delegate: EditPhotoDelegate?
    
    private lazy var contentView = UIView()
    
    var photoList: [PhotoMetaData]
    var isFavourite: Bool
    var imageName: String
    var currentImageIndex: Int
    
    private var bottomConstraint: Constraint?
    
    private lazy var photoImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .gray
        imageView.backgroundColor = .black
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private lazy var descriptionTextField = {
        let textField = UITextField(text: Constants.Text.NewPhotoController.desriptionTextfieldText,
                                    font: UIFont.systemFont(ofSize: Constants.FontSizes.medium),
                                    textColor: .black)
        textField.delegate = self
        return textField
    }()
    
    private lazy var favouritesButton = {
        let button = AdaptiveButton()
        button.setImage(UIImage(systemName: isFavourite ? Constants.Text.NewPhotoController.favourite : Constants.Text.NewPhotoController.notFavourite ) ?? UIImage(), for: .normal)
        button.addTarget(self, action: #selector(toggleFavourites(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var saveButton = {
        let button = AdaptiveButton(title: Constants.Text.NewPhotoController.backTitle,
                                    image: UIImage(systemName: Constants.Text.NewPhotoController.saveImage),
                                    fontSize: Constants.FontSizes.large)
        button.addTarget(self, action: #selector(savePhoto), for: .touchUpInside)
        return button
    }()
    
    init(photoList: [PhotoMetaData],
         imageName: String,
         isFavourite: Bool,
         currentImageIndex: Int
    ) {
        self.photoList = photoList
        self.imageName = imageName
        self.isFavourite = isFavourite
        self.currentImageIndex = currentImageIndex
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.photoList = [PhotoMetaData]()
        self.imageName = ""
        self.isFavourite = false
        self.currentImageIndex = 0
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        photoImageView.dropShadow()
        photoImageView.roundCorners()
        descriptionTextField.createBottomLines()
        view.layoutIfNeeded()
    }
    
    @objc func savePhoto() {
        view.endEditing(true)
        delegate?.saveDate(photoList: photoList)
        self.navigationController?.popViewController(animated: true)
    }
    
    private func addSubviews() {
        view.addSubview(contentView)
        contentView.addSubview(favouritesButton)
        contentView.addSubview(photoImageView)
        contentView.addSubview(descriptionTextField)
        contentView.addSubview(saveButton)
    }
    
    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let animationDuration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue,
              let keyboardScreenEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            bottomConstraint?.update(offset: 0)
        } else {
            bottomConstraint?.update(offset: -keyboardScreenEndFrame.height + Constants.Offsets.textFieldGoingUpBottomOffset)
        }
        
        UIView.animate(withDuration: animationDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    private func setupUI() {
        view.backgroundColor = Constants.backgroundColor
        navigationItem.hidesBackButton = true
        navigationController?.navigationBar.prefersLargeTitles =  false
        title = Constants.Text.NewPhotoController.leafletTitle
        addSubviews()
        setupConstraints()
        setupGestureRecogniser(in: photoImageView)
        setupViewRecognisers()
        registerForKeyboardNotifications()
        setupImageData()
    }
    
    private func setupImageData() {
        photoImageView.image = DataManager.shared.loadImage(fileName: imageName)
        descriptionTextField.text = photoList[currentImageIndex].description
        isFavourite = photoList[currentImageIndex].isFavourite
        favouritesButton.buttonImage = UIImage(systemName: isFavourite ? Constants.Text.NewPhotoController.favourite : Constants.Text.NewPhotoController.notFavourite) ?? UIImage()
    }
    
    private func setupGestureRecogniser(in photoImageView: UIImageView) {
        let viewTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:)))
        photoImageView.addGestureRecognizer(viewTap)
        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(savePhoto))
        view.addGestureRecognizer(dismissTap)
    }
    
    private func setupViewRecognisers() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(showNewImage(_:)))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(showNewImage(_:)))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
    }
    
    @objc func toggleFavourites(_ sender: UIButton) {
        isFavourite.toggle()
        photoList[currentImageIndex].isFavourite = isFavourite
        favouritesButton.setImage(UIImage(systemName: isFavourite ? Constants.Text.NewPhotoController.favourite : Constants.Text.NewPhotoController.notFavourite ) ?? UIImage(), for: .normal)
    }
    
    @objc func showNewImage(_ sender: UISwipeGestureRecognizer) {
        var direction: Int = 0
        
        switch sender.direction {
        case .right:
            direction = -1
        case .left:
            direction = 1
        default:
            break
        }
        
        let nextIndex = (currentImageIndex + direction + photoList.count) % photoList.count
        currentImageIndex = nextIndex
        let imageData = photoList[nextIndex]
        
        if let image = DataManager.shared.loadImage(fileName: imageData.path) {
            if direction == -1 {
                slideOutAnimation(image: image, replacingImageView: photoImageView)
            } else {
                slideInAnimation(image: image, replacingImageView: photoImageView)
            }
        }
        
        descriptionTextField.text = imageData.imageName
        isFavourite = imageData.isFavourite
        favouritesButton.setImage(UIImage(systemName: isFavourite ? Constants.Text.NewPhotoController.favourite : Constants.Text.NewPhotoController.notFavourite ) ?? UIImage(), for: .normal)    }
}

extension LeafletController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension LeafletController {
    func setupConstraints() {
        contentView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalToSuperview()
            bottomConstraint = make.bottom.equalToSuperview().constraint
        }
        
        saveButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Constants.Offsets.hyper - Constants.Offsets.medium)
            make.left.equalToSuperview().offset(Constants.Offsets.medium)
            make.width.equalTo(Constants.Sizes.NewPhotoController.saveButtonWidth)
            make.height.equalTo(Constants.Sizes.NewPhotoController.saveButtonHeight)
        }
        
        favouritesButton.snp.makeConstraints { make in
            make.top.equalTo(saveButton.snp.top)
            make.right.equalToSuperview().offset(-Constants.Offsets.medium - Constants.Offsets.small)
            make.width.height.equalTo(Constants.Sizes.NewPhotoController.heartSide)
        }
        
        photoImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(favouritesButton.snp.bottom).offset(Constants.Offsets.medium )
            make.width.equalTo(Constants.Sizes.NewPhotoController.photoWidth)
            make.height.equalTo(Constants.Sizes.NewPhotoController.photoHeight)
        }
        
        descriptionTextField.snp.makeConstraints { make in
            make.left.equalTo(photoImageView.snp.left)
            make.top.equalTo(photoImageView.snp.bottom).offset(Constants.Offsets.medium)
            make.width.equalTo(Constants.Sizes.NewPhotoController.descriptionTextFieldWidth)
        }
    }
}

extension LeafletController {
    func slideOutAnimation(image: UIImage, replacingImageView oldImageView: UIImageView) {
        let newImageView = UIImageView(image: oldImageView.image)
        newImageView.frame = oldImageView.frame
        oldImageView.image = image
        view.addSubview(newImageView)
        
        UIView.animate(withDuration: Constants.Text.Defaults.defaultSpeedAnimation,
                       delay: .zero,
                       options: .curveLinear) { [weak self] in
            newImageView.frame.origin.x -= self?.view.frame.width ?? .zero
        } completion: { _ in
            newImageView.removeFromSuperview()
        }
    }
    
    func slideInAnimation(image: UIImage, replacingImageView oldImageView: UIImageView) {
        let newImageView = UIImageView(image: image)
        
        newImageView.frame = CGRect(x: view.frame.width,
                                    y: oldImageView.frame.origin.y,
                                    width: oldImageView.frame.size.width,
                                    height: oldImageView.frame.size.height)
        view.addSubview(newImageView)
        
        UIView.animate(withDuration: Constants.Text.Defaults.slideInSpeedAnimation,
                       delay: .zero,
                       options: .curveLinear) { [weak self] in
            newImageView.frame.origin.x = self?.view.frame.width ?? .zero - newImageView.frame.width
        }  completion: { _ in
            oldImageView.image = image
            newImageView.removeFromSuperview()
        }
    }
}
