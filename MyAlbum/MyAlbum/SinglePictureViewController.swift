//
//  SinglePictureViewController.swift
//  MyAlbum
//
//  Created by hbd on 2022/12/14.
//

import CoreMedia
import CoreML
import UIKit
import Vision


func buffer(from image: UIImage) -> CVPixelBuffer? {
    let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
    var pixelBuffer : CVPixelBuffer?
    let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(image.size.width), Int(image.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
    guard (status == kCVReturnSuccess) else {
    return nil
    }

    CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
    let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)

    let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
    let context = CGContext(data: pixelData, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)

    context?.translateBy(x: 0, y: image.size.height)
    context?.scaleBy(x: 1.0, y: -1.0)

    UIGraphicsPushContext(context!)
    image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
    UIGraphicsPopContext()
    CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))

    return pixelBuffer
}


class SinglePictureViewController: UIViewController {

    @IBOutlet weak var videoPreview: UIImageView!
    
    var passedimg = UIImageView()
    
    var currentBuffer: CVPixelBuffer?
    
    lazy var visionModel: VNCoreMLModel = {
        do {
            let coreMLWrapper = try SnackDetector(configuration: MLModelConfiguration())
            let visionModel = try VNCoreMLModel(for: coreMLWrapper.model)
            
            if #available(iOS 13.0, *) {
                visionModel.inputImageFeatureName = "image"
                visionModel.featureProvider = try MLDictionaryFeatureProvider(dictionary: [
                    "iouThreshold": MLFeatureValue(double: 0.45),
                    "confidenceThreshold": MLFeatureValue(double: 0.25),
                ])
            }
            
            return visionModel
        } catch {
            fatalError("Failed to create VNCoreMLModel: \(error)")
        }
    }()
    
    lazy var visionRequest: VNCoreMLRequest = {
        let request = VNCoreMLRequest(model: visionModel, completionHandler: {
            [weak self] request, error in
            self?.processObservations(for: request, error: error)
        })
        
        // NOTE: If you choose another crop/scale option, then you must also
        // change how the BoundingBoxView objects get scaled when they are drawn.
        // Currently they assume the full input image is used.
        request.imageCropAndScaleOption = .scaleFill
        return request
    }()
    
    let maxBoundingBoxViews = 10
    var boundingBoxViews = [BoundingBoxView]()
    var colors: [String: UIColor] = [:]
    
    
    
    @IBOutlet weak var navigation: UINavigationItem!
    @IBOutlet weak var img: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpBoundingBoxViews()
        img.image = passedimg.image
        //predict(sampleBuffer: buffer(from: img.image!)!)
        for box in self.boundingBoxViews {
            box.addToLayer(self.videoPreview.layer)
        }

        // Do any additional setup after loading the view.
    }
    
    @IBAction func detectSwitch(_ sender: Any) {
        let detect = sender as! UISwitch
        if detect.isOn {
            predict(sampleBuffer: buffer(from: img.image!)!)
        }
        else {
            for view in self.boundingBoxViews {
                view.hide()
            }
        }
    }
    
    func setUpBoundingBoxViews() {
        for _ in 0..<maxBoundingBoxViews {
            boundingBoxViews.append(BoundingBoxView())
        }
        
        let labels = [
            "apple",
            "banana",
            "cake",
            "candy",
            "carrot",
            "cookie",
            "doughnut",
            "grape",
            "hot dog",
            "ice cream",
            "juice",
            "muffin",
            "orange",
            "pineapple",
            "popcorn",
            "pretzel",
            "salad",
            "strawberry",
            "waffle",
            "watermelon",
        ]
        
        // Make colors for the bounding boxes. There is one color for
        // each class, 20 classes in total.
        var i = 0
        for r: CGFloat in [0.5, 0.6, 0.75, 0.8, 1.0] {
            for g: CGFloat in [0.5, 0.8] {
                for b: CGFloat in [0.5, 0.8] {
                    colors[labels[i]] = UIColor(red: r, green: g, blue: b, alpha: 1)
                    i += 1
                }
            }
        }
    }
    
    
    func predict(sampleBuffer: CVPixelBuffer) {
    
        let pixelBuffer = sampleBuffer
        currentBuffer = pixelBuffer
        
        // Get additional info from the camera.
        let options: [VNImageOption : Any] = [:]
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: options)
        do {
            try handler.perform([self.visionRequest])
        } catch {
            print("Failed to perform Vision request: \(error)")
        }
        currentBuffer = nil
        
    }
    
    func processObservations(for request: VNRequest, error: Error?) {
        //call show function
        if let results = request.results as? [VNRecognizedObjectObservation] {
            self.show(predictions: results)
        }
    }
    
    
    func show(predictions: [VNRecognizedObjectObservation]) {
        //process the results, call show function in BoundingBoxView
        DispatchQueue.main.async {
            for view in self.boundingBoxViews {
                view.hide()
            }
            var idx = 0
            for result in predictions {
                if (idx >= self.maxBoundingBoxViews) {
                    break
                }
                else if (result.confidence > 0.75 && !result.labels.isEmpty) {
                    let label = result.labels.first!.identifier
                    let color = self.colors[label]!
                    let rawFrame = result.boundingBox
                    let finalFrame = CGRect(x: rawFrame.origin.x*self.videoPreview.frame.width, y: rawFrame.origin.y*self.videoPreview.frame.height, width: rawFrame.width*self.videoPreview.frame.width, height: rawFrame.height*self.videoPreview.frame.height)
                    print(label, rawFrame, color)
                    self.boundingBoxViews[idx].show(frame: finalFrame, label: label, color: color)
                    idx += 1
                }
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

