import UIKit

class LineChartLayout: UICollectionViewFlowLayout {
  override init() {
    super.init()

    scrollDirection = .horizontal
    minimumInteritemSpacing = 0
    minimumLineSpacing = 0
    sectionHeadersPinToVisibleBounds = true
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
}
