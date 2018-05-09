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
    var ipAddress: String = ""
    var port: String = ""
    
    private let kIR_ENDPOINT = "/recognizeImage"
    var endPoint: String = ""
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
        
        setSwicher()
        
        if UserDefaults.standard.value(forKey: InternetSettingsViewController.kIP_ADDRESS) != nil && UserDefaults.standard.value(forKey: InternetSettingsViewController.kPORT) != nil {
            self.ipAddress = String(describing: UserDefaults.standard.value(forKey: InternetSettingsViewController.kIP_ADDRESS)!)
            
            self.port = String(describing: UserDefaults.standard.value(forKey: InternetSettingsViewController.kPORT)!)
            
            endPoint = "http://\(ipAddress):\(port)\(kIR_ENDPOINT)"
            
            print("The Image Recognition End point : ", endPoint)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setSwicher()
        startRunningCaptureSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        stopRunningCaptureSession()
    }
    
    @objc func respondToSwipeRight(gesture: UIGestureRecognizer) {
        performSegue(withIdentifier: "showMain", sender: nil)
    }
    
    @objc func respondToSwipeTop(gesture: UIGestureRecognizer) {
        performSegue(withIdentifier: "showDetail", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   
    }
    
    func setSwicher() {
        
        if UserDefaults.standard.bool(forKey: MainViewController.kIS_OFFLOADING) == true {
            self.switcher = 2
        }
        else if UserDefaults.standard.bool(forKey: MainViewController.kIS_OFFLOADING) == false {
            self.switcher = 1
        }
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
        
    }
    
    func startRunningCaptureSession() {
        //check decision is remote
            // check remote is set
        if switcher == 2 {

            if  InternetSettingsViewController.isIPAddressCorrect {
                captureSession.startRunning()
            }
            else {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "Internet") as! InternetSettingsViewController
                controller.cameFrom = 2
                self.present(controller, animated: true, completion: nil)
            }
        }
        else if switcher == 1 {
            captureSession.startRunning()
        }
    }
    
    func stopRunningCaptureSession() {
         captureSession.stopRunning()
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
            print("still capturing ...")
            let stringSampleBuffer = "\(sampleBuffer)"
            
            let parameters = ["bufferParameter" : stringSampleBuffer]
            
            guard let urlToExecute = URL(string: endPoint) else {
                return
            }
            
            var webRequest = URLRequest(url: urlToExecute)
            webRequest.httpMethod = "POST"
            webRequest.addValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-type")
            
            let urlParams =  parameters.compactMap {
                (key, value) -> String? in "\(key)=\(value)"
                }.joined(separator: "&")
            
            webRequest.httpBody = urlParams.data(using: .utf8, allowLossyConversion: true)
            
            let dataTask = urlSession.dataTask(with: webRequest) {
                (data, response, error) in
                
                print("Response received from the server")
                
                guard let data = data, let _ = response, error == nil else {
                    return
                }
                
                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    guard let object = jsonResponse?["recognizedImage"] as? String else {
                        return
                    }
                    
                    DispatchQueue.main.async {[unowned self] in
                        self.objectLabel.text = "\(object)"
                        print("Identified object is : ", object)
                    }
                }
                catch {
                    print (error.localizedDescription)
                }
            }
            
            dataTask.resume()
        }
        else {
            // pop up undefined error
            self.popUpTaskExecutionUndefinedErrorMessage()
        }
    }
    
    func popUpTaskExecutionUndefinedErrorMessage() {
        let alertController = UIAlertController(title: "Task Execution", message: "Selection undefined!", preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Ok", style: .default, handler: { (UIAlertAction) in
            print("Selection undefined!")
        })
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func popUpConnectToRemote() {
        let alertController = UIAlertController(title: "Remote Connection", message: "Please enter remote address.", preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Ok", style: .default, handler: { (UIAlertAction) in
            print("Remote connection set up requested!")
        })
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
}
