import UIKit
import SnapKit

protocol AddNewPhotoDelegate: AnyObject {
    func addNewPhoto(photoModel: PhotoMetaData)
}

class NewPhotoViewController: UIViewController {
    
    weak var delegate: AddNewPhotoDelegate?
    
    private lazy var contentView = UIView()
    
    private var bottomConstraint: Constraint?
    
    var realImageName: String?
    
    var isFavourite: Bool = false
    
    private lazy var photoImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: Constants.Text.NewPhotoController.plusImage)
        
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .gray
        imageView.backgroundColor = .secondarySystemBackground
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
        let button = AdaptiveButton(image: UIImage(systemName: Constants.Text.NewPhotoController.notFavourite))
        button.addTarget(self, action: #selector(toggleFavourites(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var cameraButton = {
        let button = AdaptiveButton(image: UIImage(systemName: Constants.Text.NewPhotoController.cameraImage))
        button.addTarget(self, action: #selector(addNewPhoto(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var saveButton = {
        let button = AdaptiveButton(title: Constants.Text.NewPhotoController.backTitle,
                                    image: UIImage(systemName: Constants.Text.NewPhotoController.saveImage),
                                    fontSize: Constants.FontSizes.large)
        button.addTarget(self, action: #selector(savePhoto(_:)), for: .touchUpInside)
        return button
    }()
    
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
    
    @objc func savePhoto(_ sender: UIButton) {
        view.endEditing(true)
        let photoNameTextField = UITextField()
        
        showAlertWithTextField(messageTitle: Constants.Text.NewPhotoController.messageTitle,
                               alertStyle: .alert,
                               firstButtonTitle: Constants.Text.NewPhotoController.firstButtonTitle,
                               firstAlertActionStyle: .default,
                               usersTextField: photoNameTextField) { [weak self] text in
            guard let self else { return }
            
            if let photoDescription = self.descriptionTextField.text,
               let path = DataManager.shared.saveImage(image: self.photoImageView.image) {
                
                let photoModel = PhotoMetaData(path: path,
                                               imageName: text,
                                               description: photoDescription,
                                               isFavourite: isFavourite)
                self.delegate?.addNewPhoto(photoModel: photoModel)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @objc func addNewPhoto(_ sender: UITapGestureRecognizer) {
        showPhotoAlert()
    }
    
    private func addSubviews() {
        view.addSubview(contentView)
        contentView.addSubview(favouritesButton)
        contentView.addSubview(photoImageView)
        contentView.addSubview(descriptionTextField)
        contentView.addSubview(cameraButton)
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
        view.backgroundColor = .white
        navigationItem.hidesBackButton = true
        navigationController?.navigationBar.prefersLargeTitles =  false
        title = Constants.Text.NewPhotoController.navigationBarTitle
        addSubviews()
        setupConstraints()
        setupGestureRecogniser(in: photoImageView)
        registerForKeyboardNotifications()
    }
    
    private func setupGestureRecogniser(in photoImageView: UIImageView) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(addNewPhoto(_:)))
        photoImageView.addGestureRecognizer(tap)
        let viewTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:)))
        view.addGestureRecognizer(viewTap)
    }
    
    private func showPhotoAlert() {
        showAlert(messageTitle: Constants.Text.NewPhotoController.showPhotoAlert.messageTitle,
                  alertStyle: .actionSheet,
                  firstButtonTitle: Constants.Text.NewPhotoController.showPhotoAlert.firstButtonTitle,
                  secondButtonTitle: Constants.Text.NewPhotoController.showPhotoAlert.secondButtonTitle,
                  firstAlertActionStyle: .default,
                  secondAlertActionStyle: .default, 
                  firstHandler:  {
            
            self.showPicker(source: .photoLibrary)
        }) {
            self.showPicker(source: .camera)
        }
    }
    
    @objc func toggleFavourites(_ sender: UIButton) {
        isFavourite.toggle()
        favouritesButton.setImage(UIImage(systemName: isFavourite ? Constants.Text.NewPhotoController.favourite : Constants.Text.NewPhotoController.notFavourite ) ?? UIImage(), for: .normal)
    }
}

extension NewPhotoViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension NewPhotoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var chosenImage = UIImage()
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            chosenImage = image
        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            chosenImage = image
        }
        
        photoImageView.image = chosenImage
        picker.dismiss(animated: true)
    }
    
    private func showPicker(source: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = source
        present(imagePicker, animated: true)
    }
    
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
        
        cameraButton.snp.makeConstraints { make in
            make.top.equalTo(descriptionTextField.snp.top)
            make.right.equalTo(photoImageView.snp.right)
            make.height.width.equalTo(Constants.Sizes.NewPhotoController.heartSide)
        }
    }
}

