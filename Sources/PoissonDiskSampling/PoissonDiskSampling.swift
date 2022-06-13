//
//  UserDefaultsConvertible.swift
//
//
//  Created by Anton Protko on 4.06.22.
//

import Foundation
import CoreGraphics

public class PoissonDiskSampling {
    private func randomFloat() -> CGFloat {
        return CGFloat.random(in: 0...1)
    }

    private func randomPointAround(point: CGPoint,
                                   minDistance: CGFloat,
                                   maxDistance: CGFloat) -> CGPoint {
        let radius = CGFloat.random(in: minDistance...maxDistance)
        let angle = 2 * CGFloat.pi * randomFloat()
        
        let newX = point.x + radius * cos(angle)
        let newY = point.y + radius * sin(angle)
        return CGPoint(x: newX, y: newY)
    }
    
    private func getGridIndex(for point: CGPoint, cellSize: CGFloat) -> (x: Int, y: Int) {
        return (x: Int(floor(point.x / cellSize)),
                y: Int(floor(point.y / cellSize)))
    }

    private func isCandidateValid(candidate: CGPoint,
                                  size: CGSize,
                                  grid: [[Int]],
                                  gridSize: (x: Int, y: Int),
                                  cellSize: CGFloat,
                                  radius: CGFloat,
                                  points: [CGPoint]) -> Bool {
        guard
            candidate.x >= 0,
            candidate.y >= 0,
            candidate.x < size.width,
            candidate.y < size.height
        else {
            return false
        }
        
        let cellIndex = getGridIndex(for: candidate, cellSize: cellSize)
        
        let xRange = stride(from: max(0, cellIndex.x - 2),
                            to: min(cellIndex.x + 2, gridSize.x - 1) + 1,
                            by: 1)
        
        let yRange = stride(from: max(0, cellIndex.y - 2),
                            to: min(cellIndex.y + 2, gridSize.y - 1) + 1,
                            by: 1)
        
        for x in xRange {
            for y in yRange {
                let index = grid[x][y]
                if index != -1 {
                    let distance = candidate.distance(to: points[index])
                    if distance < radius {
                        return false
                    }
                }
            }
        }
        
        return true
    }
    
    private func addCandidate(_ candidate: CGPoint,
                              activePoints: inout [CGPoint],
                              points: inout [CGPoint],
                              grid: inout [[Int]],
                              cellSize: CGFloat) {
        points.append(candidate)
        activePoints.append(candidate)
        let index = getGridIndex(for: candidate, cellSize: cellSize)
        grid[index.x][index.y] = points.count - 1
    }
    
    public func getApproximatedRadius(pointCount: Int, size: CGSize) -> CGFloat {
        getApproximatedRadius(pointCount: pointCount, rect: .init(origin: .zero, size: size))
    }
    
    public func getApproximatedRadius(pointCount: Int, rect: CGRect) -> CGFloat {
        // aproximated points count function of sampling algorithm
        let referenceSize = CGSize(width: 100, height: 100)
        let squareFactor = (rect.width + rect.height) / (referenceSize.width + referenceSize.height)
        return pow(CGFloat(pointCount), -0.562) * 105 * squareFactor
    }
    
    public func sample(radius: CGFloat,
                       in size: CGSize,
                       rejectionThreshold: Int = 30) -> [CGPoint] {
        sample(radius: radius,
               in: .init(origin: .zero, size: size),
               rejectionThreshold: rejectionThreshold)
    }
    
    public func sample(radius: CGFloat,
                       in rect: CGRect,
                       rejectionThreshold: Int = 30) -> [CGPoint] {
        let size = rect.size
        let cellSize: CGFloat = radius / sqrt(2)
        let gridSize: (x: Int, y: Int) = {
            let index = getGridIndex(for: .init(x: size.width,
                                                y: size.height),
                                     cellSize: cellSize)
            return (index.x + 1, index.y + 1)
        }()
        
        var grid = Array(repeating: Array(repeating: -1,
                                          count: gridSize.y),
                         count: gridSize.x)
        
        var points = [CGPoint]()
        var activePoints = [CGPoint]()
        
        let initial = CGPoint(x: size.width * randomFloat(),
                              y: size.height * randomFloat())
        
        addCandidate(initial,
                     activePoints: &activePoints,
                     points: &points,
                     grid: &grid,
                     cellSize: cellSize)
        
        while(!activePoints.isEmpty) {
            let randomIndex = activePoints.indices.randomElement()!
            let randomPoint = activePoints[randomIndex]
            
            var candidateFound = false
            
            for _ in 0..<rejectionThreshold {
                let candidate = randomPointAround(point: randomPoint,
                                                  minDistance: radius,
                                                  maxDistance: 2 * radius)
                
                if isCandidateValid(candidate: candidate,
                                    size: size,
                                    grid: grid,
                                    gridSize: gridSize,
                                    cellSize: cellSize,
                                    radius: radius,
                                    points: points) {
                    addCandidate(candidate,
                                 activePoints: &activePoints,
                                 points: &points,
                                 grid: &grid,
                                 cellSize: cellSize)
                    candidateFound = true
                    break
                }
            }
            
            if !candidateFound {
                activePoints.remove(at: randomIndex)
            }
        }
        
        return points.map { $0 + rect.origin }
    }
}

func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x + rhs.x,
                   y: lhs.y + rhs.y)
}

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        let dx = x - point.x
        let dy = y - point.y
        return sqrt(dx * dx + dy * dy)
    }
}
