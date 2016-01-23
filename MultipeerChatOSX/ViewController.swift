//
//  ViewController.swift
//  MultipeerChatOSX
//
//  Created by Maria  Isabel on 1/23/16.
//  Copyright © 2016 UPC. All rights reserved.
//

import Cocoa
import AVFoundation
import MultipeerConnectivity

class ViewController: NSViewController, MCBrowserViewControllerDelegate, MCSessionDelegate {
    
    
    // create a sound ID, in this case its the tweet sound.
    let systemSoundID: SystemSoundID = 1003
    let serviceType = "multipeer-chat"
    var browser : MCBrowserViewController!
    var assistant : MCAdvertiserAssistant!
    var session : MCSession!
    var peerID: MCPeerID!
    
    @IBOutlet weak var messageField: NSTextField!
    @IBOutlet weak var chatView: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.peerID = MCPeerID(displayName: NSUserName())
        self.peerID = MCPeerID(displayName: "MacBookPro")
        self.session = MCSession(peer: peerID)
        self.session.delegate = self
        
        self.browser = MCBrowserViewController(serviceType: serviceType, session: self.session)
        self.browser.delegate = self
        
        self.assistant = MCAdvertiserAssistant(serviceType: serviceType, discoveryInfo: nil, session: self.session)
        self.assistant.start()
        

        // Do any additional setup after loading the view.
    }

    
    @IBAction func sendChat(sender: AnyObject) {
        let msg = self.messageField.stringValue.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        do{
            try self.session.sendData(msg!, toPeers: self.session.connectedPeers, withMode: MCSessionSendDataMode.Unreliable)
            self.updateChat(self.messageField.stringValue, fromPeer: self.peerID)
            self.messageField.stringValue = ""
        } catch{
            print("Error ocurred")
        }
    }
    
    func updateChat(text : String, fromPeer peerID: MCPeerID){
        var name : String
        
        switch(peerID){
        case self.peerID:
            name = "Me"
        default:
            name = peerID.displayName
            AudioServicesPlaySystemSound(systemSoundID)
        }
        
        let message = "\(name): \(text)\n"
        self.chatView.stringValue = self.chatView.stringValue + message
    }

    @IBAction func showBrowser(sender: AnyObject) {
        self.presentViewControllerAsModalWindow(self.browser)
    }
    
    func browserViewControllerDidFinish(browserViewController: MCBrowserViewController) {
        self.dismissViewController(self.browser)
    }
    
    func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController) {
        self.dismissViewController(self.browser)
    }

    func session(session: MCSession,
        didStartReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID, withProgress progress: NSProgress)  {
    }
    
    func session(session: MCSession,
        didFinishReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID,
        atURL localURL: NSURL, withError error: NSError?)  {
            // Called when a file has finished transferring from another peer
    }
    
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        dispatch_async(dispatch_get_main_queue()){
            let msg = NSString(data: data, encoding: NSUTF8StringEncoding)
            self.updateChat(msg! as String, fromPeer: peerID)
        }
    }
    
    func session(session: MCSession, didReceiveStream stream: NSInputStream,
        withName streamName: String, fromPeer peerID: MCPeerID)  {
            // Called when a peer establishes a stream with us
    }
    
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        switch state {
        case MCSessionState.Connected:
            print("Connected: \(peerID.displayName)")
            
        case MCSessionState.Connecting:
            print("Connecting: \(peerID.displayName)")
            
        case MCSessionState.NotConnected:
            print("Not Connected: \(peerID.displayName)")
        }
    }
   
    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

}

