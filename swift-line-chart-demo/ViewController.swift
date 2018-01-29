import UIKit
import QuartzCore

class LineChart: UIView {
  private var values = [String: [Float]]()

  override func layoutSubviews() {
    super.layoutSubviews()

    layer.sublayers?.forEach { $0.removeFromSuperlayer() }

    addBorderLayer()
    addValuesLayer()
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension LineChart {
  func addLine(values: [Float], label: String = UUID().uuidString) {
    self.values[label] = values
  }
}

extension LineChart {
  private func addBorderLayer() {
    addPathLayer(start: .zero, points: [
      CGPoint(x: bounds.minX, y: bounds.maxY),
      CGPoint(x: bounds.maxX, y: bounds.maxY)
    ])
  }

  private func addValuesLayer() {
    let max = values.max { lhs, rhs in
      guard let lhsMax = lhs.value.max() else {
        return false
      }

      guard let rhsMax = rhs.value.max() else {
        return true
      }

      return lhsMax < rhsMax
    }?.value.max()

    let maxCount = values.max { lhs, rhs in
      return lhs.value.count < rhs.value.count
    }?.value.count

    guard max != nil, maxCount != nil else {
      return
    }

    let step: (x: CGFloat, y: CGFloat) = (
      x: bounds.width / CGFloat(maxCount!),
      y: bounds.height / CGFloat(max!)
    )

    values.forEach { label, values in
      var points = [CGPoint]()
      for (index, value) in values.enumerated() {
        points.append(CGPoint(x: CGFloat(index) * step.x, y: bounds.height - CGFloat(value) * step.y))
      }
      addPathLayer(start: .zero, points: points)
    }
  }

  private func addPathLayer(start: CGPoint, points: [CGPoint]) {
    let path = UIBezierPath()
    path.move(to: start)
    points.forEach { point in
      path.addLine(to: point)
    }

    let animation = CABasicAnimation(keyPath: "strokeEnd")
    animation.duration = 0.5
    animation.fromValue = 0
    animation.toValue = 1

    let borderLayer = CAShapeLayer()
    borderLayer.strokeColor = UIColor.black.cgColor
    borderLayer.fillColor = UIColor.clear.cgColor
    borderLayer.lineWidth = 1.5
    borderLayer.lineJoin = kCALineJoinRound
    borderLayer.path = path.cgPath
    borderLayer.add(animation, forKey: "strokeEnd")
    layer.addSublayer(borderLayer)
  }
}

class ViewController: UIViewController {
  let lineChart = LineChart()

  override func viewDidLoad() {
    super.viewDidLoad()

    lineChart.frame = CGRect(x: 100, y: 100, width: 100, height: 100)
    for _ in stride(from: 0, to: 2, by: 1) {
      var values = [Float]()
      for _ in stride(from: 0, to: 10, by: 1) {
        values.append(Float(arc4random_uniform(10000)))
      }
      lineChart.addLine(values: values)
    }
    view.addSubview(lineChart)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    sleep(3)
    lineChart.frame.size.width = 150
  }
}

