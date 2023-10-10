import Foundation

class Folder: Codable {
    var title: String
    var insideFolders: [Folder]?
    var photosList: [PhotoMetaData]?
    let isFolder: Bool
    
    init(insideFolders: [Folder]?, photosList: [PhotoMetaData]?, title: String) {
        self.title = title
        self.photosList = photosList
        self.insideFolders = insideFolders
        self.isFolder = true
    }
}
