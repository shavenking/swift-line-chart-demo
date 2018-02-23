import UIKit

fileprivate extension Dictionary where Value == [Float] {
  func maxCountOfValues() -> Int {
    return reduce(0) { (result: Int, tuple: (key: Key, value: Value)) -> Int in
      return Swift.max(result, tuple.value.count)
    }
  }
}

class LineChartCell: UICollectionViewCell {
  var values = [String: [Float]]()

  var maxValue: Float?

  var yLabels = [Int]()

  var highlightPoint: CGPoint? {
    didSet {
      if let highlightPoint = highlightPoint {
        contentView.subviews.forEach {
          guard let label = $0 as? UILabel else { return }

          if label.frame.contains(CGPoint(x: highlightPoint.x, y: label.center.y)) {
            label.backgroundColor = .white
            label.textColor = .black
          } else {
            label.backgroundColor = .black
            label.textColor = .white
          }
        }
      } else {
        contentView.subviews.forEach {
          guard let label = $0 as? UILabel else { return }

          label.backgroundColor = .black
          label.textColor = .white
        }
      }
    }
  }

  func drawChart() {
    contentView.layer.sublayers?.forEach { layer in layer.removeFromSuperlayer() }
    contentView.subviews.forEach { view in view.removeFromSuperview() }

    guard !values.isEmpty, let maxValue = maxValue else {
      return
    }

    let maxCountOfValues = values.maxCountOfValues()
    let chartRect = UIEdgeInsetsInsetRect(contentView.frame, UIEdgeInsets(top: 20, left: 0, bottom: 40, right: 0))

    let step: (x: CGFloat, y: CGFloat) = (
      x: chartRect.width / CGFloat(maxCountOfValues - 1),
      y: chartRect.height / CGFloat(maxValue)
    )

    values.forEach { _, values in
      var points = [CGPoint]()
      for (index, value) in values.enumerated() {
        points.append(CGPoint(x: CGFloat(index) * step.x, y: chartRect.height - CGFloat(value) * step.y + 20))
      }
      addPathLayer(points: points)
    }
  }

  private func addPathLayer(points: [CGPoint]) {
    guard points.count > 1, yLabels.count > 1 else {
      return
    }

    let path = UIBezierPath()
    path.move(to: points.first!)
    var minimumPosition: CGFloat = 0.0
    for (point, yLabel) in zip(points.suffix(from: 1), yLabels.suffix(from: 1)) {
      path.addLine(to: point)
      let label = UILabel()
      label.text = "\(yLabel)"
      label.sizeToFit()
      label.frame.origin = CGPoint(x: point.x, y: contentView.frame.height - 40)
      label.textColor = .white
      if label.frame.origin.x >= minimumPosition && label.frame.maxX <= contentView.frame.maxX {
        contentView.addSubview(label)
        minimumPosition += label.frame.width + 8
      }
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
