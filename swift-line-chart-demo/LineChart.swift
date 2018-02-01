import UIKit

fileprivate extension Dictionary where Value == [Float] {
  func maxCountOfValues() -> Int {
    return reduce(0) { (result: Int, tuple: (key: Key, value: Value)) -> Int in
      return Swift.max(result, tuple.value.count)
    }
  }
}

class LineChartLayout: UICollectionViewFlowLayout {}

class LineChart: UICollectionView {
  var lines = [String: [Float]]() {
    didSet {
      let maxValue = lines.max { lhs, rhs in
        guard let lhsMax = lhs.value.max() else {
          return false
        }

        guard let rhsMax = rhs.value.max() else {
          return true
        }

        return lhsMax < rhsMax
      }?.value.max()

      self.maxValue = maxValue ?? 0
    }
  }

  var maxValue: Float = 0

  var chunkSize: Int = 10 {
    didSet {
      if chunkSize <= 1 {
        chunkSize = 10
      }
    }
  }

  override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
    super.init(frame: frame, collectionViewLayout: layout)

    dataSource = self
    delegate = self
    register(LineChartCell.self, forCellWithReuseIdentifier: String(describing: LineChartCell.self))
  }

  convenience init(frame: CGRect = .zero) {
    let layout = LineChartLayout()
    layout.scrollDirection = .horizontal
    layout.minimumInteritemSpacing = 0
    layout.minimumLineSpacing = 0
    self.init(frame: frame, collectionViewLayout: layout)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension LineChart: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return Int((Float(lines.maxCountOfValues()) / Float(chunkSize)).rounded(.up))
  }

  func collectionView(_ collectionView: UICollectionView,
                      cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = dequeueReusableCell(
      withReuseIdentifier: String(describing: LineChartCell.self),
      for: indexPath
    ) as? LineChartCell else {
      fatalError("bla bla bla...")
    }

    let start = max(0, indexPath.row * chunkSize - 1)

    cell.maxValue = maxValue
    cell.values = lines.mapValues { values -> [Float] in
      return Array(values.suffix(from: start).prefix(chunkSize + (start == 0 ? 0 : 1)))
    }

    return cell
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return collectionView.frame.size
  }
}

extension LineChart {
  func addLine(values: [Float], label: String = UUID().uuidString) {
    self.lines[label] = values
  }
}