import UIKit
import QuartzCore

class ViewController: UIViewController {
  let lineChart = LineChart()

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    view.addSubview(lineChart)
    lineChart.translatesAutoresizingMaskIntoConstraints = false
    lineChart.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor).isActive = true
    lineChart.heightAnchor.constraint(equalTo: view.layoutMarginsGuide.heightAnchor).isActive = true
    lineChart.centerYAnchor.constraint(equalTo: view.layoutMarginsGuide.centerYAnchor).isActive = true
    lineChart.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor).isActive = true
    for _ in stride(from: 0, to: 2, by: 1) {
      var values = [Float]()
      for _ in stride(from: 0, to: arc4random_uniform(1000), by: 1) {
        values.append(Float([1,2,3,4,5,6,7,8,9,10][Int(arc4random_uniform(10))]))
      }
      lineChart.addLine(values: values)
    }
    lineChart.chunkSize = 3
    lineChart.reloadData()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    lineChart.collectionViewLayout.invalidateLayout()
  }
}

