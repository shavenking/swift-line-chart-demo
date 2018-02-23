import UIKit

fileprivate extension Dictionary where Value == [Float] {
  func maxCountOfValues() -> Int {
    return reduce(0) { (result: Int, tuple: (key: Key, value: Value)) -> Int in
      return Swift.max(result, tuple.value.count)
    }
  }

  func maxValue() -> Float? {
    var maxValue: Float?

    filter { (tuple: (key: Key, value: [Float])) -> Bool in
      return tuple.value.count > 0
    }.forEach { (tuple: (key: Key, value: [Float])) in
      guard let tupleMaxValue = tuple.value.max() else { return }
      maxValue = Swift.max(maxValue ?? Float.leastNormalMagnitude, tupleMaxValue)
    }

    return maxValue
  }
}

class LineChartLayout: UICollectionViewFlowLayout {}

class LineChart: UICollectionView {
  var lines = [String: [Float]]() {
    didSet {
      maxValue = lines.maxValue()
    }
  }

  var maxValue: Float?

  var chunkSize: Int = 2 {
    didSet {
      if chunkSize < 2 {
        chunkSize = 2
      }
    }
  }

  override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
    super.init(frame: frame, collectionViewLayout: layout)

    dataSource = self
    delegate = self
    register(LineChartCell.self, forCellWithReuseIdentifier: String(describing: LineChartCell.self))
    register(LineChartYLabelReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: String(describing: LineChartYLabelReusableView.self))
    let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(userDidLongPress))
    addGestureRecognizer(longPressGesture)

    let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(userDidZoom))
    addGestureRecognizer(pinchGesture)
  }

  @objc func userDidZoom(_ gestureRecognizer: UIPinchGestureRecognizer) {
    if gestureRecognizer.state == .ended {
      chunkSize = Int((CGFloat(chunkSize) / gestureRecognizer.scale).rounded(.up))
      self.reloadData()
    }
  }

  let yPathLayer: CAShapeLayer = {
    let pathLayer = CAShapeLayer()
    pathLayer.strokeColor = UIColor.white.cgColor
    pathLayer.fillColor = UIColor.clear.cgColor
    pathLayer.lineWidth = 1.5
    pathLayer.lineJoin = kCALineJoinRound
    pathLayer.lineCap = kCALineCapRound
    return pathLayer
  }()

  var yLabelView: LineChartYLabelReusableView?

  @objc func userDidLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
    var location = gestureRecognizer.location(in: gestureRecognizer.view)
    location = CGPoint(x: max(contentOffset.x + 40 + yPathLayer.lineWidth, location.x), y: min(frame.maxY - 40, location.y))

    if let indexPath = indexPathForItem(at: gestureRecognizer.location(in: self)), let cell = cellForItem(at: indexPath) as? LineChartCell {
      if gestureRecognizer.state == .ended {
        cell.highlightPoint = nil
      } else {
        cell.highlightPoint = gestureRecognizer.location(in: cell.contentView)
      }
    }

    yLabelView?.highlightPoint = location

    let path = UIBezierPath()
    path.move(to: CGPoint(x: location.x, y: 0))
    path.addLine(to: CGPoint(x: location.x, y: self.frame.maxY - 40))
    path.move(to: CGPoint(x: contentOffset.x, y: location.y))
    path.addLine(to: CGPoint(x: contentOffset.x + frame.width, y: location.y))
    yPathLayer.path = path.cgPath

    if gestureRecognizer.state == .began {
      self.layer.addSublayer(yPathLayer)
    }

    if gestureRecognizer.state == .ended {
      yPathLayer.removeFromSuperlayer()
      yLabelView?.highlightPoint = nil
    }
  }

  convenience init(frame: CGRect = .zero) {
    let layout = LineChartLayout()
    layout.scrollDirection = .horizontal
    layout.minimumInteritemSpacing = 0
    layout.minimumLineSpacing = 0
    layout.sectionHeadersPinToVisibleBounds = true
    self.init(frame: frame, collectionViewLayout: layout)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension LineChart: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return (lines.maxCountOfValues() - chunkSize) / (chunkSize - 1) + 1
  }

  func collectionView(_ collectionView: UICollectionView,
                      cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = dequeueReusableCell(
      withReuseIdentifier: String(describing: LineChartCell.self),
      for: indexPath
    ) as? LineChartCell else {
      fatalError("bla bla bla...")
    }

    let start = indexPath.row * (chunkSize - 1)

    cell.maxValue = maxValue
    cell.values = lines.mapValues { values -> [Float] in
      if start >= values.count {
        return []
      }

      return Array(values.suffix(from: start).prefix(chunkSize))
    }
    cell.yLabels = Array(start..<start+cell.values.maxCountOfValues())
    cell.drawChart()

    return cell
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return collectionView.frame.size
  }

  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: String(describing: LineChartYLabelReusableView.self), for: indexPath) as! LineChartYLabelReusableView
    view.values = Array(Set(lines.values.flatMap { $0 }))
    yLabelView = view
    return view
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    return CGSize(width: 40, height: 100)
  }
}

extension LineChart {
  func addLine(values: [Float], label: String = UUID().uuidString) {
    self.lines[label] = values
  }
}
