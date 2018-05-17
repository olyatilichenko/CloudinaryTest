//
//  GalleryCVCCollectionViewController.swift
//  CloudinaryTest
//
//  Created by Olga on 5/14/18.
//  Copyright © 2018 Olga. All rights reserved.
//

import UIKit
import Cloudinary
import MobileCoreServices
import Firebase
import Kingfisher
import AVKit
import AVFoundation

private let reuseIdentifier = "Cell"

class GalleryCVC: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    var photos = [Photo]()
    
    var cld = CLDCloudinary(configuration: CLDConfiguration(cloudName: AppDelegate.cloudName, secure: true))
    
    var refPhotos: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        refPhotos = Database.database().reference().child("photos")

        refPhotos.observe(DataEventType.value, with: { snapshot in
            if snapshot.childrenCount > 0 {
                
                var newPhotos: [Photo] = []
                
                for photos in snapshot.children.allObjects as! [DataSnapshot] {
                    let photoObject = photos.value as? [String: AnyObject]
                    let url = photoObject?["secure_url"]
                    let type = photoObject?["resource_type"]
                    
                    let photo = Photo(url: url as! String, type: type as! String)
                    
                    newPhotos.append(photo!)
                }
                
                self.photos = newPhotos
                self.collectionView?.reloadData()
            }
        })

    }
    
    @IBAction func add(_ sender: Any) {
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: {(alert: UIAlertAction!) -> Void in self.camera()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Gallery", style: .default, handler: {(alert: UIAlertAction!) -> Void in self.photoLibrary()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return photos.count
    }
    

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoCollectionViewCell
        
        var photo: Photo
        photo = photos[indexPath.item]
        let urlString: String
        let type = photo.type
        if type == "video"{
            urlString = photo.url.replacingOccurrences(of: "mov", with: "jpg")
    
        } else {
            urlString = photo.url
        }
        
        let url = URL(string: urlString)
        
        cell.imageView.kf.indicatorType = .activity
        cell.imageView.kf.setImage(with: url)
        
        /*if type == "video" {
            let image = UIImage(imageLiteralResourceName: "play")
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: cell.bounds.width, height: cell.bounds.height))
            imageView.image = image
            cell.imageView.addSubview(imageView)
        }*/
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var photo: Photo
        photo = photos[indexPath.item]
        let urlString: String
        if photo.type == "video"{
            urlString = photo.url.replacingOccurrences(of: "jpg", with: "mov")
            let url = URL(string: urlString)
            
            let player = AVPlayer(url: url!)
            let controller = AVPlayerViewController()
            controller.player = player
            
            present(controller, animated: true) {
                player.play()
            }
        } else {
            urlString = photo.url
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let data = UIImageJPEGRepresentation(selectedImage, 1.0)
            cld.createUploader().upload(data: data!, uploadPreset: "olyaTestPreset").response { (response, error) in
                if let result = response?.resultJson {
                    self.addPhoto(result)
                }
            }
        }
        
        if let videoUrl = info[UIImagePickerControllerMediaURL] as? NSURL {
            print(videoUrl)
            let params = CLDUploadRequestParams()
                params.setResourceType("video")
            cld.createUploader().uploadLarge(url: videoUrl as URL, uploadPreset: "olyaTestPreset", params: params, progress: nil).response( { response, error in
                print(response?.resultJson as Any)
                if let result = response?.resultJson {
                    self.addPhoto(result)
                }
            })
        }
        dismiss(animated: true, completion: nil)
    }
    
    func camera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self;
            myPickerController.sourceType = .camera
            myPickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
            self.present(myPickerController, animated: true, completion: nil)
        }
        else{
            //no camera available
            let alert = UIAlertController(title: "Error", message: "There is no camera available", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: {(alertAction)in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func photoLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self;
            myPickerController.sourceType = .photoLibrary
            self.present(myPickerController, animated: true, completion: nil)
        }
    }
    
    func addPhoto(_ json: [String: AnyObject]) {
        let key = refPhotos.childByAutoId().key
        
        var photo = json
        photo["id"] = key as AnyObject
        refPhotos.child(key).setValue(photo)
    }
}
