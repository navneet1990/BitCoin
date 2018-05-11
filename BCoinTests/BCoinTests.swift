//
//  BCoinTests.swift
//  BCoinTests
//
//  Created by Navneet Singh on 04/05/18.
//  Copyright © 2018 Navneet. All rights reserved.
//

import XCTest
@testable import BCoin

class BCoinTests: XCTestCase {
    var viewModal: BCViewModel?
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        //All functionaly and data handling is done by View model which uses MVVM architecure
        // Initializing the View Modal
        viewModal = BCViewModel.init()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    //MARK: Today Coin test cases
    func testTodayCoinCurrencyChange(){
        // Here we check the coin rate the for Today for different currency is not same and also currency code is different
        //By default it will always take Euro
        let intialEuroValue = viewModal?.currentRateCoin?.value?.0
        XCTAssertEqual(intialEuroValue!.code, CurrencyCodes(rawValue: CurrencyCodes.EUR.rawValue))
       
        // We will change currancy to Dollar(USD)
        viewModal?.changeCurrencyCode(CurrencyCodes.USD.rawValue)
        
        //Now we must get currency as USD
        let finalDollarValue = viewModal?.currentRateCoin?.value?.0
        XCTAssertEqual(finalDollarValue!.code, CurrencyCodes(rawValue: CurrencyCodes.USD.rawValue))
        
        //Last we check the our current coin object stores the value according to currency selected
        XCTAssertNotEqual(finalDollarValue?.rate, intialEuroValue?.rate)
        XCTAssertNotEqual(finalDollarValue?.code, intialEuroValue?.code)
    }
    
    func testForIfTodayCoinDataChangesAfter60Seconds(){
        //First we will put on sleep to 5 seconds so, that we get the response from server, otherwise it will read data from shared container, if available
            sleep(5)
        // Check initial value of coin on first time service call
        let intialValue = viewModal?.currentRateCoin?.value?.1
        
        //Now we will wait for 65 secs and check for data change
        sleep(65)
        
        // We will compare string , which stores last updated date
        let finalValue = viewModal?.currentRateCoin?.value?.1
        XCTAssertNotEqual(intialValue, finalValue)
    }
    
    func testDataStoredInSharedContainerIsALwaysUpdated() {
        // Here we check we are storing data in Userdefaults in shared container
        // it will fail when we fetch data first time
     let todayData = SharedData.init().fetchDataFromSharedContainer()
        XCTAssertNotNil(todayData)
        
        // Clearning shared Data
        SharedData.init().resetTodayDataContainer()
        let someEmptyData = fetchDataTodayDataFomSharedContainer()
        XCTAssertNil(someEmptyData)
        
       // We always update the Shared data when service refresh after every 60 secs
        // But for testing we will call manually
        viewModal?.fetchTodayBitCoinRateFromServer()
         XCTAssertNotNil(fetchDataTodayDataFomSharedContainer)
    }
    func fetchDataTodayDataFomSharedContainer()-> TodayCoinModel?{
     return SharedData.init().fetchDataFromSharedContainer()
    }
    
    //MARK: Last two weeks data
    func testForOldDatesWithDifferentCurrency(){
        // Here we check the coin rate the for Last two weeks for different currency is not same w also currency code is different
        //By default it will always take Euro

        let euro = viewModal?.previousDaysRateCoin?.value?.list.values.first
        viewModal?.changeCurrencyCode(CurrencyCodes.GBP.rawValue)
        let gbp = viewModal?.previousDaysRateCoin?.value?.list.values.first
        XCTAssertNotEqual(euro, gbp)
        
    }
    func testNotUpdatingOldDataAfter60Seconds(){
        //First we will put on sleep to 5 seconds so, that we get the response from server, otherwise it will read data from shared container, if available
        sleep(5)
        // Check initial value of coin on first time service call
        let intialValue = viewModal?.previousDaysRateCoin?.value?.time
        
        //Now we will wait for 65 secs and check for data change
        sleep(65)
        
        // We will compare string , which stores last updated date
        let finalValue = viewModal?.previousDaysRateCoin?.value?.time
        
        XCTAssertEqual(intialValue, finalValue)
    }
    
    func testDataDecodeForWrongObject() {
      // here we check that if we pass wrong Mapper object
        checkForResponse { (data, error) in
            do{
             XCTAssertThrowsError(try JSONDecoder().decode(Coins.self, from: data), "", { (error) in
                
                XCTFail("Will always Failed because of wrong mapper object class")
            })
            }
            catch{
                
            }
            }
      
    }
   
    func checkForResponse(completion: @escaping (Data,Error?)->Void){
        NetworkHandler.callWebServicefor(ApiType.Today.rawValue) { (response) in
            switch response{
                
            case .success(let data):
                completion(data,nil)
                
            default:
                print("Ignore")
            }
          }
    }
    func testExample() {
       
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        
        self.measure {
            // Put the code you want to measure the time of here.
            viewModal?.fetchTodayBitCoinRateFromServer()
            
        }
    }
    func testPerformanceForTodayServiceResponse() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
            for _ in 0 ... 5{
                viewModal?.fetchTodayBitCoinRateFromServer()
                
            }
        }
    }
}
