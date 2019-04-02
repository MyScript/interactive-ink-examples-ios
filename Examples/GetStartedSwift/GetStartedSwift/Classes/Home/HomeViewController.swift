// Copyright MyScript. All right reserved.

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var inputTypeSegmentedControl: UISegmentedControl!

    weak var editorViewController: EditorViewController!
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        editorViewController = (children.first as! EditorViewController)
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            if (appDelegate.engine == nil)
            {
                let alert = UIAlertController(title: "Certificate error",
                                              message: appDelegate.engineErrorMessage,
                                              preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK",
                                              style: UIAlertAction.Style.default,
                                              handler: {(action: UIAlertAction) -> Void in
                                                  exit(1)
                                              }))
                self.present(alert, animated: true, completion: nil)
                return
            }
            editorViewController.engine = appDelegate.engine
        }
        
        editorViewController.inputMode = .forcePen  // We want the Pen mode for this GetStarted sample code. It lets the user use either its mouse or fingers to draw.
        // If you have got an iPad Pro with an Apple Pencil, please set this value to InputModeAuto for a better experience.
        
        inputTypeSegmentedControl.selectedSegmentIndex = Int(editorViewController.inputMode.rawValue)

        do {
            if let package = try createPackage(packageName: "New") {
                try editorViewController.editor.part = package.getPartAt(0)
            }
        } catch {
            print("Error while creating package : " + error.localizedDescription)
        }
    }
    
    // MARK: - Create package

    func createPackage(packageName: String) throws -> IINKContentPackage? {
        // Create a new content package with name
        var resultPackage: IINKContentPackage?
        let fullPath = FileManager.default.pathForFile(inDocumentDirectory: packageName) + ".iink"
        if let engine = (UIApplication.shared.delegate as? AppDelegate)?.engine {
            resultPackage = try engine.createPackage(fullPath.decomposedStringWithCanonicalMapping)
            
            // Add a blank page type Text Document
            if let part = try resultPackage?.createPart("Text Document") /* Options are : "Diagram", "Drawing", "Math", "Text Document", "Text" */ {
                self.title = "Type: " + part.type
            }
        }
        return resultPackage
    }
    
    // MARK: - Buttons actions

    @IBAction func clearButtonWasTouchedUpInside(_ sender: Any) {
        editorViewController.editor.clear()
    }
    
    @IBAction func undoButtonWasTouchedUpInside(_ sender: Any) {
        editorViewController.editor.undo()
    }
    
    @IBAction func redoButtonWasTouchedUpInside(_ sender: Any) {
        editorViewController.editor.redo()
    }
    
    @IBAction func convertButtonWasTouchedUpInside(_ sender: Any) {
        do {
            let supportedTargetStates = editorViewController.editor.getSupportedTargetConversionState(nil)
            try editorViewController.editor.convert(nil, targetState: supportedTargetStates[0].value)
        } catch {
            print("Error while converting : " + error.localizedDescription)
        }
    }

    // MARK: - Segmented control actions
    
    @IBAction func inputTypeSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        guard let inputMode = InputMode(rawValue: UInt(sender.selectedSegmentIndex)) else {
            return
        }
        editorViewController.inputMode = inputMode
    }
    
}
