import UIKit

extension UILabel {
    convenience init (text: String, font: UIFont?, textColor: UIColor) {
        self.init()
        self.text = text
        self.font = font
        self.textColor = textColor
        self.adjustsFontSizeToFitWidth = true
        self.roundCorners()
    }
}

extension UITextField {
    convenience init (text: String, font: UIFont?, textColor: UIColor) {
        self.init()
        self.text = text
        self.font = font
        self.textColor = textColor
        self.adjustsFontSizeToFitWidth = true
        
        self.roundCorners()
    }
    
    //MARK: - создание нижних линий
    func createBottomLines() {
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: self.frame.height - 1, width: self.frame.width, height: 1)
        bottomLine.backgroundColor = UIColor.gray.cgColor
        self.layer.addSublayer(bottomLine)
    }
    
    func setupColor() {
        self.textColor = .gray
    }
}

extension UIView {
    
    func roundCorners(radius: CGFloat = 10) {
        return self.layer.cornerRadius = radius
    }
    
    func dropShadow() {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 5, height: 5)
        layer.shadowRadius = 5
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
    }
}

extension UIViewController {
    
    func showAlert(alertTitle: String? = nil,
                   messageTitle: String,
                   alertStyle: UIAlertController.Style,
                   firstButtonTitle: String,
                   secondButtonTitle: String? = nil,
                   firstAlertActionStyle: UIAlertAction.Style,
                   secondAlertActionStyle: UIAlertAction.Style? = nil,
                   firstHandler: (() -> Void)? = nil,
                   secondHandler: (() -> Void)? = nil) {
        
        let alert = UIAlertController(title: alertTitle,
                                      message: messageTitle,
                                      preferredStyle: alertStyle)
        
        let firstAlertActionButton = UIAlertAction(title: firstButtonTitle,
                                                   style: firstAlertActionStyle) { _ in
            firstHandler?()
        }
        alert.addAction(firstAlertActionButton)
        
        if let secondButtonTitle = secondButtonTitle,
           let secondAlertActionStyle = secondAlertActionStyle {
            let secondAlertActionButton = UIAlertAction(title: secondButtonTitle,
                                                        style: secondAlertActionStyle) { _ in
                secondHandler?()
            }
            alert.addAction(secondAlertActionButton)
        }
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelActionButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    func showAlertWithTextField(alertTitle: String? = nil,
                                messageTitle: String,
                                alertStyle: UIAlertController.Style,
                                firstButtonTitle: String,
                                firstAlertActionStyle: UIAlertAction.Style,
                                usersTextField: UITextField,
                                firstHandler: ((String) -> Void)? = nil) {
        let alert = UIAlertController(title: alertTitle,
                                      message: messageTitle,
                                      preferredStyle: alertStyle)
        alert.addTextField { textField in
            textField.placeholder = "Папка"
        }
        
        let firstAlertActionButton = UIAlertAction(title: firstButtonTitle,
                                                   style: firstAlertActionStyle) { _ in
            if let text = alert.textFields?.first?.text {
                firstHandler?(text)
            }
        }
        alert.addAction(firstAlertActionButton)
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelActionButton)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func pauseLayer(layer: CALayer) {
        let pausedTime: CFTimeInterval = layer.convertTime(CACurrentMediaTime(), from: nil)
        layer.speed = .zero
        layer.timeOffset = pausedTime
    }
}

extension ContentCollectionViewCell {
    func wobble(duration: CFTimeInterval = .infinity) {
        let animation = CAKeyframeAnimation(keyPath: Constants.WobbleSettings.animationsFrame)
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = Constants.WobbleSettings.duration
        animation.values = Constants.WobbleSettings.keyTimes
        animation.repeatDuration = duration
        layer.add(animation, forKey: Constants.WobbleSettings.key)
    }
}

extension UserDefaults {
    
    func set<T: Encodable>(encodable: T, forKey key: String) {
        if let data = try? JSONEncoder().encode(encodable) {
            set(data, forKey: key)
            print("object loaded")
        }
    }
    
    func object<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        if let data = object(forKey: key) as? Data,
           let value = try? JSONDecoder().decode(type, from: data) {
            print("object read")
            return value

        }
        return nil
    }
    
    func loadAllUserContent() -> MainControllerDataSource {
        if let content = self.object(MainControllerDataSource.self, forKey: Constants.UserDefaultsKeys.mainDataSource) {
            return content
        }
        
        return Constants.defaultFolder
    }
    
    func saveAllUserContent(content: Folder) {

    }
}
