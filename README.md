# PoissonDiskSampling

## Description
Swift implementation of Poisson disk sampling algorithm

## Usage
```Swift
import PoissonDiskSampling

let radius: CGFloat = 50
let size = CGSize(width: 1000, height: 1000)
let points = PoissonDiskSampling().sample(radius: radius, in: size)
```

## Installation
### SPM
```Swift
.package(url: "https://github.com/maveric94/PoissonDiskSampling.git", .upToNextMajor(from: "1.0.0"))
```
