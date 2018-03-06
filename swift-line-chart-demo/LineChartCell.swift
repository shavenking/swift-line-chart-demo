import UIKit

class LineChartCell: UICollectionViewCell {
  var lines = [String: [Float]]()

  var maxValue: Float?

  var yLabelValues = [Int]()

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

  var pathLayers = [CAShapeLayer]()

  var yLabels = [UILabel]()

  private func addPathLayer(points: [CGPoint]) {
    guard points.count > 1, yLabelValues.count > 1 else {
      return
    }

    let path = UIBezierPath()
    path.move(to: points.first!)
    var minimumPosition: CGFloat = 0.0
    for (point, yLabel) in zip(points.suffix(from: 1), yLabelValues.suffix(from: 1)) {
      path.addLine(to: point)
      let label = UILabel()
      label.text = "\(yLabel)"
      label.sizeToFit()
      label.frame.origin = CGPoint(x: point.x, y: contentView.frame.height - 40)
      label.textColor = .white
      if label.frame.origin.x >= minimumPosition && label.frame.maxX <= contentView.frame.maxX {
        contentView.addSubview(label)
        yLabels.append(label)
        minimumPosition += label.frame.width + 8
      }
    }

    let pathLayer = PathLayerFactory.make(path: path.cgPath, animation: false)
    contentView.layer.addSublayer(pathLayer)
    pathLayers.append(pathLayer)
  }

  override func prepareForReuse() {
    pathLayers.forEach { layer in layer.removeFromSuperlayer() }
    yLabels.forEach { label in label.removeFromSuperview() }

    pathLayers.removeAll()
    yLabels.removeAll()

    super.prepareForReuse()
  }
}

// MARK: Public methods
extension LineChartCell {
  func drawChart() {
    guard !lines.isEmpty, let maxValue = maxValue else { return }

    let maxCountOfValues = lines.maxCountOfValues()
    let chartRect = UIEdgeInsetsInsetRect(contentView.frame, UIEdgeInsets(top: 20, left: 0, bottom: 40, right: 0))

    let step: (x: CGFloat, y: CGFloat) = (
      x: chartRect.width / CGFloat(maxCountOfValues - 1),
      y: chartRect.height / CGFloat(maxValue)
    )

    lines.forEach { _, values in
      var points = [CGPoint]()
      for (index, value) in values.enumerated() {
        points.append(CGPoint(x: CGFloat(index) * step.x, y: chartRect.height - CGFloat(value) * step.y + 20))
      }
      addPathLayer(points: points)
    }
  }
}
