/// Copyright (c) 2019 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import Vision

class TakeViewController: UIViewController {
  
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var cameraButton: UIButton!
    @IBOutlet var photoLibraryButton: UIButton!
    @IBOutlet var resultsView: UIView!
    @IBOutlet var resultsLabel: UILabel!
    @IBOutlet var resultsConstraint: NSLayoutConstraint!
    
    
    var firstTime = true
    var result = ""
    weak var delegate: CategaryTableViewController!

  //TODO: define a VNCoreMLRequest
    lazy var classificationRequest: VNCoreMLRequest = {
            do{
                let classifier = try Snacks(configuration: MLModelConfiguration())
                let model = try VNCoreMLModel(for: classifier.model)
                let request = VNCoreMLRequest(model: model, completionHandler: {
                    [weak self] request,error in
                    self?.processObservations(for: request, error: error)
                })
                request.imageCropAndScaleOption = .centerCrop
                return request
                
                
            } catch {
                fatalError("Failed to create request")
            }
        }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        resultsView.alpha = 0
        resultsLabel.text = "choose or take a photo"
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Show the "choose or take a photo" hint when the app is opened.
        if firstTime {
          showResultsView(delay: 0.5)
          firstTime = false
        }
    }

    @IBAction func takePicture() {
        presentPhotoPicker(sourceType: .camera)
    }

    @IBAction func choosePhoto() {
        presentPhotoPicker(sourceType: .photoLibrary)
    }

    func presentPhotoPicker(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        present(picker, animated: true)
        hideResultsView()
    }

    func showResultsView(delay: TimeInterval = 0.1) {
    resultsConstraint.constant = 100
    view.layoutIfNeeded()

    UIView.animate(withDuration: 0.5,
                   delay: delay,
                   usingSpringWithDamping: 0.6,
                   initialSpringVelocity: 0.6,
                   options: .beginFromCurrentState,
                   animations: {
      self.resultsView.alpha = 1
      self.resultsConstraint.constant = -10
      self.view.layoutIfNeeded()
    },
    completion: nil)
    }

    func hideResultsView() {
    UIView.animate(withDuration: 0.3) {
      self.resultsView.alpha = 0
    }
    }

    func classify(image: UIImage) {
      //TODO: use VNImageRequestHandler to perform a classification request
        guard let ciImage = CIImage(image: image) else {
            print("Unable to create CIImage")
            return
        }
        
        let orientation = CGImagePropertyOrientation(image.imageOrientation)
        
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
            do {
                try handler.perform([self.classificationRequest])
            } catch {
                print("Failed to perform classification: \(error)")
            }
        }
    }
    
    func currentTime() -> String {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        return dateformatter.string(from: Date())

    }

    
    func processObservations(for request1: VNRequest, error: Error?) {
            // print("Result:",request.results)
        DispatchQueue.main.async {
            if let results = request1.results as? [VNClassificationObservation] {
                if results.isEmpty {
                    self.resultsLabel.text = "Nothing found"
                } else {
                    var count = 0
                    for label in results {
                        if label.confidence >= 0.8 {
                            // self.resultsLabel.text = String(format:"%@: %.1f%%", results[0].identifier, results[0].confidence * 100)
                            self.result = label.identifier
                            self.delegate.photos[self.result]?.append(self.imageView)
                            self.delegate.times[self.result]?.append(String(format:"%.2f", label.confidence * 100) + "%   " +  self.currentTime())
                            self.delegate.tableView.reloadData()
                            print(self.result)
                            print(label.confidence)
                            count += 1
                        }
                    }
                    if count == 0 {
                        self.delegate.photos["unknown"]?.append(self.imageView)
                        self.delegate.times["unknown"]?.append(self.currentTime())
                        self.delegate.tableView.reloadData()
                    }
                }
            } else if let error = error {
                self.resultsLabel.text = "Error: \(error.localizedDescription)"
            } else {
                self.resultsLabel.text = "???"
            }
            self.showResultsView()
        }
    }
}
  //TODO: define a function like func processObservations(for request: VNRequest, error: Error?)  to process the results from the classification model
    

extension TakeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    picker.dismiss(animated: true)

    let image = info[.originalImage] as! UIImage
    imageView.image = image

    classify(image: image)
    }
}


