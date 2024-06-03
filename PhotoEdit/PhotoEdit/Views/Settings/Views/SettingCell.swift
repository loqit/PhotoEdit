//
//  SettingCell.swift
//  PhotoEdit
//
//  Created by Андрей Бобр on 3.06.24.
//

import SwiftUI

struct SettingCell: View {
    var cellModel: CellModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(cellModel.title)
                .font(.headline)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .onTapGesture {
            cellModel.action()
        }
    }
}

struct CellModel: Identifiable {
    let id = UUID()
    var title: String
    var action: () -> Void
}
