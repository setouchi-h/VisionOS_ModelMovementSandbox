//
//  ImmersiveView.swift
//  ModelMovementSandbox
//
//  Created by 橋本一輝 on 2024/10/03.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {
    var body: some View {
        RealityView { content in
            // モデルの読み込み
            guard let alicia = try? await ModelEntity(named: "AliciaSolid") else { return }
            
            let bounds = alicia.visualBounds(relativeTo: nil)
            alicia.position = SIMD3<Float>(0, 2 * bounds.min.y, 0)
            
            for i in 0..<alicia.jointNames.count {
                print("Joint(\(i)):\(alicia.jointNames[i])")
            }
            
            //                // モデルのjointNamesとjointTransformsを使用してボーン操作
            //                if let skeleton = alicia.availableJoints {
            //                    let spineJointName = "root/hips_joint/spine_1_joint/spine_2_joint/spine_3_joint"
            //
            //                    // 対象ボーンのインデックスを取得
            //                    if let spineJointIndex = skeleton.jointNames.firstIndex(of: spineJointName) {
            //                        let rotateRadian = Float(Angle(degrees: 1).radians)
            //
            //                        // タイマーで定期的に回転させる
            //                        Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            //                            var jointTransform = skeleton.jointTransforms[spineJointIndex]
            //                            jointTransform.rotation *= simd_quaternion(rotateRadian, [1, 0, 0])
            //                            skeleton.jointTransforms[spineJointIndex] = jointTransform
            //                        }
            //                    }
            //
            // ロボットをコンテンツに追加
            content.add(alicia)
        }
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
        .environment(AppModel())
}
