import UIKit

class LineChartYLabelReusableView: UICollectionReusableView {
  var lines: [Float]? {
    didSet {
      guard let values = lines?.sorted(), !values.isEmpty else {
        return
      }

      let max = values.max()!
      let chartRect = UIEdgeInsetsInsetRect(frame, UIEdgeInsets(top: 20, left: 0, bottom: 40, right: 0))
      let step = chartRect.height / CGFloat(max)
      var minimumPosition: CGFloat = chartRect.maxY

      values.forEach {
        let label = UILabel()
        label.text = "\($0)"
        label.textColor = .white
        label.sizeToFit()
        label.frame.size.width = chartRect.width
        label.frame.origin = CGPoint(x: 0, y: Swift.max(0, chartRect.height - label.frame.height / 2 - CGFloat($0) * step + 20))
        if label.frame.maxY <= minimumPosition {
          addSubview(label)
          minimumPosition -= label.frame.height + 8
        }
      }
    }
  }

  var highlightPoint: CGPoint? {
    didSet {
      if let highlightPoint = highlightPoint {
        subviews.forEach {
          if $0.frame.contains(CGPoint(x: $0.center.x, y: highlightPoint.y)) {
            $0.backgroundColor = .white
            ($0 as? UILabel)?.textColor = .black
          } else {
            $0.backgroundColor = .black
            ($0 as? UILabel)?.textColor = .white
          }
        }
      } else {
        subviews.forEach {
          $0.backgroundColor = .black
          ($0 as? UILabel)?.textColor = .white
        }
      }
    }
  }

  override func prepareForReuse() {
    super.prepareForReuse()

    subviews.forEach { $0.removeFromSuperview() }
  }

  override init(frame: CGRect) {
    super.init(frame: frame)

    backgroundColor = .black
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
}
