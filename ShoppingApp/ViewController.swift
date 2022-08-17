//
//  ViewController.swift
//  ShoppingApp
//
//  Created by Mert Şahin on 17.08.2022.
//

import UIKit
import CoreData

class ViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    var clickedName = ""
    var clickedUUID : UUID?
    var itemArr = Array<ListItemEntity>()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        print(itemArr.count)
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addItemButton))
        // Do any additional setup after loading the view.
        getData()
    }
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("addItem"), object: nil)
    }
    @objc func getData(){
        itemArr.removeAll(keepingCapacity: false)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchDat = NSFetchRequest<NSFetchRequestResult>(entityName: "ShoppingList")
        fetchDat.returnsObjectsAsFaults = false
        
        do{
            
            let dataResults = try context.fetch(fetchDat)
            if dataResults.count > 0{
                for result in dataResults as! [NSManagedObject] {
                    if let name = result.value(forKey: "name") as? String{
                        if let id = result.value(forKey: "id") as? UUID{
                            
                            itemArr.append(.init(id: id, name: name))
                        }
                    }
                    
                }
                
                tableView.reloadData()
            }
        } catch {
            print("hata oluştu")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArr.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = itemArr[indexPath.row].name
        return cell
    }
    @objc func addItemButton(){
        clickedName = ""
     performSegue(withIdentifier: "addShopItem", sender: nil)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        clickedName = itemArr[indexPath.row].name
        clickedUUID = itemArr[indexPath.row].id
        performSegue(withIdentifier: "addShopItem", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addShopItem"{
            let destinationVC = segue.destination as? AddItemViewController
            
            destinationVC?.selectedItemName = clickedName
            destinationVC?.selectedItemUUID = clickedUUID
        }
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
        let appDelagate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelagate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ShoppingList")
        let uuidString = itemArr[indexPath.row].id.uuidString
        fetchRequest.predicate = NSPredicate(format: "id = %@" , uuidString)
        fetchRequest.returnsObjectsAsFaults = false
        
        
        do{
            let sonuclar = try context.fetch(fetchRequest)
            if sonuclar.count > 0 {
                for sonuc in sonuclar as! [NSManagedObject]{
                    if let id = sonuc.value(forKey: "id") as? UUID{
                        if id == itemArr[indexPath.row] .id{
                            context.delete(sonuc)
                            itemArr.remove(at: indexPath.row)
                            
                            self.tableView.reloadData()
                            
                            do{
                                try context.save()
                                getData()
                            }catch{
                                print("hata")
                            }
                        }
                    }
                }
            }
        }catch{
            print("Hata bulundu")
        }
        }
    }
}

