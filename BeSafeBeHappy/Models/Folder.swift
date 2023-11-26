import Foundation

class Folder: Codable {
    var title: String
    var photosList: [PhotoMetaData]?
    let isFolder: Bool
    
    init(photosList: [PhotoMetaData]?, title: String) {
        self.title = title
        self.photosList = photosList
        self.isFolder = true
    }
}
