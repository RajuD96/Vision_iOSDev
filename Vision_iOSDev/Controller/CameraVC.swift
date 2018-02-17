//
//  ViewController.swift
//  Vision_iOSDev
//
//  Created by Raju Dhumne on 15/02/18.
//  Copyright © 2018 Raju Dhumne. All rights reserved.
//

import UIKit

class CameraVC: UIViewController {

    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var confidenceLbl: UILabel!
    
    @IBOutlet weak var identificationLbl: UILabel!
    @IBOutlet weak var flashBtn: RoundedCornerButton!
    
  
    @IBOutlet weak var roundedCornerLbl: RoundedCornerView!
    
    
    @IBOutlet weak var capturedImageView: RoundedCornerImage!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }

   

}

