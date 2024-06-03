//
//  CropView.swift
//  PhotoEdit
//
//  Created by Андрей Бобр on 3.06.24.
//

import SwiftUI

struct CropView: View {
    
    @State private var image: UIImage = UIImage(named: "test_pic")!
    @State private var showingImagePicker = false
    @StateObject private var viewModel: CropViewModel = CropViewModel(maskSize: 100)
    
    @State var saveStatusMessage: String = ""
    @State var showSaveAlert: Bool = false
    
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
            .gesture(combinedGesture)
            Button {
                cropImage()
            } label: {
                Text("Crop Image")
                    .padding(.all, 10)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                    .padding(.top, 50)
            }
            HStack {
                Button {
                    showingImagePicker = true
                } label: {
                    Text("Upload Image")
                        .padding(.all, 10)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }        
                .sheet(isPresented: $showingImagePicker) {
                    ImagePicker(image: $image)
                }
                
                Button {
                    saveImage()
                } label: {
                    Text("Save Image")
                        .padding(.all, 10)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
                .alert(isPresented: $showSaveAlert) {
                    Alert(title: Text("Save Image"),
                          message: Text(saveStatusMessage),
                          dismissButton: .default(Text("OK")))
                }
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
    
    // MARK: - Utils methods
    
    private func cropImage() {
        var editableImage = image
        
        if let rotatedImage = viewModel.rotate(editableImage, viewModel.angle) {
            editableImage = rotatedImage
        }
        
        image = viewModel.crop(image: editableImage)!
    }
    
    private func saveImage() {
        let imageSaver = ImageSaver { result in
            switch result {
            case .success:
                saveStatusMessage = "Your cropped image has been saved to your photos."
            case .failure(let error):
                saveStatusMessage = "Save error: \(error.localizedDescription)"
            }
            showSaveAlert = true
        }
        imageSaver.writeToPhotoAlbum(image: image)
    }
}
