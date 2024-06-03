//
//  SettingsView.swift
//  PhotoEdit
//
//  Created by Андрей Бобр on 3.06.24.
//

import SwiftUI

struct SettingsView: View {
    
    @StateObject private var viewModel = SettingsViewModel()
    
    var body: some View {
        NavigationView {
            List(viewModel.cells) { cell in
                SettingCell(cellModel: cell)
            }
            .navigationTitle("Settings")
            .alert(isPresented: $viewModel.showAboutAlert) {
                Alert(title: Text("About App"),
                      message: Text("Andrey Bobr"),
                      dismissButton: .default(Text("OK")))
            }
        }
    }
}
