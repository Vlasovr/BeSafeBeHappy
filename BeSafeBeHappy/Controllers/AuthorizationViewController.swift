import UIKit
import SwiftyKeychainKit

final class AuthorizationViewController: UIViewController, UITextFieldDelegate {
    
    private lazy var loginLabel = {
        let label = UILabel(text: Constants.Text.AuthorizationController.loginTextLabel,
                            font: UIFont.systemFont(ofSize: Constants.FontSizes.large),
                            textColor: .black)
        return label
    }()
    
    private let passwordLabel = {
        let label = UILabel(text: Constants.Text.AuthorizationController.passwordLabelText,
                            font: UIFont.systemFont(ofSize: Constants.FontSizes.large),
                            textColor: .black)
        return label
    }()
    
    private lazy var loginTextField = {
        let textField = UITextField(text: Constants.Text.AuthorizationController.loginText,
                                    font: UIFont.systemFont(ofSize: Constants.FontSizes.large),
                                    textColor: .black)
        textField.delegate = self
        return textField
    }()
    
    private lazy var passwordTextField = {
        let textField = UITextField(text: Constants.Text.AuthorizationController.passwordText,
                                    font: UIFont.systemFont(ofSize: Constants.FontSizes.large),
                                    textColor: .black)
        textField.delegate = self
        return textField
    }()
    
    private let signInButton = {
        let button = AdaptiveButton(title: Constants.Text.AuthorizationController.signInButtonTitle, fontSize: Constants.FontSizes.large)
        button.addTarget(self, action: #selector(authorizate(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var signInLabel = {
        let label = UILabel(text: Constants.Text.AuthorizationController.signInText,
                            font: UIFont.systemFont(ofSize: Constants.FontSizes.large),
                            textColor: .black)
        return label
    }()
    
    private var userAuthorization = [Constants.Text.AuthorizationController.loginText: Constants.Text.AuthorizationController.passwordText]

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        finalSetupViews()
    }
    
    //MARK: - авторизация
    @objc private func authorizate(_ sender: UIButton) {
        var isCorrectData: Bool {
            let result = userAuthorization.keys.first?.lowercased() == loginTextField.text?.lowercased() &&
            userAuthorization.values.first?.lowercased() == passwordTextField.text?.lowercased()
            return result
        }
        
        guard isCorrectData else {
            loginTextField.text = nil
            passwordTextField.text = nil
            showAlert(alertTitle: Constants.Text.AuthorizationController.alertTitle,
                      messageTitle: Constants.Text.AuthorizationController.messageTitle,
                      alertStyle: .alert,
                      firstButtonTitle: Constants.Text.AuthorizationController.firstButtonTitle,
                      firstAlertActionStyle: .cancel)
            return
        }
        
        let mainController = GalleryController()
        let dataSource = loadUserData()
        mainController.dataSourceFolder = dataSource
        navigationController?.pushViewController(mainController, animated: false)
    }
    
    private func checkIsFirstEntry() -> Bool {
        guard UserDefaults.standard.object(forKey: Constants.UserDefaultsKeys.appEntries) is Bool else {
            UserDefaults.standard.set(false, forKey: Constants.UserDefaultsKeys.appEntries)
            return true
        }
        return false
    }
    
    private func loadUserData() -> Folder {
        if !checkIsFirstEntry() {
            if let data = UserDefaults.standard.object(Folder.self, forKey: Constants.UserDefaultsKeys.contentList) {
                return data
            }
        } else {
            UserDefaults.standard.set(encodable: Constants.defaultFolder, forKey: Constants.UserDefaultsKeys.contentList)
        }
        
        return Constants.defaultFolder
    }
    
    
    private func setupUI() {
        navigationController?.isNavigationBarHidden = true
        addSubviews()
        setupConstraints()
    }
    
    private func addSubviews() {
        view.addSubview(loginLabel)
        view.addSubview(loginTextField)
        view.addSubview(passwordLabel)
        view.addSubview(passwordTextField)
        view.addSubview(signInLabel)
        view.addSubview(signInButton)
    }
    
    private func finalSetupViews() {
        loginTextField.createBottomLines()
        passwordTextField.createBottomLines()
    }
    
    //MARK: - если в текстфилде текст с примером - при нажатии - стираем поле
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField.text == Constants.Text.AuthorizationController.loginText || textField.text == Constants.Text.AuthorizationController.passwordText {
            textField.text = nil
        }
    }
}

extension AuthorizationViewController {
    func setupConstraints() {
        loginLabel.snp.makeConstraints { make in
            make.left.equalTo(Constants.Offsets.medium)
            make.top.equalTo(Constants.Offsets.hyper + Constants.Offsets.hyper)
            make.width.equalTo(Constants.Sizes.AuthorizationController.labelsWidth)
        }
        
        loginTextField.snp.makeConstraints { make in
            make.left.equalTo(Constants.Offsets.big)
            make.top.equalTo(loginLabel.snp.bottom).offset(Constants.Offsets.medium)
            make.width.equalTo(Constants.Sizes.AuthorizationController.labelsWidth)
        }
        
        passwordLabel.snp.makeConstraints { make in
            make.left.equalTo(Constants.Offsets.medium)
            make.top.equalTo(loginTextField.snp.bottom).offset(Constants.Offsets.medium)
            make.width.equalTo(Constants.Sizes.AuthorizationController.labelsWidth)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.left.equalTo(Constants.Offsets.big)
            make.top.equalTo(passwordLabel.snp.bottom).offset(Constants.Offsets.medium)
            make.width.equalTo(Constants.Sizes.AuthorizationController.labelsWidth)
        }
        
        signInLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(passwordTextField.snp.bottom).offset(Constants.Offsets.hyper)
            make.width.equalTo(Constants.Sizes.AuthorizationController.labelsWidth)
        }
        
        signInButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(signInLabel.snp.bottom)
            make.width.equalTo(Constants.Sizes.AuthorizationController.signInButtonWidth)
            make.height.equalTo(Constants.Sizes.AuthorizationController.signInButtonHeight)
        }
    }
}
