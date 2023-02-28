//
//  PictureTableViewController.swift
//  MyAlbum
//
//  Created by hbd on 2022/12/14.
//

import UIKit

class PictureTableViewController: UITableViewController {

    var pictureList: [UIImageView] = []
    var timeList: [String] = []
    
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
        return pictureList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "picture", for: indexPath)

        // Configure the cell...
        let picture = pictureList[indexPath.row]
        picture.contentMode = UIView.ContentMode.scaleAspectFit
        //picture.clipsToBounds = true
        cell.contentView.addSubview(picture)
        /*
        picture.translatesAutoresizingMaskIntoConstraints = false
        let ratio = Double(picture.frame.size.height)/Double(picture.frame.size.width)
        picture.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 2).isActive = true
        picture.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 2).isActive = true
        picture.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: 2).isActive = true
        picture.heightAnchor.constraint(equalTo: picture.widthAnchor, multiplier: ratio).isActive = true
        picture.widthAnchor.constraint(equalTo: cell.contentView.widthAnchor, multiplier: 1).isActive = true
        picture.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: 0).isActive = true
         */
        picture.translatesAutoresizingMaskIntoConstraints = false
        //let ratio = Double(picture.frame.size.height)/Double(picture.frame.size.width)
        
        picture.heightAnchor.constraint(equalTo: cell.heightAnchor, multiplier: 1).isActive = true
        picture.widthAnchor.constraint(equalTo: cell.heightAnchor, multiplier: 1).isActive = true
        //cell.h
        cell.detailTextLabel!.text = timeList[indexPath.row]
        return cell
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

    var clicked = UIImageView()
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        clicked = pictureList[indexPath.row]
        return indexPath
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        let controller = segue.destination as! SinglePictureViewController
        controller.passedimg = clicked
        controller.navigation.title = "detail"
    }
    

}
