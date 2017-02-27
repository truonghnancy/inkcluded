//
//  SelectImageViewController.swift
//  inkcluded-405
//
//  Created by Francis Yuen on 2/12/17.
//  Copyright © 2017 Boba. All rights reserved.
//

import UIKit

class SelectImageViewController: UIViewController {

    private var _selectImageDelegate: SelectImageDelegate?
    
    var selectImageDelegate: SelectImageDelegate {
        get {
            return _selectImageDelegate!
        }
        set(newValue) {
            self._selectImageDelegate = newValue
        }
    }

    @IBOutlet var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelButtonDidClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SelectImageViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        let defaultImage = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: cell.contentView.frame.size))
        defaultImage.image = UIImage(named: "francis")
        
        cell.contentView.addSubview(defaultImage)
        
        return cell
    }
}

extension SelectImageViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.dismiss(animated: true) {
            let size = CGSize(width: 80, height: 80)
            let origin = CGPoint(x: 0, y: 0)
            let defaultImage = DraggableImageView(frame: CGRect(origin: origin, size: size))
            defaultImage.image = UIImage(named: "francis")
            self.selectImageDelegate.didSelectImage(image: defaultImage)
        }
    }
}
