import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Configurar el gradiente para el splash screen
    if let window = self.window {
      let gradientLayer = CAGradientLayer()
      gradientLayer.frame = window.bounds
      gradientLayer.colors = [
        UIColor(red: 80/255, green: 79/255, blue: 246/255, alpha: 1).cgColor,
        UIColor(red: 211/255, green: 96/255, blue: 176/255, alpha: 1).cgColor
      ]
      gradientLayer.startPoint = CGPoint(x: 0, y: 0)
      gradientLayer.endPoint = CGPoint(x: 1, y: 1)
      window.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
