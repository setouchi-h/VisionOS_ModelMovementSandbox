//
//  ContentView.swift
//  ModelMovementSandbox
//
//  Created by 橋本一輝 on 2024/10/03.
//

import SwiftUI
import RealityKit
import Observation

@MainActor
struct ContentView: View {
    var body: some View {
        RealityView { content in
            // モデルの読み込み
            guard let alicia = try? await ModelEntity(named: "QuQu_U") else { return }

            let bounds = alicia.visualBounds(relativeTo: nil)
            alicia.position = SIMD3<Float>(0, -bounds.max.y / 2, 0)

            // キャラクターの向きを調整（必要に応じて）
            alicia.transform.rotation = simd_quatf(angle: .pi, axis: [0, 1, 0])

            // ジョイントを回転させる関数を定義
            func rotateJoint(named jointName: String, by rotation: simd_quatf) {
                if let jointIndex = alicia.jointNames.firstIndex(of: jointName) {
                    var jointTransform = alicia.jointTransforms[jointIndex]
                    jointTransform.rotation = rotation * jointTransform.rotation
                    alicia.jointTransforms[jointIndex] = jointTransform
                } else {
                    print("ジョイントが見つかりませんでした：\(jointName)")
                }
            }

            // 上腕のジョイント名と回転角度を定義
            let upperArmData: [(side: String, jointName: String, rotation: simd_quatf)] = [
                ("left", "Hips/Spine/Chest/L_Shoulder/L_UpperArm", simd_quatf(angle: .pi / 2.5, axis: [0, 0, 1])),
                ("right", "Hips/Spine/Chest/R_Shoulder/R_UpperArm", simd_quatf(angle: -.pi / 2.5, axis: [0, 0, 1]))
            ]

            // 上腕を回転して腕を下げる
            for data in upperArmData {
                rotateJoint(named: data.jointName, by: data.rotation)
            }

            // 肘のジョイント名と回転角度を定義
            let elbowData: [(side: String, jointName: String, rotation: simd_quatf)] = [
                ("left", "Hips/Spine/Chest/L_Shoulder/L_UpperArm/L_LowerArm", simd_quatf(angle: .pi / 18, axis: [0, 0, 1])),
                ("right", "Hips/Spine/Chest/R_Shoulder/R_UpperArm/R_LowerArm", simd_quatf(angle: -.pi / 18, axis: [0, 0, 1]))
            ]

            // 肘を少し曲げる
            for data in elbowData {
                rotateJoint(named: data.jointName, by: data.rotation)
            }

            // 指のデータを定義
            let fingerNames = ["thumb", "index", "middle", "ring", "little"]
            let fingerJoints = ["_proximal", "_intermediate", "_distal"]
            let handSides = ["left": "L", "right": "R"]

            // 指の曲げ角度（ラジアン）
            let fingerCurlAngles: [Float] = [
                -.pi / 4, // 第一関節（proximal）45度曲げる
                -.pi / 3, // 第二関節（intermediate）60度曲げる
                -.pi / 3  // 第三関節（distal）60度曲げる
            ]

            // 左右の手についてループ
            for (side, handPrefix) in handSides {
                // 各指についてループ
                for finger in fingerNames {
                    // 親指の場合、関節が少ない可能性があるので調整
                    let jointSuffixes: [String]
                    if finger == "thumb" {
                        jointSuffixes = ["_proximal"] // 必要に応じて増やす
                    } else {
                        jointSuffixes = fingerJoints
                    }

                    var parentPath = "Hips/Spine/Chest/\(handPrefix)_Shoulder/\(handPrefix)_UpperArm/\(handPrefix)_LowerArm/\(handPrefix)_hand"

                    // 各関節についてループ
                    for (index, jointSuffix) in jointSuffixes.enumerated() {
                        let jointName = "\(parentPath)/\(handPrefix)_\(finger)\(jointSuffix)"
                        let angle = fingerCurlAngles[index]
                        let rotationAxis: SIMD3<Float>
                        var rotationAngle: Float

                        if finger == "thumb" {
                            // 親指の回転設定
                            rotationAxis = [1, 0, 0] // X軸
                            rotationAngle = -(.pi / 3) // 60度曲げる
                        } else {
                            // 他の指の回転設定
                            rotationAxis = [0, 0, 1] // Z軸
                            rotationAngle = angle
                            if side == "left" {
                                rotationAngle = -rotationAngle
                            }
                        }
                        let fingerRotation = simd_quatf(angle: rotationAngle, axis: rotationAxis)
                        rotateJoint(named: jointName, by: fingerRotation)

                        // 次の関節のために親パスを更新
                        parentPath = jointName
                    }
                }
            }

            // モデルをシーンに追加
            content.add(alicia)
        }
    }
}

//@MainActor
//struct ContentView: View {
//    var body: some View {
//        RealityView { content in
//            // モデルの読み込み
//            guard let alicia = try? await ModelEntity(named: "QuQu_U") else { return }
//            
//            let bounds = alicia.visualBounds(relativeTo: nil)
//            alicia.position = SIMD3<Float>(0, -bounds.max.y / 2, 0)
//            
//            // キャラクターの立ち位置を180度反転
//            alicia.transform.rotation = simd_quatf(angle: .pi, axis: [0, 1, 0])
//            
//            // 必要なジョイントのインデックスを取得
//            let leftShoulderIndex = alicia.jointNames.firstIndex(of: "Hips/Spine/Chest/L_Shoulder")!
//            let leftElbowIndex = alicia.jointNames.firstIndex(of: "Hips/Spine/Chest/L_Shoulder/L_UpperArm")!
//            let leftWristIndex = alicia.jointNames.firstIndex(of: "Hips/Spine/Chest/L_Shoulder/L_UpperArm/L_LowerArm/L_hand")!
//            
//            // 初期トランスフォームを取得
//            let leftShoulderTransform = alicia.jointTransforms[leftShoulderIndex]
//            let leftElbowTransform = alicia.jointTransforms[leftElbowIndex]
//            let leftWristTransform = alicia.jointTransforms[leftWristIndex]
//            
//            // 開始ポーズの作成
//            let fromTransforms = [
//                leftShoulderTransform,
//                leftElbowTransform,
//                leftWristTransform,
//            ]
//            let fromPose = JointTransforms(fromTransforms)
//            
//            // 終了ポーズの作成
//            // 肩を前に回転、肘を伸ばし、手首を振る
//            // ここでは単純な例として回転を加えていますが、必要に応じて調整してください
//            
//            let leftShoulderToTransform = Transform(
//                scale: leftShoulderTransform.scale,
//                rotation: simd_mul(leftShoulderTransform.rotation, simd_quatf(angle: -.pi / 2, axis: [0, 1, 0])),
//                translation: leftShoulderTransform.translation
//            )
//            
//            let leftElbowToTransform = Transform(
//                scale: leftElbowTransform.scale,
//                rotation: simd_mul(leftElbowTransform.rotation, simd_quatf(angle: .pi / 8, axis: [0, 1, 0])),
//                translation: leftElbowTransform.translation
//            )
//            
//            let leftWristToTransform = Transform(
//                scale: leftWristTransform.scale,
//                rotation: simd_mul(leftWristTransform.rotation, simd_quatf(angle: .pi / 6, axis: [0, 1, 0])),
//                translation: leftWristTransform.translation
//            )
//            
//            
//            let toTransforms = [
//                leftShoulderToTransform,
//                leftElbowToTransform,
//                leftWristToTransform,
//            ]
//            let toPose = JointTransforms(toTransforms)
//            
//            // アニメーションリソースの作成
//            let jointNames = [
//                "Hips/Spine/Chest/L_Shoulder",
//                "Hips/Spine/Chest/L_Shoulder/L_UpperArm",
//                "Hips/Spine/Chest/L_Shoulder/L_UpperArm/L_LowerArm/L_hand",
//                "Hips/Spine/Chest/R_Shoulder",
//                "Hips/Spine/Chest/R_Shoulder/R_UpperArm",
//                "Hips/Spine/Chest/R_Shoulder/R_UpperArm/R_LowerArm/R_hand"
//            ]
//            
//            var fromToBy = FromToByAnimation<JointTransforms>()
//            fromToBy.name = "waveAnimation"
//            fromToBy.duration = 1.0
//            fromToBy.repeatMode = .repeat
//            fromToBy.jointNames = jointNames
//            fromToBy.fromValue = fromPose
//            fromToBy.toValue = toPose
//            fromToBy.bindTarget = .jointTransforms
//            
//            if let animationResource = try? AnimationResource.generate(with: fromToBy) {
//                alicia.playAnimation(animationResource)
//            }
//            
//            content.add(alicia)
//        }
//    }
//}


//@MainActor
//struct ContentView: View {
//    var body: some View {
//        RealityView { content in
//            // モデルの読み込み
//            guard let alicia = try? await ModelEntity(named: "QuQu_U") else { return }
//
//            let bounds = alicia.visualBounds(relativeTo: nil)
//            alicia.position = SIMD3<Float>(0, -bounds.max.y / 2, 0)
//
//            // キャラクターの立ち位置を180度反転
//            alicia.transform.rotation = simd_quatf(angle: .pi, axis: [0, 1, 0])
//
//            for i in 0..<alicia.jointNames.count {
//                print("Joint(\(i)):\(alicia.jointNames[i])")
//            }
//
//            // 左右の肩のジョイントを取得
//            let leftShoulderJointName = "Hips/Spine/Spine1/Spine2/Spine3/LeftShoulder"
//            let rightShoulderJointName = "Hips/Spine/Spine1/Spine2/Spine3/RightShoulder"
//            let leftShoulderJointIndex = alicia.jointNames.firstIndex(of: leftShoulderJointName)!
//            let rightShoulderJointIndex = alicia.jointNames.firstIndex(of: rightShoulderJointName)!
//
//            // 左右の肩の初期Transformを取得
//            let leftShoulderJoint = alicia.jointTransforms[leftShoulderJointIndex]
//            let rightShoulderJoint = alicia.jointTransforms[rightShoulderJointIndex]
//
//            // アニメーションの開始ポーズの作成
//            let fromTransforms: [Transform] = [leftShoulderJoint, rightShoulderJoint]
//            let fromPose = JointTransforms(fromTransforms)
//
//            // アニメーションの終了ポーズの作成
//            let leftToTransform = Transform(scale: [1, 1, 1], rotation: simd_quatf(angle: -.pi / 3, axis: [0, 0, 1]), translation: leftShoulderJoint.translation)
//            let rightToTransform = Transform(scale: [1, 1, 1], rotation: simd_quatf(angle: .pi / 3, axis: [0, 1, 0]), translation: rightShoulderJoint.translation)
//            let toTransforms: [Transform] = [leftToTransform, rightToTransform]
//            let toPose = JointTransforms(toTransforms)
//
//            // アニメーションリソースを作成
//            let jointNames = [leftShoulderJointName, rightShoulderJointName]
//            var fromToBy = FromToByAnimation<JointTransforms>()
//            fromToBy.name = "armSwing"
//            fromToBy.duration = 1.0
//            fromToBy.repeatMode = .autoReverse
//            fromToBy.jointNames = jointNames
//            fromToBy.fromValue = fromPose
//            fromToBy.toValue = toPose
//            fromToBy.bindTarget = .jointTransforms
//
//            // アニメーションリソースを生成
//            if let animationResource = try? AnimationResource.generate(with: fromToBy) {
//                // アニメーションを再生
//                alicia.playAnimation(animationResource)
//            }
//
//            content.add(alicia)
//        }
//    }
//}


//@MainActor
//struct ContentView: View {
//    var body: some View {
//        RealityView { content in
//            // モデルの読み込み
//            guard let character = try? await ModelEntity(named: "QuQu_U") else { return }
//
//            let bounds = character.visualBounds(relativeTo: nil)
//            character.position = SIMD3<Float>(0, -bounds.max.y / 2, 0)
//
//            // キャラクターの立ち位置を180度反転
//            character.transform.rotation = simd_quatf(angle: .pi, axis: [0, 1, 0])
//
//            // ブレンドシェイプのリストを取得
//            let blendShapeNames = character.blendWeightNames
//            blendShapeNames.forEach { print($0) }
//            print(character.blendWeights)
//
//            // 口に関するブレンドシェイプのインデックスを取得（例: blendShape0 が口の開閉と仮定）
//            //            let mouthBlendShapeIndex = blendShapeNames[0]
//
//            // タイマーを使って口を開閉させる
//            //            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
//            //                let time = Float(timer.fireDate.timeIntervalSinceReferenceDate).truncatingRemainder(dividingBy: 1.0)
//            //                let weight = (sin(time * 2.0 * .pi) + 1.0) / 2.0  // 0.0 から 1.0 までの範囲で変化
//            //
//            //            }
//            character.blendWeights[1][3] = 1
//
//            // シーンにモデルを追加
//            content.add(character)
//        }
//    }
//}

#Preview(windowStyle: .volumetric) {
    ContentView()
}
