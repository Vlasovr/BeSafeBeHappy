import UIKit

final class AdaptiveButton: UIButton {
    var buttonImage = UIImage()

    init(title: String = "", image: UIImage? = nil, fontSize: Double? = nil) {
        super.init(frame: .zero)
        configureButton(image: image ?? UIImage(), fontSize: fontSize ?? Constants.FontSizes.medium)
        self.setTitle(title, for: .normal)
        self.titleLabel?.adjustsFontSizeToFitWidth = true
        roundCorners()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }

    private func configureButton(image: UIImage, fontSize: Double) {
        var configuration = UIButton.Configuration.filled()
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: fontSize)
            return outgoing
        }
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 14, bottom: 10, trailing: 14)
        configuration.image = image
        configuration.imagePadding = 8
        configuration.imagePlacement = .trailing
        self.configuration = configuration
        
        self.addTarget(self, action: #selector(touchDown), for: .touchDown)
        self.addTarget(self, action: #selector(touchUpInside), for: .touchUpInside)

    }
    
    @objc func touchDown() {
        UIView.animate(withDuration: 0.4, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState]) {
            self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }
    }
    
    @objc func touchUpInside() {
        UIView.animate(withDuration: 0.4, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState]) {
            self.transform = .identity
        }
    }
    
    override func tintColorDidChange() {
        super.tintColorDidChange()
        
        switch tintAdjustmentMode {
        case .dimmed:
            self.backgroundColor = .cyan
            self.tintColor = .cyan
        default:
            self.backgroundColor = .systemBlue
            self.tintColor = .systemBlue
        }
    }

}
