//
//  PostReview.swift
//  PracticaBoot4
//
//  Created by Juan Antonio Martin Noguera on 23/03/2017.
//  Copyright © 2017 COM. All rights reserved.
//

import UIKit
import Firebase


class PostReview: UIViewController {

    @IBOutlet weak var rateSlider: UISlider!
    @IBOutlet weak var imagePost: UIImageView!
    @IBOutlet weak var postTxt: UITextField!
    @IBOutlet weak var titleTxt: UITextField!
    @IBOutlet weak var progressView: UIProgressView!
    
    let storage = Storage.storage()
    var taskDownload: StorageDownloadTask?
    
    var post: Posts?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.synchronizeViewWithModel()
    }
    
    
    private func synchronizeViewWithModel() {
        guard let post = self.post else { return }
        
        self.postTxt.text = post.description
        self.titleTxt.text = post.title
        self.downloadObject(post.photo)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func rateAction(_ sender: Any) {
        print("\((sender as! UISlider).value)")
    }

    @IBAction func ratePost(_ sender: Any) {
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.taskDownload?.removeAllObservers()
    }
    
    // MARK: - Descarga
    
    private func downloadObject(_ photoString: String) {
        
        let storageRef = self.storage.reference(forURL: photoString)
        
//        let fileRef = storageRef.child("2D86057C-42CC-4CB7-9760-D488F3C61D70.jpg")
        self.taskDownload = storageRef.getData(maxSize: 1 * 1024 * 1024) { (data, error) in
            if error != nil {
                print("Error en descarga de la imagen.")
                return
            }
            
            if data != nil {
                let image = UIImage(data: data!)
                DispatchQueue.main.async {
                    self.imagePost.image = image
                }
            }
        }
        
        taskDownload?.observe(.progress) { (snapshot) in
            let percentComplete = 100.0 * Double((snapshot.progress?.completedUnitCount)!) / Double((snapshot.progress?.totalUnitCount)!)
            
            self.progressView.progress = Float(percentComplete)
        }
        
        taskDownload?.observe(.success) { (snapshot) in
            self.progressView.progress = 0.0
        }
    }

}
























