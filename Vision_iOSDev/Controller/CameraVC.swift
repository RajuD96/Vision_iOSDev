//
//  ViewController.swift
//  Vision_iOSDev
//
//  Created by Raju Dhumne on 15/02/18.
//  Copyright © 2018 Raju Dhumne. All rights reserved.
//

import UIKit
import AVFoundation
import CoreML
import Vision

enum FlashState {
    case off
    case on
}

class CameraVC: UIViewController {
    
    var captureSession: AVCaptureSession!
    var cameraOutput: AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var photoData: Data?
    var flashControlState: FlashState = .off
    var speechSynthesizer = AVSpeechSynthesizer()

    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var confidenceLbl: UILabel!
    @IBOutlet weak var identificationLbl: UILabel!
    @IBOutlet weak var flashBtn: RoundedCornerButton!
    @IBOutlet weak var roundedCornerLbl: RoundedCornerView!
    @IBOutlet weak var capturedImageView: RoundedCornerImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        previewLayer.frame = cameraView.bounds
        speechSynthesizer.delegate = self
        spinner.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let tap = UITapGestureRecognizer(target: self, action: #selector (didTapCameraView))
        tap.numberOfTapsRequired = 1
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSession.Preset.hd1920x1080
        
        let backCamera = AVCaptureDevice.default(for: AVMediaType.video)
        do {
            let input = try AVCaptureDeviceInput(device: backCamera!)
            if captureSession.canAddInput(input) == true {
                captureSession.addInput(input)
            }
            cameraOutput = AVCapturePhotoOutput()
            
            if captureSession.canAddOutput(cameraOutput) == true {
                captureSession.addOutput(cameraOutput)
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer.videoGravity = AVLayerVideoGravity.resizeAspect
                previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
                cameraView.layer.addSublayer(previewLayer!)
                cameraView.addGestureRecognizer(tap)
                captureSession.startRunning()
            }
        }
        catch{
            debugPrint(error)
        }
    }
    
    @objc func didTapCameraView() {
        self.cameraView.isUserInteractionEnabled = false
        self.spinner.isHidden = false
        self.spinner.startAnimating()
        let settings = AVCapturePhotoSettings()
        settings.previewPhotoFormat = settings.embeddedThumbnailPhotoFormat
        
        if flashControlState == .off {
            settings.flashMode = .off
        }else {
            settings.flashMode = .on
        }
        cameraOutput.capturePhoto(with: settings, delegate: self)
        
    }
    
    func resultsMethod(request: VNRequest, error: Error?){
        guard let results = request.results as? [VNClassificationObservation] else { return }
        for classification in results {
            if classification.confidence < 0.5 {
                let unkownObject = "I'm not sure what it is. please try again."
                self.identificationLbl.text = unkownObject
                synthesizeSpeech(forString: unkownObject)
                self.confidenceLbl.text = ""
                break
            }
            else {
                
                let identification = classification.identifier
                let confidenc = Int(classification.confidence * 100)
                self.identificationLbl.text = identification
                self.confidenceLbl.text = "CONFIDENCE:\(confidenc)%"
                let completeSentence = "This look like a \(identification) and I'm \(confidenc) percent sure. "
                synthesizeSpeech(forString: completeSentence)
                break
            }
        }
    }
    
    func synthesizeSpeech(forString string: String) {
        let speechUtterance = AVSpeechUtterance(string: string)
        speechSynthesizer.speak(speechUtterance)
        
    }
    
    @IBAction func flashBtnWasPressed(_ sender: Any) {
        
        switch flashControlState {
        case .off:
            flashBtn.setTitle("FLASH ON", for: .normal)
            flashControlState = .on
        case.on:
            flashBtn.setTitle("FLASH OFF", for: .normal)
            flashControlState = .off
        }
    }
}

extension CameraVC: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            debugPrint(error)
        }else {
            photoData = photo.fileDataRepresentation()
            do {
                let model = try VNCoreMLModel(for: SqueezeNet().model)
                let request = VNCoreMLRequest(model: model, completionHandler: resultsMethod)
                let handler = VNImageRequestHandler(data: photoData!)
                try handler.perform([request])
            } catch {
                debugPrint(error)
            }
            
            let image = UIImage(data: photoData!)
            self.capturedImageView.image = image
        }
    }
}

extension CameraVC: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        
        self.cameraView.isUserInteractionEnabled = true
        self.spinner.isHidden = true
        self.spinner.stopAnimating()
    }
    
}











