//
//  IRViewController.swift
//  Offloading-Client
//
//  Created by Girijah Nagarajah on 5/7/18.
//  Copyright © 2018 Core Sparker. All rights reserved.
//

import UIKit
import AVFoundation
import Vision
import BTE

class IRViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @IBOutlet weak var objectLabel: UILabel!
    let ipAddress: String! = nil
    let port: Int! = nil
    
    private let endPoint = "http://192.168.43.41:8181/recognizeImage"
    private let urlSession = URLSession.shared
    
    var switcher = 0   // 1 - Local Execution, 2 - Remote Execution, 0 - Not yet set
    
    // creates a new capture session
    let captureSession = AVCaptureSession()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCaptureSession()
        
        view.addSubview(objectLabel)
        
        BTE.shared.hello()
        
        let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeRight))
        swipeRightGesture.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRightGesture)
        
        let swipeTopGesture = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeTop))
        swipeTopGesture.direction = UISwipeGestureRecognizerDirection.up
        self.view.addGestureRecognizer(swipeTopGesture)
        
        if UserDefaults.standard.bool(forKey: MainViewController.kIS_OFFLOADING) == true {
            self.switcher = 2
        }
        else if UserDefaults.standard.bool(forKey: MainViewController.kIS_OFFLOADING) == false {
            self.switcher = 1
        }
    }
    
    @objc func respondToSwipeRight(gesture: UIGestureRecognizer) {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let controller = storyboard.instantiateViewController(withIdentifier: "Settings")
//        self.present(controller, animated: true, completion: nil)
        captureSession.stopRunning()
        performSegue(withIdentifier: "showMain", sender: nil)
    }
    
    @objc func respondToSwipeTop(gesture: UIGestureRecognizer) {
//                let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                let controller = storyboard.instantiateViewController(withIdentifier: "Detail")
//                self.present(controller, animated: true, completion: nil)
        
        performSegue(withIdentifier: "showDetail", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let mainViewController = segue.destination as! MainViewController
//            mainViewController.
//            print("")
    }
    
    func setupCaptureSession() {
        
        // search for available capture devices
        let availableDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back).devices
        
        // get capture device, add device input to capture session
        do {
            if let captureDevice = availableDevices.first {
                captureSession.addInput(try AVCaptureDeviceInput(device: captureDevice))
            }
        } catch {
            print(error.localizedDescription)
        }
        
        // setup output, add output to capture session
        let captureOutput = AVCaptureVideoDataOutput()
        captureSession.addOutput(captureOutput)
        
        captureOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.frame
        view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
    }
    
    // called everytime a frame is captured
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        if switcher == 1 {
            
            guard let model = try? VNCoreMLModel(for: Resnet50().model) else { return }
            let request = VNCoreMLRequest(model: model) { (finishedRequest, error) in
                guard let results = finishedRequest.results as? [VNClassificationObservation] else { return }
                guard let Observation = results.first else { return }
                
                DispatchQueue.main.async(execute: {
                    self.objectLabel.text = "\(Observation.identifier)"
                })
            }
            guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
            
            // executes request
            try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
            
        }
        else if switcher == 2 {
//            var stringSampleBuffer = ""
//
//            do {
//
//                // Object to JSON data
//                let jsonData = try JSONSerialization.data(withJSONObject: sampleBuffer, options: JSONSerialization.WritingOptions.prettyPrinted)
//
//                print("This is JSON data: ", jsonData)
//
//                // JSON data to JSON string
//                if let jsonString = String(data: jsonData, encoding: String.Encoding.utf8) {
//                    stringSampleBuffer = jsonString
//                    //socket.send(jsonString) // pass into a dictionary
//                } else {
//                    print("Couldn't create json string")
//                }
//
//            } catch let error {
//                print("Couldn't create json data: \(error)")
//            }
//
//            print( "Is sample buffer a valid json object: ", JSONSerialization.isValidJSONObject(sampleBuffer) )
//
//            let parameters = ["bufferParameter" : stringSampleBuffer]
//
//            guard let urlToExecute = URL(string: endPoint) else {
//                return
//            }
//
//            var webRequest = URLRequest(url: urlToExecute)
//            webRequest.httpMethod = "POST"
//            webRequest.addValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-type")
//
//            let urlParams =  parameters.compactMap {
//                (key, value) -> String? in "\(key)=\(value)"
//                }.joined(separator: "&")
//
//            webRequest.httpBody = urlParams.data(using: .utf8, allowLossyConversion: true)
//
//            let dataTask = urlSession.dataTask(with: webRequest) {
//                (data, response, error) in
//
//                print("Response received from the server")
//
//                guard let data = data, let _ = response, error == nil else {
//                    return
//                }
//
//                do {
//                    let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
//                    guard let object = jsonResponse?["recognizedImage"] else {
//                        return
//                    }
//
//                    DispatchQueue.main.async {[unowned self] in
//                        self.objectLabel.text = "\(object)"
//
//                    }
//                }
//                catch {
//                    print (error.localizedDescription)
//                }
//            }
//
//            dataTask.resume()
        }
        else {
            // pop up undefined error
            self.popUpTaskExecutionUndefinedErrorMessage()
        }
    }
    
    func popUpTaskExecutionUndefinedErrorMessage() {
        let alertController = UIAlertController(title: "Task Execution", message: "Selection undefined!", preferredStyle: .alert)
        let cancelAction = UIAlertAction.init(title: "Ok", style: .default, handler: { (UIAlertAction) in
            print("Selection undefined!")
        })
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
}
