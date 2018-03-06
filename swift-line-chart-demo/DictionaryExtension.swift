import Foundation

extension Dictionary where Value == [Float] {
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
