import XCTest
@testable import PoissonDiskSampling

final class PoissonDiskSamplingTests: XCTestCase {
    func testDistance() throws {
        for _ in 0..<10 {
            let sampler = PoissonDiskSampling()
            let radius: CGFloat = 50
            let size = CGSize(width: 1000, height: 1000)
            let points = sampler.sample(radius: radius, in: size)
            for i in 0..<points.count {
                for j in 0..<points.count {
                    if i == j { continue }
                    let distance = points[i].distance(to: points[j])
                    XCTAssert(distance >= radius)
                }
            }
        }
    }
}
