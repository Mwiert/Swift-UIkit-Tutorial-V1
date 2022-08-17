//
//  AddItemViewController.swift
//  ShoppingApp
//
//  Created by Mert Şahin on 17.08.2022.
//

import UIKit
import CoreData

class AddItemViewController:UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var urunAdiText: UITextField!
    @IBOutlet weak var urunFiyatiText: UITextField!
    @IBOutlet weak var urunSizeText: UITextField!
    @IBOutlet weak var urunDatePicker: UIDatePicker!
    
    
    var selectedItemName = ""
    var selectedItemUUID : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if selectedItemName != ""{
            if let selectedUUIDString = selectedItemUUID?.uuidString{
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                
                let fetchData = NSFetchRequest<NSFetchRequestResult>.init(entityName: "ShoppingList")
                fetchData.predicate = NSPredicate.init(format: "id = %@", selectedUUIDString)
                fetchData.returnsObjectsAsFaults = false
                
                do{
                    let rslts = try context.fetch(fetchData)
                    if rslts.count > 0 {
                        for sonuc in rslts as! [NSManagedObject]{
                            if let name = sonuc.value(forKey: "name") as? String{
                                urunAdiText.text = name
                            }
                            if let fiyat = sonuc.value(forKey: "price") as? Double{
                                urunFiyatiText.text = String(fiyat)
                            }
                            if let size = sonuc.value(forKey: "size") as? String{
                                urunSizeText.text = size
                            }
                            if let date = sonuc.value(forKey: "date") as? Date{
                                urunDatePicker.date = date
                            }
                            if let img = sonuc.value(forKey: "picture") as? Data{
                                let image = UIImage(data: img)
                                imageView.image = image
                            }
                        }
                    }
                    
                }catch{
                    print("Hata oluştu")
                }
            }
        }
        else{
            urunAdiText.text = ""
            urunFiyatiText.text = ""
            urunSizeText.text = ""
            
        }
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
        imageView.isUserInteractionEnabled = true
        let imageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(addImage))
        imageView.addGestureRecognizer(imageGestureRecognizer)
    }
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    @objc func addImage(){
        let imgPicker = UIImagePickerController()
        imgPicker.delegate = self
        imgPicker.sourceType = .photoLibrary
        present(imgPicker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true)
    }
    
    @IBAction func saveItemButton(_ sender: Any) {
        
        if selectedItemName != "" {
            print("Güncelleme işlemi istendi")
        }
        else{
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let shopping = NSEntityDescription.insertNewObject(forEntityName: "ShoppingList", into: context)
        let img = imageView.image?.jpegData(compressionQuality: 0.5)
        
        shopping.setValue(img, forKey: "picture")
        shopping.setValue(urunAdiText.text!, forKey: "name")
        shopping.setValue(urunSizeText.text!, forKey: "size")
        shopping.setValue(urunDatePicker.date, forKey: "date")
        
        if let fiyat = Double(urunFiyatiText.text!){
            shopping.setValue(fiyat, forKey: "price")
        }
        shopping.setValue(UUID(), forKey: "id")
        
        do{
            try context.save()
        }catch{
            print("hata oluştu")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("addItem"), object: nil)
        self.navigationController?.popViewController(animated: true)
            
        }
    }
}
