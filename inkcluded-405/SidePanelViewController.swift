//
//  SidePanelViewController.swift
//  inkcluded-405
//
//  Created by Nancy on 1/30/17.
//  Copyright © 2017 Boba. All rights reserved.
//

import Foundation
import UIKit

protocol SidePanelViewControllerDelegate {
    //func animalSelected(_ animal: Animal)
}

class SidePanelViewController: UIViewController {
    /*
     @IBOutlet weak var tableView: UITableView!
     
     var animals: Array<Animal>!
     
     struct TableView {
     struct CellIdentifiers {
     static let AnimalCell = "AnimalCell"
     }
     }
     
     override func viewDidLoad() {
     super.viewDidLoad()
     
     tableView.reloadData()
     }
     */
}

// MARK: Table View Data Source
/*
 extension SidePanelViewController: UITableViewDataSource {
 
 func numberOfSections(in tableView: UITableView) -> Int {
 return 1
 }
 
 func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
 //return animals.count
 return null
 }
 
 func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
 /*let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.AnimalCell, for: indexPath) as! AnimalCell
 cell.configureForAnimal(animals[indexPath.row])
 return cell
 */
 return null
 }
 
 }*/

// Mark: Table View Delegate

extension SidePanelViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
}

class AnimalCell: UITableViewCell {
    /*
     @IBOutlet weak var animalImageView: UIImageView!
     @IBOutlet weak var imageNameLabel: UILabel!
     @IBOutlet weak var imageCreatorLabel: UILabel!
     
     func configureForAnimal(_ animal: Animal) {
     animalImageView.image = animal.image
     imageNameLabel.text = animal.title
     imageCreatorLabel.text = animal.creator
     }
     */
}
