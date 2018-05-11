//
//  BCViewModel.swift
//  BCoin
//
//  Created by Navneet Singh on 04/05/18.
//  Copyright © 2018 Navneet. All rights reserved.
//
import WatchKit
import UIKit


class BCViewModel: NSObject {
    // Private properties
    private  let serviceRefreshTime = 60.0
    private var sharedData : SharedData = SharedData.init()
    private var previousCoinModel : PreviousDaysCoinModel? = PreviousDaysCoinModel.init(currencies: CurrencyOld.init()){
        didSet{
            previousDaysRateCoin?.value = previousCoinModel!.currencies.currencyBasedOnCode(code: currentCurrencyCode)
        }
    }
    private  var todayCoinModel : TodayCoinModel?{
        didSet{
            changeCurrentCoinData()
        }
    }
    private   var currentCurrencyCode : CurrencyCodes = CurrencyCodes.EUR{
        didSet{
            currencyCode.value = currentCurrencyCode
            changeCurrentCoinData()
            fetchDataForLastTwoWeeks()
        }
    }
    var todayServiceTimer: DispatchSourceTimer?
    
    var previousDaysRateCoin : Binding<Coins?>? = Binding(nil)
    var currentRateCoin : Binding<(Coin ,String)?>? = Binding(nil)
    var alerts : Binding<AlertMsgModal?>? = Binding(nil)
    var currencyCode : Binding<CurrencyCodes> = Binding(CurrencyCodes.EUR)
    
    override  init() {
        super.init()
        fetchTodayBitCoinRateFromServer()
        fetchDataForLastTwoWeeks()
        refreshWebApiTimerForToday()
        todayServiceTimer!.resume()
    }
    func changeCurrencyCode(_ code: String){
        currentCurrencyCode.setCurrencyCode(code)
    }
}
private extension BCViewModel{
    // Fetch Data From Server
    func fetchBitCoinRatesFromServer(apiType : ApiType, parms: String = ""){
        NetworkHandler.callWebServicefor(apiType.rawValue + parms) { [unowned self] response in
            switch response{
            case .invalid:
                print("Invalid Url")
                
            case .failure(let error):
                if let eror = error as NSError? {
                    if eror.code == -1009{
                        self.alerts?.value = AlertMsgModal.init(title: "Opps", msg: "Please connect to internet", buttonTitle: "Ok")
                    }}
                print("Failed response")
                print(error.localizedDescription)
                
            case .success(let responseData):
                if let decode = try? JSONDecoder().decode(TodayCoinModel.self, from: responseData){
                    self.todayCoinModel = decode
                    self.sharedData.addSharedDataToContainder(responseData)
                }
                else if let coin = try? JSONDecoder().decode(Coins.self, from: responseData){
                    self.sharedData.saveDataForOldDates(responseData, self.currentCurrencyCode)
                    self.mapOldCoinData(forCoin: coin)
                    
                }
            }
            
        }
    }
    func refreshWebApiTimerForToday(){
        todayServiceTimer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
        todayServiceTimer!.setEventHandler(handler: {[weak self] in
            self?.fetchBitCoinRatesFromServer(apiType: ApiType.Today )
        })
        todayServiceTimer!.schedule(deadline: .now(), repeating: serviceRefreshTime)
        
    }
}
//MARK: Last Two weeks data extension
extension BCViewModel{
    private  func mapOldCoinData(forCoin coin: Coins){
        switch self.currentCurrencyCode  {
        case .EUR:
            self.previousCoinModel?.currencies.EUR = coin
            
        case .USD:
            self.previousCoinModel?.currencies.USD = coin
            
        case .GBP:
            self.previousCoinModel?.currencies.GBP = coin
            
        }
    }
    private  func callOldDatesData(){
        let params = "start=\(Date().getDateBeforeDays(14).changeDateToString())" + "&" + "end=\(Date().changeDateToString())" + "&" + "currency=" + currentCurrencyCode.rawValue
        fetchBitCoinRatesFromServer(apiType: ApiType.Last2Week, parms: params)
    }
    
    func fetchDataForLastTwoWeeks()  {
        if let sharedData = sharedData.fetchOldData(currentCurrencyCode){
            mapOldCoinData(forCoin: sharedData)
        }
        else{
            guard let coin = previousCoinModel!.currencies.currencyBasedOnCode(code: currentCurrencyCode)  else {
                callOldDatesData()
                return
            }
            mapOldCoinData(forCoin: coin)
            // IF date is old then we will referesh
            if Date().lastFetchedDataIsToday((self.previousDaysRateCoin?.value?.time)!) == false{
                callOldDatesData()
            }
        }
        
    }
}
//MARK: Today Data Extension
extension BCViewModel{
    // Calling today rate service after every 5 mins
    
    func fetchTodayBitCoinRateFromServer(){
        if let sharedData = sharedData.fetchDataFromSharedContainer(){
            todayCoinModel = sharedData
        }
        else{
            self.fetchBitCoinRatesFromServer(apiType: ApiType.Today )
        }
    }
    //Check selected currency
    func changeCurrentCoinData(){
        switch currentCurrencyCode {
        case .EUR:
            currentRateCoin?.value = (todayCoinModel?.currencies.EUR,  todayCoinModel?.time) as? (Coin, String)
        case .GBP:
            currentRateCoin?.value = (todayCoinModel?.currencies.GBP ,  todayCoinModel?.time) as?(Coin,String)
        case .USD:
            currentRateCoin?.value = (todayCoinModel?.currencies.USD,  todayCoinModel?.time) as? (Coin, String)
        }
        if !((currentRateCoin?.value) != nil) {
            fetchTodayBitCoinRateFromServer()
        }
    }
}
