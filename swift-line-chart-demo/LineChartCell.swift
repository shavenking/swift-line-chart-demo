import UIKit

fileprivate extension Dictionary where Value == [Float] {
  func maxCountOfValues() -> Int {
    return reduce(0) { (result: Int, tuple: (key: Key, value: Value)) -> Int in
      return Swift.max(result, tuple.value.count)
    }
  }
}

class LineChartCell: UICollectionViewCell {
  var values = [String: [Float]]() {
    didSet {
      drawChart()
    }
  }

  var maxValue: Float = 0

  func drawChart() {
    contentView.layer.sublayers?.forEach { layer in layer.removeFromSuperlayer() }

    guard !values.isEmpty else {
      return
    }

    let maxCountOfValues = values.maxCountOfValues()

    let step: (x: CGFloat, y: CGFloat) = (
      x: contentView.frame.width / CGFloat(maxCountOfValues - 1),
      y: contentView.frame.height / CGFloat(maxValue)
    )

    values.forEach { _, values in
      var points = [CGPoint]()
      for (index, value) in values.enumerated() {
        points.append(CGPoint(x: CGFloat(index) * step.x, y: contentView.frame.height - CGFloat(value) * step.y))
      }
      addPathLayer(points: points)
    }
  }

  private func addPathLayer(points: [CGPoint]) {
    guard !points.isEmpty else {
      return
    }

    let path = UIBezierPath()
    path.move(to: points.first!)
    points.dropFirst().forEach { point in
      path.addLine(to: point)
    }

    let animation = CABasicAnimation(keyPath: "strokeEnd")
    animation.duration = 0.5
    animation.fromValue = 0
    animation.toValue = 1

    let pathLayer = CAShapeLayer()
    pathLayer.strokeColor = UIColor.white.cgColor
    pathLayer.fillColor = UIColor.clear.cgColor
    pathLayer.lineWidth = 1.5
    pathLayer.lineJoin = kCALineJoinRound
    pathLayer.lineCap = kCALineCapRound
    pathLayer.path = path.cgPath
    pathLayer.add(animation, forKey: "strokeEnd")
    contentView.layer.addSublayer(pathLayer)
  }
}
