import UIKit

@IBDesignable
class GradientView: UIView {
    private let gradientLayer = CAGradientLayer()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if gradientLayer.superlayer == nil {
            layer.insertSublayer(gradientLayer, at: 0)
        }
        
        gradientLayer.frame = bounds
        gradientLayer.colors = [
            UIColor(red: 80/255, green: 79/255, blue: 246/255, alpha: 1).cgColor,
            UIColor(red: 211/255, green: 96/255, blue: 176/255, alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
    }
} 