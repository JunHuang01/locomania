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
    @IBOutlet weak var Timer: UILabel!
    
    var locationManager: CLLocationManager!
    
    var currUserLocation: CLLocation!
    
    var currTimeSinceLastPush: Int!
    
    let PUSH_INTERVAL = 60*5;  //Time in seconds for how long between push
    
    var pushCount: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                // Do any additional setup after loading the view, typically from a nib.
        self.setUpLocationManager();
        
        currTimeSinceLastPush = 0;
        pushCount = 0;
        
        self.timerUpdate();
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
        LatValue.text = "\(location.coordinate.latitude)";
        LongValue.text = "\(location.coordinate.longitude)";
        currUserLocation = location;
    }
    
    
    //recursive function that starts background thread every other 1 seconds to serve the time.
    func timerUpdate(){
        let delay = 1 * Double(NSEC_PER_SEC);
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay));
        dispatch_after(time, dispatch_get_main_queue()){
            self.currTimeSinceLastPush = self.currTimeSinceLastPush + 1;
            if (self.currTimeSinceLastPush > self.PUSH_INTERVAL ){
                self.currTimeSinceLastPush = 0;
                self.pushLocationToServer(self.currUserLocation);
            }
            self.Timer.text = String(self.currTimeSinceLastPush);
            self.timerUpdate();
        }
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

