import UIKit
import QuartzCore

fileprivate func constraint(_ child: UIView, equalTo parent: UIView) {
  parent.addSubview(child)
  child.translatesAutoresizingMaskIntoConstraints = false
  child.widthAnchor.constraint(equalTo: parent.widthAnchor).isActive = true
  child.heightAnchor.constraint(equalTo: parent.heightAnchor).isActive = true
  child.centerYAnchor.constraint(equalTo: parent.centerYAnchor).isActive = true
  child.centerXAnchor.constraint(equalTo: parent.centerXAnchor).isActive = true
}

fileprivate func make(numberOfSequence: Int, maxSize: UInt32) -> [[Float]] {
  var integerSequences = [[Float]]()

  for _ in stride(from: 0, to: numberOfSequence, by: 1) {
    var integerSequence = [Float]()

    for _ in stride(from: 0, to: arc4random_uniform(maxSize), by: 1) {
      integerSequence.append(Float([1,2,3,4,5,6,7,8,9,10][Int(arc4random_uniform(10))]))
    }

    integerSequences.append(integerSequence)
  }

  return integerSequences
}

class ViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    let lineChart = LineChart()
    constraint(lineChart, equalTo: view)

//    make(numberOfSequence: 1, maxSize: 110).forEach { lineChart.addLine(lines: $0) }

    lineChart.addLine(values: [5.0, 6.0, 3.0, 5.0, 3.0, 3.0, 9.0, 2.0, 7.0, 10.0, 6.0, 2.0, 5.0, 4.0, 4.0, 8.0, 9.0, 9.0, 7.0, 3.0, 8.0, 1.0, 2.0, 10.0, 8.0, 5.0, 8.0, 10.0, 3.0, 2.0, 6.0, 1.0, 10.0, 6.0, 5.0, 4.0, 6.0, 8.0, 6.0, 9.0, 4.0, 4.0, 1.0, 8.0, 3.0, 9.0, 10.0, 8.0, 3.0, 1.0, 10.0, 3.0, 10.0, 10.0, 6.0, 8.0, 2.0, 10.0, 8.0, 3.0, 8.0, 3.0, 1.0, 4.0, 4.0, 6.0, 2.0, 8.0, 2.0, 6.0, 9.0, 4.0, 3.0, 4.0, 1.0, 7.0, 5.0, 5.0, 2.0, 1.0, 5.0, 10.0, 6.0, 3.0, 9.0, 4.0, 7.0, 1.0, 8.0, 9.0, 10.0, 5.0, 9.0, 6.0, 7.0, 10.0, 1.0, 7.0, 3.0, 5.0, 9.0, 8.0, 3.0, 3.0, 10.0, 4.0])
    lineChart.reloadData()
  }
}

