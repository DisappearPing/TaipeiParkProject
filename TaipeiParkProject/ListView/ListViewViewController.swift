//
//  ListViewViewController.swift
//  TaipeiParkProject
//
//  Created by Hsiao Wind on 2018/6/10.
//  Copyright © 2018年 Hsiao. All rights reserved.
//

import UIKit

class ListViewViewController: UIViewController {

    @IBOutlet weak var parkTableView: UITableView!
    
    var parks = [Park]()
    var selectedPark: Park?
    var cache = NSCache<AnyObject, AnyObject>()
    var isLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        getListDataWithPage(0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.tabBarController?.selectedIndex = 1
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

// MARK: Custom Method

extension ListViewViewController {
    func getListDataWithPage(_ page: Int) {
        APIManager.shared.getListDataWithPage(page) { [unowned self] (result, error) in
            guard error == nil else {
                print("error = \(error)")
                return
            }
            print("result = \(result)")
            let newParks = result!.result?.results ?? []
            if page == 0 {
                self.parks = newParks
            } else {
                self.parks += newParks
            }
           
            DispatchQueue.main.async {
                self.parkTableView.reloadData()
                self.isLoading = false
                self.removeRefreshFootView()
            }
        }
    }
    
    func setUpRefreshFootView() {
        let indicatorFooter = UIActivityIndicatorView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: parkTableView.frame.size.width, height: 44)))
        indicatorFooter.color = UIColor.darkGray
        indicatorFooter.startAnimating()
        
        parkTableView.tableFooterView = indicatorFooter
    }
    
    func removeRefreshFootView() {
        parkTableView.tableFooterView = UIView()
    }
    
    @objc func cellMapButtonAction(_ sender: UIButton) {
        selectedPark = parks[sender.tag]
        self.tabBarController?.selectedIndex = 1
    }
}

// MARK: UITableViewDataSource

extension ListViewViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return parks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ListViewBasicTableViewCell
        let cellData = parks[indexPath.row]
        
        cell.parkNameLabel.text = cellData.parkName
        cell.administrativeAreaLabel.text = cellData.administrativeArea
        cell.introductionLabel.text = cellData.introduction
        if let cacheImage = cache.object(forKey: indexPath.row as AnyObject) as? UIImage {
            cell.parkImageView.image = cacheImage
        } else {
            cell.parkImageView.imageFromServerURL(urlString: cellData.image ?? "") {[unowned self] (image) in
                guard let image = image else { return }
                self.cache.setObject(image, forKey:  indexPath.row as AnyObject)
            }
        }
        
        cell.mapButton.addTarget(self, action: #selector(cellMapButtonAction(_:)), for: .touchUpInside)
        cell.mapButton.tag = indexPath.row
        
        return cell
    }
}

// MARK: UITableViewDelegate

extension ListViewViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard parks.count == indexPath.row + 1 && parks.count % 15 == 0 else { return }
        if ( indexPath.row + 1) % 15 == 0 && isLoading == false {
            setUpRefreshFootView()
            isLoading = true
            getListDataWithPage(parks.count + 1)
        } else {
            removeRefreshFootView()
        }
    }
}
