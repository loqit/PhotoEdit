//
//  SettingsViewModel.swift
//  PhotoEdit
//
//  Created by Андрей Бобр on 3.06.24.
//

import SwiftUI

final class SettingsViewModel: ObservableObject {
    
    @Published var cells: [CellModel] = []
    @Published var showAboutAlert: Bool = false
    
    init() {
        loadCells()
    }
    
    func loadCells() {
        cells = [
            CellModel(title: "About",
                      action: { [weak self] in
                          print("Cell 1 tapped")
                          self?.handleAbout()
                      })
        ]
    }
    
    private func handleAbout() {
        showAboutAlert = true
    }
}
