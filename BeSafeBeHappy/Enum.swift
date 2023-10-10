import Foundation

enum Constants {
    
    enum Offsets {
        static let small = 8.0
        static let medium = 16.0
        static let big = 32.0
        static let large = 64.0
        static let hyper = 128.0
        static let textFieldGoingUpBottomOffset = 200.0
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
        }
        
        enum NewPhotoController {
            static let photoWidth = 340
            static let photoHeight = 400
            static let descriptionTextFieldWidth = 280
            static let heartSide = 50
            static let saveButtonHeight = 50.0
            static let saveButtonWidth = 260.0
        }
    }
    
    enum Text {
        static let galeryTitle = "Галерея"
        
        enum Defaults {
            static let radius = 14.0
        }
        
        enum AuthorizationController {

        }

        enum MainController {

        }
        
        enum NewPhotoController {
            static let desriptionTextfieldText = "There would be some photo description"
            static let notFavourite = "heart"
            static let favourite = "heart.fill"
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
        static let contentList = "ContentList"
    }
    static let defaultFolder = Folder(insideFolders: nil, photosList: nil, title: Constants.Text.galeryTitle)
    //static let defaultFolder = Folder(insideFolders: someFolder, photosList: photosListFolder, title: Constants.Text.galeryTitle)
}

