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
    for _ in stride(from: 0, to: 1, by: 1) {
      var values = [Float]()
      for _ in stride(from: 0, to: 10000, by: 1) {
        values.append(Float(arc4random_uniform(10000)))
      }
      lineChart.addLine(values: values)
    }
    //    lineChart.addLine(values: [1,46,6,10])
    //    lineChart.addLine(values: [1,10,6,46,1,46,10,1])
    lineChart.chunkSize = 100
    lineChart.reloadData()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    lineChart.collectionViewLayout.invalidateLayout()
  }
}

