import UIKit

class LineChart: UICollectionView {
  var lines = [String: [Float]]()

  var maxValue: Float?

  var chunkSize: Int = 10 {
    didSet {
      if chunkSize < 2 {
        chunkSize = 2
      }
    }
  }

  lazy var longPressGesture: UILongPressGestureRecognizer = {
    return UILongPressGestureRecognizer(target: self, action: #selector(userDidLongPress))
  }()

  lazy var pinchGesture: UIPinchGestureRecognizer = {
    return UIPinchGestureRecognizer(target: self, action: #selector(userDidZoom))
  }()

  let highlightPathLayer: CAShapeLayer = PathLayerFactory.make()

  var yLabelView: LineChartYLabelReusableView?

  override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
    super.init(frame: frame, collectionViewLayout: layout)

    dataSource = self
    delegate = self
    register(LineChartCell.self, forCellWithReuseIdentifier: String(describing: LineChartCell.self))
    register(LineChartYLabelReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: String(describing: LineChartYLabelReusableView.self))
    addGestureRecognizer(longPressGesture)
    addGestureRecognizer(pinchGesture)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: Convenience init
extension LineChart {
  convenience init(frame: CGRect = .zero) {
    self.init(frame: frame, collectionViewLayout: LineChartLayout())
  }
}

// MARK: UICollectionView
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
    cell.lines = lines.mapValues { values -> [Float] in
      if start >= values.count {
        return []
      }

      return Array(values.suffix(from: start).prefix(chunkSize))
    }
    cell.yLabelValues = Array(start..<start + cell.lines.maxCountOfValues())
    cell.drawChart()

    return cell
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return collectionView.frame.size
  }

  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: String(describing: LineChartYLabelReusableView.self), for: indexPath) as! LineChartYLabelReusableView
    view.maxValue = lines.maxValue()
    yLabelView = view
    return view
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    return CGSize(width: 40, height: 100)
  }

  override func reloadData() {
    maxValue = lines.maxValue()
    super.reloadData()
  }

  override func reloadSections(_ sections: IndexSet) {
    maxValue = lines.maxValue()
    super.reloadSections(sections)
  }

  override func reloadItems(at indexPaths: [IndexPath]) {
    maxValue = lines.maxValue()
    super.reloadItems(at: indexPaths)
  }
}

// MARK: Gestures
extension LineChart {
  @objc private func userDidLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
    var location = gestureRecognizer.location(in: gestureRecognizer.view)
    location = CGPoint(x: max(contentOffset.x + 40 + highlightPathLayer.lineWidth, location.x), y: min(frame.maxY - 40, location.y))

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
    highlightPathLayer.path = path.cgPath

    if gestureRecognizer.state == .began {
      self.layer.addSublayer(highlightPathLayer)
    }

    if gestureRecognizer.state == .ended {
      highlightPathLayer.removeFromSuperlayer()
      yLabelView?.highlightPoint = nil
    }
  }

  @objc private func userDidZoom(_ gestureRecognizer: UIPinchGestureRecognizer) {
    if gestureRecognizer.state == .ended {
      chunkSize = Int((CGFloat(chunkSize) / gestureRecognizer.scale).rounded(.up))

      reloadData()
    }
  }
}

// MARK: Public methods
extension LineChart {
  func addLine(values: [Float], label: String = UUID().uuidString) {
    self.lines[label] = values
  }
}
