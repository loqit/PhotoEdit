//
//  CropView.swift
//  PhotoEdit
//
//  Created by Андрей Бобр on 3.06.24.
//

import SwiftUI

struct CropView: View {
    
    @State private var image: UIImage = UIImage(named: "test_pic")!
    
    @StateObject private var viewModel: CropViewModel = CropViewModel(maskSize: 100)
    
    var body: some View {
        let rotationGesture = RotationGesture()
            .onChanged { angle in
                viewModel.angle = angle
            }

        let magnificationGesture = MagnificationGesture()
            .onChanged { scale in
                viewModel.scale = scale
            }

        let dragGesture = DragGesture()
            .onChanged { value in
                viewModel.offset = CGSize(width: value.translation.width + viewModel.lastOffset.width,
                                    height: value.translation.height + viewModel.lastOffset.height)
            }
            .onEnded { value in
                viewModel.lastOffset = viewModel.offset
            }

        let combinedGesture = SimultaneousGesture(
            SimultaneousGesture(rotationGesture, magnificationGesture),
            dragGesture
        )
        
        VStack {
            ZStack {
                mainImage
                    .opacity(0.5)
                    .overlay {
                        GeometryReader { geometry in
                            Color.clear
                                .onAppear {
                                    viewModel.imageSizeInView = geometry.size
                                }
                        }
                    }
                mainImage
                    .mask {
                        Rectangle()
                            .frame(width: viewModel.maskSize * 2, height: viewModel.maskSize * 2)
                    }
                    .overlay {
                        Rectangle()
                            .stroke(lineWidth: 2)
                            .foregroundStyle(.yellow)
                            .frame(width: viewModel.maskSize * 2, height: viewModel.maskSize * 2)
                    }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .gesture(combinedGesture)
            Button (action : {
                cropImage()
            }) {
                Text("Crop Image")
                    .padding(.all, 10)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                    .padding(.top, 50)
            }
        }
    }
    
    private var mainImage: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .rotationEffect(viewModel.angle)
            .scaleEffect(viewModel.scale)
            .offset(viewModel.offset)
    }
    
    func cropImage() {
        var editableImage = image
        
        if let rotatedImage = viewModel.rotate(editableImage, viewModel.angle) {
            editableImage = rotatedImage
        }
        
        image = viewModel.crop(image: editableImage)!
     }
}
