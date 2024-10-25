//
//  MediaPicker.swift
//  Lifferent
//
//  Created by sumit sharma on 03/03/21.
//

import Foundation
import UIKit
import MobileCoreServices


class MediaPicker: NSObject { //Inherit NSObject
    enum MediaType {
        case image
        case video
        case all
    }
    struct Constants {
        static let camera = "Camera".localized()
        static let gallery = "Gallery".localized()
        static let video = "Video"
        static let file = "File"
        static let cancel = "Cancel".localized()
        static let documentTypes = ["com.microsoft.word.doc", "public.data", "org.openxmlformats.wordprocessingml.document", kUTTypePDF as String] //Use for specify type you need to pickup
    }
    
    static let shared: MediaPicker = MediaPicker() //Singleton Pattern
    fileprivate var currentViewController: UIViewController!
    var imagePickerBlock: ((_ image: UIImage) -> Void)?
    var videoPickerBlock: ((_ url: URL?,_ data: Data?) -> Void)?
    var filePickerBlock: ((_ url: URL) -> Void)?
    
    fileprivate func imageFromcamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let pickerController = UIImagePickerController()
            pickerController.delegate = self
            pickerController.sourceType = .camera
            pickerController.allowsEditing = true
            DispatchQueue.main.async {
                self.currentViewController.present(pickerController, animated: true,   completion: nil)
            }
        }
    }
    
    fileprivate func photoFromLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let pickerController = UIImagePickerController()
            pickerController.delegate = self
            pickerController.sourceType = .photoLibrary
            pickerController.allowsEditing = true
            DispatchQueue.main.async {
                self.currentViewController.present(pickerController, animated: true,   completion: nil)
            }
        }
    }
    
    fileprivate func videoFromCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let pickerController = UIImagePickerController()
            pickerController.delegate = self
            pickerController.sourceType = .camera
            pickerController.allowsEditing = true
            pickerController.mediaTypes = [kUTTypeMovie as String, kUTTypeVideo as String]
            DispatchQueue.main.async {
                self.currentViewController.present(pickerController, animated: true,   completion: nil)
            }
            //            self.pickerController.mediaTypes = ["public.movie"]
            //            self.pickerController.videoQuality = .typeMedium
        }
    }
    fileprivate func videoFromLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let pickerController = UIImagePickerController()
            pickerController.delegate = self
            pickerController.sourceType = .photoLibrary
            pickerController.allowsEditing = true
            pickerController.mediaTypes = [kUTTypeMovie as String, kUTTypeVideo as String]
            DispatchQueue.main.async {
                self.currentViewController.present(pickerController, animated: true,   completion: nil)
            }
            //            self.pickerController.mediaTypes = ["public.movie"]
            //            self.pickerController.videoQuality = .typeMedium
        }
    }
    
    //    fileprivate func file() {
    //        let importMenuViewController = UIDocumentMenuViewController(documentTypes: Constants.documentTypes, in: .import)
    //        importMenuViewController.delegate = self
    //        importMenuViewController.modalPresentationStyle = .formSheet
    //        currentViewController.present(importMenuViewController, animated: true, completion: nil)
    //    }
    
    func showActionSheet(viewController: UIViewController, type: MediaType) {
        currentViewController = viewController
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let imagefromcamera = UIAlertAction(title: Constants.camera, style: .default, handler: { (action) -> Void in
            self.imageFromcamera()
        })
        let imagefromgallery = UIAlertAction(title: Constants.gallery, style: .default, handler: { (action) -> Void in
            self.photoFromLibrary()
        })
        let videoromcamera = UIAlertAction(title: Constants.camera, style: .default, handler: { (action) -> Void in
            self.videoFromCamera()
        })
        let videoromgallery = UIAlertAction(title: Constants.gallery, style: .default, handler: { (action) -> Void in
            self.videoFromLibrary()
        })
        
        //        let file = UIAlertAction(title: Constants.file, style: .default, handler: { (action) -> Void in
        //            self.file()
        //        })
        let cancel = UIAlertAction(title: Constants.cancel, style: .cancel, handler: nil)
        
        if type == .image{
            actionSheet.addAction(imagefromcamera)
            actionSheet.addAction(imagefromgallery)
        }else if type == .video {
            actionSheet.addAction(videoromcamera)
            actionSheet.addAction(videoromgallery)
        }else if type == .all {
            actionSheet.addAction(imagefromgallery)
            actionSheet.addAction(imagefromgallery)
            actionSheet.addAction(videoromcamera)
            actionSheet.addAction(videoromgallery)
            // actionSheet.addAction(file)
        }
        actionSheet.addAction(cancel)
        DispatchQueue.main.async {
            viewController.present(actionSheet, animated: true, completion: nil)
        }
        
    }
    
    func showActionSheetForGalleryOnly(viewController: UIViewController, type: MediaType) {
        currentViewController = viewController
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let imagefromgallery = UIAlertAction(title: Constants.gallery, style: .default, handler: { (action) -> Void in
            self.photoFromLibrary()
        })
        
        let cancel = UIAlertAction(title: Constants.cancel, style: .cancel, handler: nil)
        
        if type == .image{
            actionSheet.addAction(imagefromgallery)
        }
        actionSheet.addAction(cancel)
        DispatchQueue.main.async {
            viewController.present(actionSheet, animated: true, completion: nil)
        }
        
    }
}

extension MediaPicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        currentViewController.dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        currentViewController.dismiss(animated: true) {
            if let image = info[.editedImage] as? UIImage {
                self.imagePickerBlock?(image)
            }else{
                print("Something went wrong")
            }
            
            if let videoUrl = info[.mediaURL] as? URL {
                let data = try? Data(contentsOf: videoUrl)
                self.videoPickerBlock?(videoUrl,data) //return video url when not null
            }
            else{
                print("Something went wrong")
            }
        }
    }
    
    
}

////Receive File
//     MediaPicker.shared.filePickerBlock = { (file) -> Void in
//        self.file = file
//     }
//extension MediaPicker: UIDocumentMenuDelegate, UIDocumentPickerDelegate  {
//    func documentMenu(_ documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
//        documentPicker.delegate = self
//        currentViewController.present(documentPicker, animated: true, completion: nil)
//    }
//    func documentPicker(_ controller: UIDocumentPickerViewController,   didPickDocumentAt url: URL) {
//        filePickerBlock?(url) //return file url if you selected from drive.
//    }
//    func documentMenuWasCancelled(_ documentMenu: UIDocumentMenuViewController) {
//        currentViewController.dismiss(animated: true, completion: nil)
//    }
//}
