//
//  NewPostController.swift
//  PracticaBoot4
//
//  Created by Juan Antonio Martin Noguera on 23/03/2017.
//  Copyright © 2017 COM. All rights reserved.
//

import UIKit
import Firebase


class NewPostController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var titlePostTxt: UITextField!
    @IBOutlet weak var textPostTxt: UITextField!
    @IBOutlet weak var imagePost: UIImageView!
    @IBOutlet weak var progressView: UIProgressView!
    
    var isReadyToPublish: Bool = false
    var imageCaptured: UIImage! {
        didSet {
            imagePost.image = imageCaptured
        }
    }
    
    let postsReference = Database.database().reference(withPath: "posts")
    let storageRef = Storage.storage().reference().child("imgPosts")
    var uploadTask: StorageUploadTask?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func takePhoto(_ sender: Any) {
        self.present(pushAlertCameraLibrary(), animated: true, completion: nil)
    }
    @IBAction func publishAction(_ sender: Any) {
        isReadyToPublish = (sender as! UISwitch).isOn
    }

    @IBAction func savePostInCloud(_ sender: Any) {
        var newPost: [String: Any] = ["title" : self.titlePostTxt.text ?? "",
                                      "description" : self.textPostTxt.text ?? "",
                                      "owner" : Auth.auth().currentUser?.uid ?? "none"]
        
        // Primero subimos el objeto
        self.uploadFrom(buffer: UIImageJPEGRepresentation(self.imageCaptured, 0.5)!) { (url) in
            if url != nil {
                newPost["photo"] = url.absoluteString
            }
            let newPostFb = self.postsReference.childByAutoId()
            newPostFb.setValue(newPost)
        }
    }
    
    
    @IBAction func newPostInFB(_ sender: Any) {
        let newPost: [String: Any] = ["title" : self.titlePostTxt.text ?? "",
                                      "description" : self.textPostTxt.text ?? ""]
        
        let newPostFb = postsReference.childByAutoId()
        newPostFb.setValue(newPost)
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - funciones para la camara
    internal func pushAlertCameraLibrary() -> UIAlertController {
        let actionSheet = UIAlertController(title: NSLocalizedString("Selecciona la fuente de la imagen", comment: ""), message: NSLocalizedString("", comment: ""), preferredStyle: .actionSheet)
        
        let libraryBtn = UIAlertAction(title: NSLocalizedString("Ussar la libreria", comment: ""), style: .default) { (action) in
            self.takePictureFromCameraOrLibrary(.photoLibrary)
            
        }
        let cameraBtn = UIAlertAction(title: NSLocalizedString("Usar la camara", comment: ""), style: .default) { (action) in
            self.takePictureFromCameraOrLibrary(.camera)
            
        }
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        
        actionSheet.addAction(libraryBtn)
        actionSheet.addAction(cameraBtn)
        actionSheet.addAction(cancel)
        
        return actionSheet
    }
    
    internal func takePictureFromCameraOrLibrary(_ source: UIImagePickerControllerSourceType) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        switch source {
        case .camera:
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
                picker.sourceType = UIImagePickerControllerSourceType.camera
            } else {
                return
            }
        case .photoLibrary:
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        case .savedPhotosAlbum:
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        }
        
        self.present(picker, animated: true, completion: nil)
    }
    
    
    // MARK: - Storage Firebase methods
    
    private func uploadFrom(buffer: Data, complete: @escaping (_: URL!) -> Void) {
//        let storage = Storage.storage()
//        let storageRef = storage.reference().child("imgPosts")
        
        let fileRef = storageRef.child(UUID().uuidString + ".jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        uploadTask = fileRef.putData(buffer, metadata: metadata) { (metaEnd, error) in
            if error != nil {
                print("Error en la subida de imagen.")
            }
        }
        
        uploadTask?.observe(.success, handler: { (snapshot) in
            print("Parece que la imagen se ha subido bien.")
            self.progressView.progress = 0.0
            self.deleteSuccessOberserver()
            
            fileRef.downloadURL(completion: { (url, error) in
                if error != nil {
                    print("Error en la generación de URL de la imagen")
                } else {
                    print(url?.absoluteString ?? "VACÍA")
                    complete(url)
                }
            })
            
        })
        
        uploadTask?.observe(.progress, handler: { (snapshot) in
            print(snapshot.progress?.completedUnitCount ?? "sin datos")
            let percentComplete = 100.0 * Double((snapshot.progress?.completedUnitCount)!) / Double((snapshot.progress?.totalUnitCount)!)
            
            self.progressView.progress = Float(percentComplete)
        })
    }
    
    private func deleteSuccessOberserver() {
        
    }
    

}

// MARK: - Delegado del imagepicker
extension NewPostController {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imageCaptured = (info[UIImagePickerControllerOriginalImage] as? UIImage)!
        self.dismiss(animated: false, completion: {
        })
    }
    
}












