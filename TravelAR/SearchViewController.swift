//
//  searchInfoVC.swift
//  TravelAR
//
//  Created by Muhammad Singdi on 9/17/17.
//  Copyright © 2017 Utkarsh Pandey. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    @IBOutlet weak var originText: UITextField!
    @IBOutlet weak var destinationText: UITextField!
    @IBOutlet weak var departDate: UITextField!
    @IBOutlet weak var arrivalDate: UITextField!
    
    let AMADEUS_KEY = "Ph9ScLKVlkZuwZMoVOVo1nGPieUDU8If"
    var flightData:[FlightData] = []
    
    // Submit button press
    @IBAction func submitPressed(_ sender: Any) {
        sendRequest(origin: originText.text!, destination: destinationText.text!, departDate: departDate.text!)
        self.performSegue(withIdentifier: "goToAR", sender: self)
    }
    
    // Send flightData array to ARVIew
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToAR" {
//            let destinationVC = segue.destination as View
//            destinationVC.
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sendRequest(origin: String, destination: String, departDate: String)
    {
        let url_String = "https://api.sandbox.amadeus.com/v1.2/flights/low-fare-search?origin=" + origin + "&destination=" + destination + "&departure_date=" + departDate + "&apikey=" + AMADEUS_KEY
        let url = URL(string: url_String)
        let task = URLSession.shared.dataTask(with: url!)
        {
            data, response, error in
            guard error == nil else{
                print(error!)
                return
            }
            guard let data = data else {
                print("Data is empty")
                return
            }
            let json = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary

            guard let res = json!["results"] as? NSArray else { return }
            print(res.count)
            for i in 0..<10 {
                guard let result = res[i] as? NSDictionary else { print ("failed"); return }
                guard let fare = result["fare"] as? NSDictionary else { print ("failed fare"); return }
                guard let itinerary = result["itineraries"] as? NSArray else { print ("failed itinerary"); return }
                guard let itin1 = itinerary[0] as? NSDictionary else { print ("failed itin1"); return}
                guard let outbound = itin1["outbound"] as? NSDictionary else { print ("failed outbound"); return}
                
                guard let flights = outbound["flights"] as? NSArray else { print ("failed flights"); return}
                
                guard let flights1 = flights[0] as? NSDictionary else { print ("failed flights1"); return}
                
                guard let aircraft = flights1["aircraft"] as? String else { print ("failed aircraft"); return }
                
                guard let depart_at = flights1["departs_at"] as? String else { print ("failed depart at"); return }
                
                guard let operating_airline = flights1["operating_airline"] as? String else { print ("failed operating airline"); return}
                
                guard let totalPrice = fare["total_price"] as? String else {            print ("failed total price"); return}
                
                guard let PPA = fare["price_per_adult"] as? NSDictionary else { print ("failed PPA"); return}
                
                guard let ppa_tax = PPA["tax"] as? String else { print("failed ppa_tax"); return}
                
                guard let ppa_total = PPA["total_fare"] as? String else { print("failed ppa_total"); return}
                
                
                self.flightData.append(FlightData(fn: aircraft + " " + operating_airline, fd: depart_at, ftp: totalPrice, fpp: ppa_total, ft: ppa_tax, fde: destination, frg: origin, fdt: destination, frgt: origin))
            }
            
        }
        task.resume()
        return
    }
    
    @IBAction func travel_Info(_ sender: UIButton)
    {
        sendRequest(origin: "BOS", destination: "ORD", departDate: "2017-09-17")
    }
 

}
