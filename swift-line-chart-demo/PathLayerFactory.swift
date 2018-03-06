import UIKit

class PathLayerFactory {
  static func make() -> CAShapeLayer {
    let pathLayer = CAShapeLayer()
    pathLayer.strokeColor = UIColor.white.cgColor
    pathLayer.fillColor = UIColor.clear.cgColor
    pathLayer.lineWidth = 1.5
    pathLayer.lineJoin = kCALineJoinRound
    pathLayer.lineCap = kCALineCapRound

    return pathLayer
  }

  static func make(path: CGPath, animation: Bool) -> CAShapeLayer {
    let pathLayer = make()
    pathLayer.path = path

    if animation {
      let animation = CABasicAnimation(keyPath: "strokeEnd")
      animation.duration = 0.5
      animation.fromValue = 0
      animation.toValue = 1
      pathLayer.add(animation, forKey: "strokeEnd")
    }

    return pathLayer
  }
}
