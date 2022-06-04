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
