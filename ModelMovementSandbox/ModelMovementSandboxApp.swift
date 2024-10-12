//
//  ModelMovementSandboxApp.swift
//  ModelMovementSandbox
//
//  Created by 橋本一輝 on 2024/10/03.
//

import SwiftUI

@main
struct ModelMovementSandboxApp: App {

    @State private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appModel)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 2000, height: 7000, depth: 1500)

        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView()
                .environment(appModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
    }
}
