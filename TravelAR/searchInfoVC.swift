//
//  searchInfoVC.swift
//  TravelAR
//
//  Created by Muhammad Singdi on 9/17/17.
//  Copyright © 2017 Utkarsh Pandey. All rights reserved.
//

import UIKit

class searchInfoVC: UIViewController {
    
    @IBOutlet weak var originText: UITextField!
    @IBOutlet weak var destinationText: UITextField!
    @IBOutlet weak var departDate: UITextField!
    @IBOutlet weak var arrivalDate: UITextField!
    
    let AMADEUS_KEY = "Ph9ScLKVlkZuwZMoVOVo1nGPieUDU8If"
    var flightData:[FlightData] = []
    var activityind = UIActivityIndicatorView()
    
    
    @IBAction func submitPressed(_ sender: Any) {
        
        if originText.text! == "" || destinationText.text! == "" || departDate.text! == "" || arrivalDate.text! == "" {
            createAlert(title: "At least one of the fields is empty", message: "Please fill in all the information!")
        }
        
        // Begin ignoring interactions
        self.activityind = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        self.activityind.center = self.view.center
        self.activityind.hidesWhenStopped = true
        self.activityind.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        self.activityind.startAnimating()
        self.view.addSubview(self.activityind)
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        self.sendRequest(origin: self.originText.text!, destination: self.destinationText.text!, departDate: self.departDate.text!)

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4), execute: {
            // Put your code which should be executed with a delay here
            self.performSegue(withIdentifier: "goToAR", sender: self)
            if self.activityind.isAnimating{
                print("it's animating")
                self.activityind.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
                self.performSegue(withIdentifier: "goToAR", sender: self)
            }
        })
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToAR" {
            if let destVC = segue.destination as? ViewController {
                destVC.flightData = flightData
            }
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
            
            guard let res = json!["results"] as? NSArray else { print ("results failed \n \(json!)") ; return }
            
            let count = min(res.count, 10)
            for i in 0..<count {
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
                
                guard let totalPrice = fare["total_price"] as? String else { print ("failed total price"); return}
                
                guard let PPA = fare["price_per_adult"] as? NSDictionary else { print ("failed PPA"); return}
                
                guard let ppa_tax = PPA["tax"] as? String else { print("failed ppa_tax"); return}
                
                guard let ppa_total = PPA["total_fare"] as? String else { print("failed ppa_total"); return}
                
                
                self.flightData.append(FlightData(fn: operating_airline + aircraft, fd: depart_at, ftp: totalPrice, fpp: ppa_total, ft: ppa_tax, fde: destination, frg: origin, fdt: destination, frgt: origin))
            }
        }
        task.resume()
        return
    }
    
    
    func createAlert(title: String, message :String){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: {
            (action) in
            
            alert.dismiss(animated: true, completion: nil)
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
}
