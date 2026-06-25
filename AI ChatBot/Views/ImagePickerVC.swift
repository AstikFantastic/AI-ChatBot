import UIKit

final class ImagePickerVC: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private weak var presentationController: UIViewController?
    private var completion: ((UIImage) -> Void)?
    
    init(presentationController: UIViewController) {
        self.presentationController = presentationController
        super.init()
    }
    
    func presentImagePicker(completion: @escaping (UIImage) -> Void) {
        self.completion = completion
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        presentationController?.present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }

            picker.dismiss(animated: true) { [weak self] in
                self?.completion?(image)
            }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
