//
//  ViewController.swift
//  locomania
//
//  Created by Jun Huang on 3/31/15.
//  Copyright (c) 2015 Jun Huang. All rights reserved.
//

import UIKit

import CoreLocation

class ViewController: UIViewController , CLLocationManagerDelegate {

    @IBOutlet weak var LatValue: UILabel!
    @IBOutlet weak var LongValue: UILabel!
    @IBOutlet weak var TimestampOfLastPush: UILabel!
    @IBOutlet weak var PushCountLabel: UILabel!
    
    
    var locationManager: CLLocationManager!
    
    var currUserLocation: CLLocation!
    
    let PUSH_INTERVAL = 60*5;  //Time in seconds for how long between push
    
    var pushCount: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                // Do any additional setup after loading the view, typically from a nib.
        self.setUpLocationManager();
        
        pushCount = 0;
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //sets up location manager, and ask user for permission to use app location.
    func setUpLocationManager(){
        locationManager = CLLocationManager();
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization();
        locationManager.startUpdatingLocation();
        println("started");

    }


    //This overrides the location manager update function, this determines what to do with new location data.
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!){
        var location:CLLocation = locations[locations.count-1] as CLLocation;
        println("locations = \(locations)");
        self.LatValue.text = "\(location.coordinate.latitude)";
        self.LongValue.text = "\(location.coordinate.longitude)";
        let bInitPush = self.currUserLocation == nil
        self.currUserLocation = location;
        
        if(bInitPush){
            self.timerUpdate()
        }
    }
    
    
    //recursive function that starts background thread every other 1 seconds to serve the time.
    func timerUpdate(){
        self.pushLocationToServer(self.currUserLocation);
        self.TimestampOfLastPush.text = self.getCurrentTimestamp();
        self.PushCountLabel.text = "Total PushCount: \(self.pushCount)"
        let delay = Double(self.PUSH_INTERVAL) * Double(NSEC_PER_SEC);
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay));
        dispatch_after(time, dispatch_get_main_queue()){
            self.timerUpdate();
        }
    }
    
    func getCurrentTimestamp() -> String {
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components( .CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay | .CalendarUnitHour | .CalendarUnitMinute | .CalendarUnitSecond , fromDate: date)
        let currTime = NSCalendar.currentCalendar().dateFromComponents(components)
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.MediumStyle
        
        return dateFormatter.stringFromDate(currTime!)
    }

    
    func pushLocationToServer(location: CLLocation){
        self.pushCount = self.pushCount + 1;
        let url = NSURL(string: "http://myurl:8888/pushLatLong/\(self.pushCount)/\(location.coordinate.latitude)/\(location.coordinate.longitude)")
        let request = NSURLRequest(URL: url!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {(response, data, error) in
            println(NSString(data: data, encoding: NSUTF8StringEncoding))
        }
    }
}

