//
//  SessionMovement3DView.swift
//  Volea Measure
//
//  Created by Javier Galera Robles on 12/2/25.
//

import SwiftUI
import SceneKit
import SwiftData
import MeasureData

/// A SwiftUI view that renders a 3D representation of a recorded movement.
///
/// The view uses SceneKit to display a model that follows a computed trajectory derived from
/// sensor data (i.e. acceleration, rotation, and attitude). Additionally, it draws a "trail" (a series
/// of colored cylinders) to visualize the path and speed of the movement.
struct SessionMovement3DView: View {
    @Environment(\.colorScheme) var colorScheme
    
    /// An array of motion data samples representing a movement.
    var motionData: [RecordingMotionData]

    var body: some View {
        GeometryReader { geometry in
            SceneView(
                scene: makeScene(),
                pointOfView: makeCameraNode(),
                options: [.allowsCameraControl, .autoenablesDefaultLighting]
            )
            .ignoresSafeArea()
        }
    }
    
    // MARK: - Scene Creation
    
    /// Constructs and configures the SceneKit scene.
    ///
    /// This method creates a scene with a background color that adapts to the color scheme,
    /// computes a series of positions from sensor data, loads a 3D model from a USDZ file,
    /// and sets up both a trail visualization and animations for the model’s position and orientation.
    ///
    /// - Returns: A configured `SCNScene` ready for display.
    func makeScene() -> SCNScene {
        let scene = SCNScene()
        scene.background.contents = (colorScheme == .dark ? UIColor.black : UIColor.white)
        
        // Scale factor to amplify the subtle wrist movements.
        let scaleFactor: Float = 10.0
        
        // Compute the integrated positions from sensor data using custom integration parameters.
        let positions = computePositions(from: motionData, scale: scaleFactor)
        
        // --- MODEL LOADING ---
        // Load the USDZ model from the bundle.
        guard let modelScene = SCNScene(named: "model.usdz") else {
            fatalError("Failed to load model.usdz")
        }
        // Assume the primary node is the first child of the root node.
        let modelNode = modelScene.rootNode.childNodes.first!.clone()
        // Adjust the scale of the model (doubling its size).
        modelNode.scale = SCNVector3(2, 2, 2)
        
        // Set the initial position based on the computed positions.
        if let firstPos = positions.first {
            modelNode.position = firstPos
        }
        scene.rootNode.addChildNode(modelNode)
        
        // --- TRAIL CREATION ---
        // Create a parent node to hold the trail segments.
        let trailNode = SCNNode()
        
        // Calculate the speed for each segment between positions to map to a color.
        var segmentSpeeds: [Float] = []
        for i in 0..<(positions.count - 1) {
            let dt = Float(motionData[i+1].sensorTimestamp - motionData[i].sensorTimestamp)
            let dist = distance(from: positions[i], to: positions[i+1])
            let speed = dt > 0 ? dist / dt : 0
            segmentSpeeds.append(speed)
        }
        // Ensure a non-zero range to avoid division errors.
        let minSpeed = segmentSpeeds.min() ?? 0
        let maxSpeed = segmentSpeeds.max() ?? 0.001
        
        // Create a cylinder (line segment) between each pair of positions.
        for i in 0..<(positions.count - 1) {
            let start = positions[i]
            let end = positions[i+1]
            let dt = Float(motionData[i+1].sensorTimestamp - motionData[i].sensorTimestamp)
            let segSpeed = dt > 0 ? distance(from: start, to: end) / dt : 0
            let segColor = color(forSpeed: segSpeed, minSpeed: minSpeed, maxSpeed: maxSpeed)
            // Use a smaller radius to render finer trail lines.
            let segmentNode = cylinderLine(from: start, to: end, radius: 0.015, color: segColor)
            trailNode.addChildNode(segmentNode)
        }
        scene.rootNode.addChildNode(trailNode)
        // --- END TRAIL CREATION ---
        
        // --- ANIMATIONS ---
        // Setup animations if there is more than one position.
        if positions.count > 1,
           let t0 = motionData.first?.sensorTimestamp,
           let tLast = motionData.last?.sensorTimestamp {
            
            let totalDuration = tLast - t0
            
            // Position animation: moves the model along the computed trajectory.
            let positionAnimation = CAKeyframeAnimation(keyPath: "position")
            positionAnimation.values = positions.map { NSValue(scnVector3: $0) }
            positionAnimation.keyTimes = motionData.map { NSNumber(value: ($0.sensorTimestamp - t0) / totalDuration) }
            positionAnimation.duration = totalDuration
            positionAnimation.repeatCount = .infinity
            positionAnimation.calculationMode = .linear
            modelNode.addAnimation(positionAnimation, forKey: "positionAnimation")
            
            // Orientation animation: uses the quaternion data to smoothly animate the model's orientation.
            let orientationAnimation = CAKeyframeAnimation(keyPath: "orientation")
            orientationAnimation.values = motionData.map { data in
                let q = SCNVector4(
                    Float(data.attitudeQuaternionX),
                    Float(data.attitudeQuaternionY),
                    Float(data.attitudeQuaternionZ),
                    Float(data.attitudeQuaternionW)
                )
                return NSValue(scnVector4: q)
            }
            orientationAnimation.keyTimes = motionData.map { NSNumber(value: ($0.sensorTimestamp - t0) / totalDuration) }
            orientationAnimation.duration = totalDuration
            orientationAnimation.repeatCount = .infinity
            orientationAnimation.calculationMode = .linear
            modelNode.addAnimation(orientationAnimation, forKey: "orientationAnimation")
        }
        // --- END ANIMATIONS ---
        
        return scene
    }
    
    /// Creates and configures the camera node to provide an optimal view of the scene.
    ///
    /// - Returns: A configured `SCNNode` containing a camera.
    func makeCameraNode() -> SCNNode {
        let camera = SCNCamera()
        camera.zFar = 1000
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(0, 0, 15)
        return cameraNode
    }
    
    // MARK: - Motion Data Integration
    
    /// Computes a series of positions by integrating sensor acceleration data.
    ///
    /// This method integrates user acceleration (converted to world coordinates) over time,
    /// applies a restoring spring force to keep the trajectory bounded, and damps the velocity.
    ///
    /// - Parameters:
    ///   - data: An array of motion data samples.
    ///   - scale: A scaling factor to amplify the computed positions.
    /// - Returns: An array of `SCNVector3` positions corresponding to the integrated motion.
    func computePositions(from data: [RecordingMotionData], scale: Float) -> [SCNVector3] {
        guard data.count > 0 else { return [] }
        
        var positions: [SCNVector3] = []
        var velocity = SCNVector3Zero
        var position = SCNVector3Zero
        positions.append(position)
        
        // Integration parameters:
        let accelerationThreshold: Float = 0.02  // Threshold to filter out sensor noise.
        let springConstant: Float = 2.0          // Spring force constant to pull the position back to the origin.
        let damping: Float = 0.95                // Damping factor to reduce velocity over time.
        
        for i in 1..<data.count {
            let dt = Float(data[i].sensorTimestamp - data[i-1].sensorTimestamp)
            
            // Get user acceleration in the device coordinate system.
            let accDevice = SCNVector3(
                Float(data[i-1].userAccelerationX),
                Float(data[i-1].userAccelerationY),
                Float(data[i-1].userAccelerationZ)
            )
            // Convert acceleration to world coordinates using the previous sample’s quaternion.
            let q = SCNVector4(
                Float(data[i-1].attitudeQuaternionX),
                Float(data[i-1].attitudeQuaternionY),
                Float(data[i-1].attitudeQuaternionZ),
                Float(data[i-1].attitudeQuaternionW)
            )
            let accWorld = rotate(vector: accDevice, by: q)
            
            // Compute the magnitude of acceleration.
            let accMagnitude = sqrt(accWorld.x * accWorld.x +
                                    accWorld.y * accWorld.y +
                                    accWorld.z * accWorld.z)
            
            // Use the acceleration only if it exceeds the noise threshold.
            var effectiveAcc = SCNVector3Zero
            if accMagnitude >= accelerationThreshold {
                effectiveAcc = accWorld
            }
            
            // Apply a restoring spring force to keep the trajectory bounded.
            effectiveAcc.x -= springConstant * position.x
            effectiveAcc.y -= springConstant * position.y
            effectiveAcc.z -= springConstant * position.z
            
            // Integrate acceleration to update velocity.
            velocity.x += effectiveAcc.x * dt
            velocity.y += effectiveAcc.y * dt
            velocity.z += effectiveAcc.z * dt
            
            // Apply damping to the velocity.
            velocity.x *= damping
            velocity.y *= damping
            velocity.z *= damping
            
            // Integrate velocity to update position.
            position.x += velocity.x * dt
            position.y += velocity.y * dt
            position.z += velocity.z * dt
            
            // Scale the position and store it.
            positions.append(SCNVector3(position.x * scale,
                                          position.y * scale,
                                          position.z * scale))
        }
        
        return positions
    }
    
    // MARK: - Vector and Quaternion Utilities
    
    /// Rotates a vector using a given quaternion.
    ///
    /// This method computes the rotated vector by applying the quaternion rotation formula:
    /// rotated = q * v * q⁻¹.
    ///
    /// - Parameters:
    ///   - vector: The vector to rotate.
    ///   - quaternion: The quaternion representing the rotation.
    /// - Returns: The rotated vector.
    func rotate(vector: SCNVector3, by quaternion: SCNVector4) -> SCNVector3 {
        let qx = quaternion.x, qy = quaternion.y, qz = quaternion.z, qw = quaternion.w
        let vx = vector.x, vy = vector.y, vz = vector.z
        
        // Compute quaternion-vector multiplication (q * v), treating v as a quaternion with w = 0.
        let ix = qw * vx + qy * vz - qz * vy
        let iy = qw * vy + qz * vx - qx * vz
        let iz = qw * vz + qx * vy - qy * vx
        let iw = -qx * vx - qy * vy - qz * vz
        
        // Multiply the result by the inverse of the quaternion (q⁻¹ = (-qx, -qy, -qz, qw)).
        let rx = ix * qw + iw * -qx + iy * -qz - iz * -qy
        let ry = iy * qw + iw * -qy + iz * -qx - ix * -qz
        let rz = iz * qw + iw * -qz + ix * -qy - iy * -qx
        
        return SCNVector3(rx, ry, rz)
    }
    
    /// Computes the Euclidean distance between two 3D points.
    func distance(from: SCNVector3, to: SCNVector3) -> Float {
        let dx = to.x - from.x, dy = to.y - from.y, dz = to.z - from.z
        return sqrt(dx * dx + dy * dy + dz * dz)
    }
    
    /// Creates a cylindrical segment (line) between two points.
    ///
    /// The function creates a cylinder, positions it between the given vectors, rotates it to align with
    /// the direction from `vectorA` to `vectorB`, and applies a specified color.
    ///
    /// - Parameters:
    ///   - vectorA: The starting point.
    ///   - vectorB: The ending point.
    ///   - radius: The radius of the cylinder.
    ///   - color: The color used for the cylinder’s material.
    /// - Returns: A node representing the line segment.
    func cylinderLine(from vectorA: SCNVector3, to vectorB: SCNVector3, radius: CGFloat, color: UIColor) -> SCNNode {
        let height = CGFloat(distance(from: vectorA, to: vectorB))
        let cylinder = SCNCylinder(radius: radius, height: height)
        let material = SCNMaterial()
        material.diffuse.contents = color
        cylinder.materials = [material]
        
        let node = SCNNode(geometry: cylinder)
        node.position = midPoint(vectorA, vectorB)
        
        // SceneKit cylinders are oriented along the Y-axis by default.
        let dir = SCNVector3(vectorB.x - vectorA.x,
                             vectorB.y - vectorA.y,
                             vectorB.z - vectorA.z)
        let normalizedDir = normalize(vector: dir)
        node.orientation = quaternion(from: SCNVector3(0, 1, 0), to: normalizedDir)
        return node
    }
    
    /// Calculates the midpoint between two 3D vectors.
    func midPoint(_ a: SCNVector3, _ b: SCNVector3) -> SCNVector3 {
        return SCNVector3((a.x + b.x) / 2,
                          (a.y + b.y) / 2,
                          (a.z + b.z) / 2)
    }
    
    /// Normalizes a 3D vector.
    func normalize(vector: SCNVector3) -> SCNVector3 {
        let len = sqrt(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z)
        guard len != 0 else { return SCNVector3(0, 0, 0) }
        return SCNVector3(vector.x / len, vector.y / len, vector.z / len)
    }
    
    /// Constructs a quaternion representing the rotation from one vector to another.
    ///
    /// - Parameters:
    ///   - fromVector: The initial vector.
    ///   - toVector: The target vector.
    /// - Returns: A quaternion that rotates `fromVector` to align with `toVector`.
    func quaternion(from fromVector: SCNVector3, to toVector: SCNVector3) -> SCNQuaternion {
        let f = normalize(vector: fromVector)
        let t = normalize(vector: toVector)
        let cosTheta = f.x * t.x + f.y * t.y + f.z * t.z
        let rotationAxis = crossProduct(f, t)
        let axis = normalize(vector: rotationAxis)
        let angle = acos(cosTheta)
        return SCNQuaternion(axis.x * sin(angle/2),
                             axis.y * sin(angle/2),
                             axis.z * sin(angle/2),
                             cos(angle/2))
    }
    
    /// Computes the cross product of two 3D vectors.
    func crossProduct(_ a: SCNVector3, _ b: SCNVector3) -> SCNVector3 {
        return SCNVector3(a.y * b.z - a.z * b.y,
                          a.z * b.x - a.x * b.z,
                          a.x * b.y - a.y * b.x)
    }
    
    /// Maps a speed value to a color by interpolating between two colors.
    ///
    /// This function uses linear interpolation between blue (low speed) and red (high speed).
    ///
    /// - Parameters:
    ///   - speed: The current speed value.
    ///   - minSpeed: The minimum speed in the dataset.
    ///   - maxSpeed: The maximum speed in the dataset.
    /// - Returns: A `UIColor` representing the interpolated color.
    func color(forSpeed speed: Float, minSpeed: Float, maxSpeed: Float) -> UIColor {
        let t: CGFloat = (maxSpeed - minSpeed) > 0 ? CGFloat((speed - minSpeed) / (maxSpeed - minSpeed)) : 0
        let lowColor = UIColor.blue
        let highColor = UIColor.red
        
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        
        lowColor.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        highColor.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
        let r = r1 + t * (r2 - r1)
        let g = g1 + t * (g2 - g1)
        let b = b1 + t * (b2 - b1)
        let a = a1 + t * (a2 - a1)
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}
