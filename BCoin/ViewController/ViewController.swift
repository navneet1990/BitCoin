//
//  ViewController.swift
//  BCoin
//
//  Created by Navneet Singh on 04/05/18.
//  Copyright © 2018 Navneet. All rights reserved.
//

import UIKit
import WatchConnectivity
class ViewController: UIViewController {
    //MARK: IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var lastUpdatedLbl: UILabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var priceLbl: UILabel!
    
    private  var viewModal : BCViewModel = BCViewModel()
    private var connectHandler : BCConnectModel?

    
    //MARK: View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
                // Do any additional setup after loading the view, typically from a nib.
        //Checking for Watch
        connectHandler  = BCConnectModel.init()
        loadUIFromModelResponse()
        unbindMsgsFromWatch()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Load UI

    func loadUIFromModelResponse(){
        //Two phase binding
        viewModal.alerts?.bind(listener: { (alertData) in
            guard let alertObj = alertData else{
                return
            }

          let alert = UIAlertController.init(title: alertObj.title, message: alertObj.msg, preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: alertObj.buttonTitle, style: .default, handler: nil))
            DispatchQueue.main.async { [unowned self] in
                self.activityIndicator.stopAnimating()
                self.present(alert, animated: true, completion: nil)
            }
        })
        viewModal.currencyCode.bind { [unowned self](code) in
                  self.connectHandler!.notifyCurrencyChange(code.rawValue)
           
            self.segmentControl.selectedSegmentIndex = code.hashValue
        }
        viewModal.previousDaysRateCoin?.bind{[unowned self](data) in
           DispatchQueue.main.async { [unowned self] in
            self.tableView.reloadData()
                }}
        
        viewModal.currentRateCoin?.bind { (coinData) in
            
            guard let coin = coinData?.0,let lastUpdateTime = coinData?.1 else{
                return
            }
            self.connectHandler!.notigyForTodayData(lastUpdateTime, coin.rate, coin.code)
            DispatchQueue.main.async { [unowned self] in
                self.activityIndicator.stopAnimating()
                self.lastUpdatedLbl.text = lastUpdateTime
                self.priceLbl.text = coin.code.rawValue.convertCurrencyCodeToSymbol()! + coin.rate
                
            }        }
    }
    func unbindMsgsFromWatch(){
        connectHandler!.updatePrice?.bind(listener: { (price) in
            guard let value = price else{
                return
            }
            DispatchQueue.main.async { [unowned self] in
                self.priceLbl.text =  value
                
            }
        })
        connectHandler!.updateDate?.bind(listener: { (date) in
            guard let value = date else{
                return
            }
            
            DispatchQueue.main.async { [unowned self] in
                self.lastUpdatedLbl.text =  value
                
            }
        })
        connectHandler!.updateSegment?.bind(listener: { (code) in
            guard let value = code else{
                return
            }
            DispatchQueue.main.async { [unowned self] in
                self.segmentControl.selectedSegmentIndex = value
                
            }
        })
        connectHandler!.updateTable?.bind(listener: { (code) in
            guard let _ = code else{
                return
            }
            DispatchQueue.main.async { [unowned self] in
                self.tableView.reloadData()
                
            }
        })

    }
    //IBActions
    @IBAction func changeCurrencySegmentAction(_ sender: UISegmentedControl) {
        viewModal.changeCurrencyCode(sender.titleForSegment(at: sender.selectedSegmentIndex)!)
    }
    
}

//MARK: UITableView Data Source methods
extension ViewController : UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModal.previousDaysRateCoin?.value?.dates.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TableCellIdenfiers.coinRateCell.rawValue, for: indexPath) as UITableViewCell? else {
            return UITableViewCell(style: .default, reuseIdentifier: TableCellIdenfiers.defaultCell.rawValue)
        }
        let dict = viewModal.previousDaysRateCoin!.value!.list
        let coinData = dict[(viewModal.previousDaysRateCoin!.value!.dates[indexPath.row])]
        cell.textLabel?.text = viewModal.currencyCode.value.rawValue.convertCurrencyCodeToSymbol()! + "\(String(describing: coinData!))"
        cell.detailTextLabel?.text = viewModal.previousDaysRateCoin!.value!.dates[indexPath.row]
        return cell
    }
}
//MARK: UITableView Data Source methods
extension ViewController : UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
      self.connectHandler!.notifyTableInteraction(forIndex: indexPath.row)
    }

}
