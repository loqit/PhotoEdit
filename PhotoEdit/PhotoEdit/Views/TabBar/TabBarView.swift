//
//  TabBarView.swift
//  PhotoEdit
//
//  Created by Андрей Бобр on 3.06.24.
//

import SwiftUI

struct TabBarView: View {
    var body: some View {
        TabView {
            CropView()
                .tabItem {
                    Label("Edit", systemImage: "photo")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
    }
}
