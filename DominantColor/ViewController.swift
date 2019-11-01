//
//  ViewController.swift
//  DominantColor
//
//  Created by Ahmed Khalaf on 10/31/19.
//  Copyright © 2019 Ahmed Khalaf. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var dominantColorImageView: UIImageView!
    
    private func setAvatarImage(to image: UIImage) {
        avatarImageView.set(image: image, animated: true)
    }
    
    private let onePxSize = CGSize(width: 1 / UIScreen.main.scale, height: 1 / UIScreen.main.scale)
    private lazy var renderer = UIGraphicsImageRenderer(size: onePxSize)
    
    private func setDominantColorImage(from image: UIImage) {
        let dominantColorImage = renderer.image { (_) in
            image.draw(in: CGRect(origin: .zero, size: onePxSize))
        }
        
        dominantColorImageView.set(image: dominantColorImage, animated: true)
    }
    
    private lazy var imageURLs: [URL] = {
        let imagesDirURL = Bundle.main.resourceURL!.appendingPathComponent("images", isDirectory: true)
        
        return try! FileManager.default.contentsOfDirectory(at: imagesDirURL, includingPropertiesForKeys: nil)
        
    }()
    
    private var index = 0 {
        didSet {
            let image = downsampleImage(at: imageURLs[circular: index], maxSize: avatarImageView.bounds.maxDimension)
            setAvatarImage(to: image)
            setDominantColorImage(from: image)
        }
    }
    private func startTimer() {
        index = 0
        Timer.scheduledTimer(withTimeInterval: 4, repeats: true) { [weak self] (_) in
            guard let self = self else { return }
            
            self.index += 1
        }
    }
    
    // Credits: https://www.swiftjectivec.com/optimizing-images/
    func downsampleImage(at url: URL, maxSize: CGFloat) -> UIImage
    {
        let sourceOptions = [kCGImageSourceShouldCache:false] as CFDictionary
        let source = CGImageSourceCreateWithURL(url as CFURL, sourceOptions)!
        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways:true,
            kCGImageSourceThumbnailMaxPixelSize:maxSize,
            kCGImageSourceShouldCacheImmediately:true,
            kCGImageSourceCreateThumbnailWithTransform:true,
        ] as CFDictionary
        
        let downsampledImage = CGImageSourceCreateThumbnailAtIndex(source, 0, downsampleOptions)!
        
        return UIImage(cgImage: downsampledImage)
    }

    // MARK: Overrides
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startTimer()
    }
}

fileprivate extension UIImageView {
    func set(image: UIImage, animated: Bool = false) {
        func setImage() {
            self.image = image
        }
        
        if animated {
            UIView.transition(with: self, duration: 1, options: .transitionCrossDissolve, animations: {
                setImage()
            })
        } else {
            setImage()
        }
    }
}

fileprivate extension Array {
    subscript(circular index: Index) -> Element {
        return self[index % count]
    }
}

fileprivate extension CGSize {
    var max: CGFloat {
        return Swift.max(width, height)
    }
}

fileprivate extension CGRect {
    var maxDimension: CGFloat {
        return size.max
    }
}
