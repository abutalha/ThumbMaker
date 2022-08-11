//
//  ViewController.swift
//  ThumbMaker
//
//  Created by AbuTalha on 09/08/2022.
//

import Cocoa
import QuickLookThumbnailing

class ViewController: NSViewController {
    var image: NSImage = NSImage()
    
    //let dialog = NSOpenPanel()
    var ip: URL? = URL(string: "/Users/abutalha/Downloads/")
    var op: URL? = URL(string: "/Users/abutalha/Downloads/")
    
    @IBOutlet weak var inputPath: NSTextField!
    @IBOutlet weak var outputPath: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
//    override var representedObject: Any? {
//        didSet {
//            // Update the view, if already loaded.
//        }
//    }
    
    @IBAction func onInput(_ sender: Any) {
        showIPDialog()
    }
    
    @IBAction func onOutput(_ sender: Any) {
        showOPDialog()
    }
    
    @IBAction func onGenerate(_ sender: Any) {
        
        let fm = FileManager.default
        let docurl = fm.urls(for: .downloadsDirectory, in: .userDomainMask)[0].path
        do {
            let fileurls = try fm.contentsOfDirectory(atPath: docurl)
            for filename in fileurls {
                let nameWithoutExt = NSString(string: filename).deletingPathExtension
                generateThumbnail(for: (ip?.appendingPathComponent(filename))!, size: CGSize(width: 300, height: 300), newFileName: nameWithoutExt + ".png")
            }
            print (fileurls)
        }
        catch {
            print (error.localizedDescription)
        }
    }
    
    
    func showIPDialog() {
        let dialog = NSOpenPanel()
        
        dialog.title = "Choose single directory | Our Code World"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseFiles = false
        dialog.canChooseDirectories = true
        dialog.canCreateDirectories = true
        
        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            let result = dialog.url
            ip = dialog.url
            
            if (result != nil) {
                let path: String = result!.path
                //image = NSImage(contentsOf: URL(fileURLWithPath: path + "/1.png"))!
                print (path)
                //return path
                // path contains the directory path e.g
                // /Users/ourcodeworld/Desktop/folder
            }
        } else {
            // User clicked on "Cancel"
            return
        }
        return
    }
    
    func showOPDialog() {
        
        let dialog = NSSavePanel()
        dialog.title = "Output Location"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canCreateDirectories = true
        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            let result = dialog.url
            
            if (result != nil) {
                op = result
//                let path: String = result!.path
                // path contains the directory path e.g
                // /Users/ourcodeworld/Desktop/folder
            }
        } else {
            // User clicked on "Cancel"
            return
        }
        return
    }
    
    
    func generateThumbnail(for resource: URL, size: CGSize, newFileName: String) {
//
        let fm = FileManager.default
        let docurl = fm.urls(for: .downloadsDirectory, in: .userDomainMask)[0]
        
//        // Create url for resource
//        let filePath = "/Volumes/Dev/Work/Reference/ARModels/" + resource + "." + withExtension
//        //let url1 = NSURL(string: filePath)
//        //        guard let url = Bundle.main.url(forResource: resource, withExtension: withExtension) else {
//        let url = URL(fileURLWithPath: filePath)
//        if url.path.isEmpty {
//            // Handle the error case.
//            print("Unable to create URL for resource. \(resource)")
//            return
//        }
//
//        // Get the scale of the display. Retina displays have a scale of 2 or 3. Regular displays have 1.
//        //        let scale = UIScreen.main.scale
        let scale = NSScreen.main?.backingScaleFactor ?? 2
//
        // Create the thumbnail request.
        let request = QLThumbnailGenerator.Request(fileAt: resource,
                                                   size: size,
                                                   scale: scale,
                                                   representationTypes: .thumbnail)

        // Retrieve the singleton instance of the thumbnail generator and generate the thumbnails.
        let generator = QLThumbnailGenerator.shared
        generator.generateRepresentations(for: request) { (thumbnail, type, error) in

            DispatchQueue.global(qos: .default).async {
                if thumbnail == nil || error != nil {
                    // Handle the error case gracefully.
                    //print("ThumbnailGenerator: " + resource + " - " + error!.localizedDescription)
                    return
                } else {
                    print ("generating... \(newFileName)")
                    let newPath = docurl.appendingPathComponent(newFileName)
                    _ = thumbnail?.nsImage.pngWrite(to: newPath)
                    sleep(1)
                }
            }
        }
    }
}

extension NSImage {
    var pngData: Data? {
        guard let tiffRepresentation = tiffRepresentation, let bitmapImage = NSBitmapImageRep(data: tiffRepresentation) else { return nil }
        return bitmapImage.representation(using: .png, properties: [:])
    }
    func pngWrite(to url: URL, options: Data.WritingOptions = .atomic) -> Bool {
        do {
            try pngData?.write(to: url, options: options)
            return true
        } catch {
            print(error)
            return false
        }
    }
}

