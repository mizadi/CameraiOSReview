//
//  ViewController.swift
//  iOSReviewExam
//
//  Created by Adi Mizrahi on 03/06/2020.
//  Copyright © 2020 Tap.pm. All rights reserved.
//

import UIKit
import Kingfisher
import Photos
class MainViewController: UIViewController {
    
    @IBOutlet weak var ivPreview2: UIImageView!
    @IBOutlet weak var ivPreview1: UIImageView!
    @IBOutlet weak var capturePreviewView: UIView!
    @IBOutlet weak var ivMain: UIImageView!
    @IBOutlet weak var btnTakePicture: UIButton!
    let cameraController = CameraController()
    var previewOverlay: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ivMain.isHidden = true
        // Do any additional setup after loading the view.
        ApiHandler.sharedInstance.pullAssetsFromServer { (success) in
            if success {
                guard let url = URL(string: ImagesHolder.sharedInstance.images[0]) else {
                    return
                }
                guard let url2 = URL(string: ImagesHolder.sharedInstance.images[1]) else {
                    return
                }
                DispatchQueue.main.async {
                    self.preview1()
                    //self.ivMain.kf.setImage(with: url)
                    self.ivPreview1.kf.setImage(with: url)
                    self.ivPreview2.kf.setImage(with: url2)
                }
            }
        }
        configureCameraController()
        setButton()
    }
    
    func setButton() {
        btnTakePicture.addTarget(self, action: #selector(self.captureImage), for: .touchUpInside)
        let recorgPreview1 = UITapGestureRecognizer(target: self, action: #selector(self.preview1))
        ivPreview1.isUserInteractionEnabled = true
        ivPreview1.addGestureRecognizer(recorgPreview1)
        
        
        let recogPreview2 = UITapGestureRecognizer(target: self, action: #selector(preview2))
        ivPreview2.isUserInteractionEnabled = true
        ivPreview2.addGestureRecognizer(recogPreview2)
    }
    
    @objc func preview1() {
        guard let url = URL(string: ImagesHolder.sharedInstance.images[0]) else {
            return
        }
        ivPreview1.layer.borderColor = UIColor.blue.cgColor
        ivPreview1.layer.borderWidth = 2
        ivPreview2.layer.borderWidth = 0
        ivMain.kf.setImage(with: url)
        if let previewOverlay = self.previewOverlay {
            previewOverlay.kf.setImage(with: url)
        }
    }
    
    @objc func preview2() {
        guard let url = URL(string: ImagesHolder.sharedInstance.images[1]) else {
            return
        }
        ivPreview2.layer.borderColor = UIColor.blue.cgColor
        ivPreview2.layer.borderWidth = 2
        ivPreview1.layer.borderWidth = 0
        ivMain.kf.setImage(with: url)
        if let previewOverlay = self.previewOverlay {
            previewOverlay.kf.setImage(with: url)
        }
    }
    
    func configureCameraController() {
        cameraController.prepare {(error) in
            if let error = error {
                print(error)
            }
            try? self.cameraController.displayPreview(on: self.capturePreviewView)
            self.addOverlay()
        }
    }
    
    func addOverlay() {
        let view = UIView(frame: capturePreviewView.frame)
        view.backgroundColor = .clear
        let previewImage = UIImageView(frame: capturePreviewView.frame)
        previewImage.alpha = 0.3
        previewImage.contentMode = .scaleToFill
        view.addSubview(previewImage)
        previewOverlay = previewImage
        capturePreviewView.addSubview(view)
    }
    
    @objc func captureImage() {
        cameraController.captureImage {(image, error) in
            guard let image = image else {
                print(error ?? "Image capture error")
                return
            }
            
            UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
            image.draw(in: CGRect(origin: .zero, size: image.size))
            var newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            newImage = self.combineImages(newImage!, self.ivMain.image!)
            try? PHPhotoLibrary.shared().performChangesAndWait {
                PHAssetChangeRequest.creationRequestForAsset(from: newImage!)
            }
        }
    }
    
    func combineImages(_ topImage: UIImage, _ bottomImage: UIImage) -> UIImage {
        let size = CGSize(width: topImage.size.width, height: topImage.size.height)
        UIGraphicsBeginImageContext(size)
        
        let areaSize = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        bottomImage.draw(in: areaSize, blendMode: .normal, alpha: 1)
        
        topImage.draw(in: areaSize, blendMode: .multiply, alpha: 1)
        
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    
}

