//
//  CropViewModel.swift
//  PhotoEdit
//
//  Created by Андрей Бобр on 2.06.24.
//

import UIKit
import SwiftUI

final class CropViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published var maskSize: CGFloat
    @Published var scale: CGFloat = 1.0
    @Published var offset: CGSize = .zero
    @Published var lastOffset: CGSize = .zero
    @Published var angle: Angle = .zero
    
    var backupImage: UIImage?
    
    var imageSizeInView: CGSize = .zero {
        didSet {
            maskSize = min(maskSize, min(imageSizeInView.width, imageSizeInView.height) / 2)
        }
    }
    
    // MARK: - Init
    
    init(maskSize: CGFloat) {
        self.maskSize = maskSize
    }

    func crop(image: UIImage) -> UIImage? {
        guard let orientedImage = image.correctlyOriented else {
            return nil
        }

        let cropRect = calculateCropRect(orientedImage)

        guard let cgImage = orientedImage.cgImage,
              let result = cgImage.cropping(to: cropRect) else {
            return nil
        }

        return UIImage(cgImage: result)
    }

    private func calculateCropRect(_ orientedImage: UIImage) -> CGRect {
        let factor = min(
            (orientedImage.size.width / imageSizeInView.width),
            (orientedImage.size.height / imageSizeInView.height)
        )
        let centerInOriginalImage = CGPoint(x: orientedImage.size.width / 2, y: orientedImage.size.height / 2)
        let cropRadiusInOriginalImage = (maskSize * factor) / scale

        let offsetX = offset.width * factor
        let offsetY = offset.height * factor
        
        let cropRectX = (centerInOriginalImage.x - cropRadiusInOriginalImage) - (offsetX / scale)
        let cropRectY = (centerInOriginalImage.y - cropRadiusInOriginalImage) - (offsetY / scale)
        let cropRectCoordinate = CGPoint(x: cropRectX, y: cropRectY)
        let cropRectDimension = cropRadiusInOriginalImage * 2
        
        let cropRect = CGRect(
            x: cropRectCoordinate.x,
            y: cropRectCoordinate.y,
            width: cropRectDimension,
            height: cropRectDimension
        )
        
        return cropRect
    }
    
    func rotate(_ image: UIImage, _ angle: Angle) -> UIImage? {
        guard let orientedImage = image.correctlyOriented,
              let cgImage = orientedImage.cgImage else {
            return nil
        }
        
        let ciImage = CIImage(cgImage: cgImage)
        
        let filter = CIFilter.straightenFilter(image: ciImage, radians: angle.radians)
        guard let output = filter?.outputImage else {
            return nil
        }

        let context = CIContext()
        guard let result = context.createCGImage(output, from: output.extent) else {
            return nil
        }
        
        return UIImage(cgImage: result)
    }
    
    func applyMonochromeFilter(to image: UIImage) -> UIImage? {
        guard let currentCGImage = image.cgImage else { return nil }
        let currentCIImage = CIImage(cgImage: currentCGImage)

        let filter = CIFilter(name: "CIColorMonochrome")
        filter?.setValue(currentCIImage, forKey: "inputImage")
        filter?.setValue(CIColor(red: 0.7, green: 0.7, blue: 0.7), forKey: "inputColor")
        filter?.setValue(1.0, forKey: "inputIntensity")
        
        guard let outputImage = filter?.outputImage else { return nil }
        
        let context = CIContext()
        guard let cgimg = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }
        
        return UIImage(cgImage: cgimg)
    }
}

private extension UIImage {
    var correctlyOriented: UIImage? {
        if imageOrientation == .up { return self }

        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return normalizedImage
    }
}

private extension CIFilter {
    static func straightenFilter(image: CIImage, radians: Double) -> CIFilter? {
        let angle: Double = radians != 0 ? -radians : 0
        guard let filter = CIFilter(name: "CIStraightenFilter") else {
            return nil
        }
        filter.setDefaults()
        filter.setValue(image, forKey: kCIInputImageKey)
        filter.setValue(angle, forKey: kCIInputAngleKey)
        return filter
    }
}
