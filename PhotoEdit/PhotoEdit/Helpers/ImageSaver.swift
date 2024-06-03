//
//  ImageSaver.swift
//  PhotoEdit
//
//  Created by Андрей Бобр on 3.06.24.
//

import UIKit

class ImageSaver: NSObject {
    
    private var completionHandler: (Result<Void, Error>) -> Void
    
    init(completionHandler: @escaping (Result<Void, Error>) -> Void) {
        self.completionHandler = completionHandler
    }
    
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }

    @objc private func saveCompleted(_ image: UIImage, 
                             didFinishSavingWithError error: Error?,
                             contextInfo: UnsafeRawPointer) {
        if let error {
            completionHandler(.failure(error))
        } else {
            completionHandler(.success(()))
        }
    }
}
