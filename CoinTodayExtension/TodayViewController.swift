//
//  TodayViewController.swift
//  CoinTodayExtension
//
//  Created by Navneet Singh on 07/05/18.
//  Copyright © 2018 Navneet. All rights reserved.
//
import UIKit
import NotificationCenter
class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var rateLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    private   lazy var todayModel : TodayCoinModel? = {
        guard let data =  SharedData.init().fetchDataFromSharedContainer()else{
            return nil
        }
        return data
    }()
    
    //MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // Fetching Data from server
    func fetchBitCoinRatesFromServer(){
        NetworkHandler.callWebServicefor(ApiType.Today.rawValue) { [unowned self] response in
            switch response{
            case .invalid:
                print("Invalid Url")
            case .failure(let error):
                if let eror = error as NSError?{
                    print("Error code:\(eror.code)")
                }
                print("Failed response")
                print(error.localizedDescription)
            case .success(let responseData):
                if let decode = try? JSONDecoder().decode(TodayCoinModel.self, from: responseData){
                    self.todayModel = decode
                    SharedData.init().addSharedDataToContainder(responseData)
                    self.setRateForSelectedCurrency()
                }
              
            }
            
        }
    }
// Setting UIComponents
    func setRateForSelectedCurrency(){
        guard let modal = todayModel else {
            fetchBitCoinRatesFromServer()
            return
        }
        DispatchQueue.main.async { [unowned self] in
        self.dateLbl.text =  modal.time
        let sign = self.segmentControl.titleForSegment(at: self.segmentControl.selectedSegmentIndex)
        self.rateLbl.text = modal.currencies.EUR.rate
        
        switch sign! {
        case "EUR":
            self.rateLbl.text = (sign?.convertCurrencyCodeToSymbol())! + (modal.currencies.EUR.rate)
            
            
        case "USD":
            self.rateLbl.text = (sign?.convertCurrencyCodeToSymbol())! + (modal.currencies.USD.rate)

        case "GBP":
            self.rateLbl.text = (sign?.convertCurrencyCodeToSymbol())! + (modal.currencies.GBP.rate)
        
        default:
            self.rateLbl.text = (sign?.convertCurrencyCodeToSymbol())! + (modal.currencies.EUR.rate)
            
        }
            self.activityIndicator.stopAnimating()
            
        }
    }
    
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
       
        
        setRateForSelectedCurrency()
        
        completionHandler(NCUpdateResult.newData)
    }
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == .compact {
            self.preferredContentSize = maxSize
        } else if activeDisplayMode == .expanded {
            self.preferredContentSize = CGSize(width: maxSize.width, height: 150)
        }
    }
    //IBACtions
    @IBAction func segmentAction(_ sender: UISegmentedControl) {
        setRateForSelectedCurrency()
    }
    
    @IBAction func refreshAction(_ sender: Any) {
        activityIndicator.startAnimating()
        fetchBitCoinRatesFromServer()
    }
}


