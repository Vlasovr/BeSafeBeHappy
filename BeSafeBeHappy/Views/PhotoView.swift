import UIKit

class PhotoView: UIImageView {
    override func layoutSubviews() {
        super.layoutSubviews()
        self.dropShadow()
        self.roundCorners()
        self.clipsToBounds = true
    }
    
}
