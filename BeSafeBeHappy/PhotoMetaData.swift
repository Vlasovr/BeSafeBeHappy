import Foundation

class PhotoMetaData: Codable {
    var path: String
    var imageName: String
    var description: String
    var isFavourite: Bool
    
    init(path: String = "", imageName: String, description: String, isFavourite: Bool) {
        self.path = path
        self.imageName = imageName
        self.description = description
        self.isFavourite = isFavourite
    }
}

