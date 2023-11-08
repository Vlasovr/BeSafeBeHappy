import UIKit

final class DataManager {
    
    static let shared = DataManager()
    
    private init() { }
    
    func saveImage(image: UIImage?) -> String? {
        guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
              let image else { return nil }
        
        let fileName = UUID().uuidString
        let fileURL = directory.appendingPathComponent(fileName)
        let data = image.jpegData(compressionQuality: 1.0)
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(atPath: fileURL.path)
                print(directory.path)
            } catch let error {
                print(error)
                return nil
            }
        }
        
        print(directory.path)
        do {
            try data?.write(to: fileURL)
            return fileName
        } catch {
            return nil
        }
    }
    
    func loadImage(fileName: String) -> UIImage? {
        guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }

        let fileURL = directory.appendingPathComponent(fileName)
        let image = UIImage(contentsOfFile: fileURL.path)
        return image
    }
    
}
