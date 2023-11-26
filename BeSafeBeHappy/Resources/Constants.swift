import UIKit

enum Constants {
    
    enum Offsets {
        static let small = 8.0
        static let medium = 16.0
        static let big = 32.0
        static let large = 64.0
        static let hyper = 128.0
        static let textFieldGoingUpBottomOffset = 100.0
    }
    
    enum WobbleSettings {
        static let keyTimes = [0.015, 0.03, 0.015, 0, -0.015, -0.03, -0.015, 0]
        static let duration = 0.2
        static let animationsFrame =  "transform.rotation.z"
        static let key = "wobble"
    }
    
    enum Sizes {
        enum Defaults {
            static let radius = 14.0
        }
        
        enum AuthorizationController {
            static let signInButtonHeight = 50.0
            static let signInButtonWidth = 200.0
            static let labelsWidth = 200
        }

        enum MainController {
            static let addButtonHeight = 50.0
            static let addButtonWidth = 260.0
            static let deleteButtonSide = 24.0
        }
        
        enum NewPhotoController {
            static let photoWidth = 340
            static let photoHeight = 450
            static let descriptionTextFieldWidth = 280
            static let heartSide = 50
            static let saveButtonHeight = 50.0
            static let saveButtonWidth = 260.0
        }
    }
    
    enum Text {
        enum Defaults {
            static let radius = 14.0
            static let defaultSpeedAnimation = 0.3
            static let slideInSpeedAnimation = 0.15
        }
        
        enum AuthorizationController {
            static let loginTextLabel = "Login"
            static let passwordLabelText = "Password"
            static let loginText = "example@email.com"
            static let passwordText = "****"
            static let signInButtonTitle = "Войти"
            static let signInText = "Login"
            static let alertTitle = "Ошибка"
            static let messageTitle = "Неправильно введен логин и пароль"
            static let firstButtonTitle = "Окей, летсгоу"
        }

        enum GalleryController {
            static let galleryText = "Галерея"
            static let plusButtonTitle = "Добавить новое фото"
            static let plusButtonImage = "plus.circle"
            static let alertTitle = "Добавить папку"
            static let messageTitle = "Имя папки"
            static let firstButtonTitle = "Ok"
            static let photoImage = "photo"
            static let UIBarButtonItemImage = "folder.badge.plus"
        }
        
        enum NewPhotoController {
            static let navigationBarTitle = "Добавьте свои лучшие воспоминания"
            static let leafletTitle = "Листайте на здоровье"
            static let desriptionTextfieldText = "Какое-то описание фото"
            static let notFavourite = "heart"
            static let favourite = "heart.fill"
            static let plusImage = "plus"
            static let cameraImage = "camera"
            static let backTitle = "Назад"
            static let saveImage = "checkmark.rectangle.fill"
            static let messageTitle = "Добавить имя фото"
            static let firstButtonTitle = "Ok"
            
            enum showPhotoAlert {
                static let messageTitle = "ChoosePhoto"
                static let firstButtonTitle =  "Library"
                static let secondButtonTitle = "Camera"
            }
        }
    }
    
    enum FontSizes {
        static let small = 10.0
        static let medium = 20.0
        static let large = 30.0
        static let hyper = 40.0
    }
    
    enum UserDefaultsKeys {
        static let appEntries = "AppEntries"
        static let mainDataSource = "MainDataSource"
    }
    
    static let longPressDuration: TimeInterval = 1    
    static let defaultFolder = MainControllerDataSource()
    static let backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
}

