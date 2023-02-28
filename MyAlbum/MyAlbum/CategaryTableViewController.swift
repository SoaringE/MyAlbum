//
//  CategaryTableViewController.swift
//  MyAlbum
//
//  Created by hbd on 2022/12/14.
//

import UIKit

class CategaryTableViewController: UITableViewController {
    
    var categaryList: [String] = ["apple", "banana", "cake", "candy", "carrot", "cookie", "doughnut", "grape", "hot dog", "ice cream", "juice", "muffin", "orange", "pineapple", "popcorn", "pretzel", "salad", "strawberry", "waffle", "watermelon", "unknown"]
    
    var photos: [String: [UIImageView]] = ["apple": [], "banana": [], "cake": [], "candy": [], "carrot": [], "cookie": [], "doughnut": [], "grape": [], "hot dog": [], "ice cream": [], "juice": [], "muffin": [], "orange": [], "pineapple": [], "popcorn": [], "pretzel": [], "salad": [], "strawberry": [], "waffle": [], "watermelon": [], "unknown": []]
    
    var times: [String: [String]] = ["apple": [], "banana": [], "cake": [], "candy": [], "carrot": [], "cookie": [], "doughnut": [], "grape": [], "hot dog": [], "ice cream": [], "juice": [], "muffin": [], "orange": [], "pineapple": [], "popcorn": [], "pretzel": [], "salad": [], "strawberry": [], "waffle": [], "watermelon": [], "unknown": []]
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 21
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categary", for: indexPath)

        // Configure the cell...
        cell.textLabel!.text = categaryList[indexPath.row]
        cell.detailTextLabel!.text = String(photos[categaryList[indexPath.row]]!.count)
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Categary"
        }
        return "Unknown"
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    var clicked = ""
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        clicked = categaryList[indexPath.row]
        return indexPath
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "take" {
            let controller = segue.destination as! TakeViewController
            controller.delegate = self
            controller.navigationItem.title = clicked
        }
        if segue.identifier == "show" {
            let controller = segue.destination as! PictureTableViewController
            for pic in photos[clicked]! {
                controller.pictureList.append(pic)
            }
            for time in times[clicked]! {
                controller.timeList.append(time)
            }
            controller.navigationItem.title = clicked
        }
    }
    

}
