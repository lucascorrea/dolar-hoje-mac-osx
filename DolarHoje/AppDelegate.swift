//
//  AppDelegate.swift
//  DolarHoje
//
//  Created by Gustavo Barbosa on 9/10/15.
//  Copyright © 2015 Gustavo Barbosa. All rights reserved.
//

import Cocoa
import ServiceManagement

extension Double {
    /// Rounds the double to decimal places value
    func roundToPlaces(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return round(self * divisor) / divisor
    }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var loginOnStartupItem: NSMenuItem!
    var statusItem: NSStatusItem?
    
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
        statusItem?.menu = statusMenu
        statusItem?.highlightMode = true
        
        loginOnStartupItem.state = NSBundle.mainBundle().isLoginItem() ? NSOnState : NSOffState
        
        fetch()
        NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: #selector(AppDelegate.fetch), userInfo: nil, repeats: true)
    }
    
    func fetch() {
        let url: NSURL = NSURL(string: "http://api.promasters.net.br/cotacao/v1/valores")!
        let request: NSURLRequest = NSURLRequest(URL: url)
        let queue:NSOperationQueue = NSOperationQueue()
        NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler:{ (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
            
            if let responseData = data {
                do {
                    
                    let json = try NSJSONSerialization.JSONObjectWithData(responseData, options: NSJSONReadingOptions.AllowFragments)
                    
                    
                    print(json)
                    
                    let dolar = json["valores"]!!["USD"]!!["valor"] as! Double
                    let euro = json["valores"]!!["EUR"]!!["valor"]! as! Double
                    
                    let formatter = NSNumberFormatter()
                    formatter.minimumFractionDigits = 2
                    
                    let title = "D: R$ \(formatter.stringFromNumber(dolar)!) | E: R$ \(formatter.stringFromNumber(euro)!)"
                    self.statusItem?.title = title
                } catch let error as NSError {
                    print(error)
                }
            }
        })
    }
    
    @IBAction func toggleLoginOnStartup(menuItem: NSMenuItem) {
        menuItem.state = menuItem.state == NSOnState ? NSOffState : NSOnState
        
        if menuItem.state == NSOnState {
            NSBundle.mainBundle().addToLoginItems()
        } else {
            NSBundle.mainBundle().removeFromLoginItems()
        }
    }
    
    @IBAction func quit(menuItem: NSMenuItem) {
        NSApplication.sharedApplication().terminate(self)
    }
}

