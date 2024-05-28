/*
 E5MapData
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation
import CloudKit
import E5Data
import E5PhotoLib

#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif


public protocol AppLoaderDelegate{
#if os(macOS)
    func startSpinner() -> NSProgressIndicator
    func stopSpinner(_ spinner : NSProgressIndicator?)
#elseif os(iOS)
    func startSpinner() -> UIActivityIndicatorView
    func stopSpinner(_ spinner: UIActivityIndicatorView?)
    #endif
    func dataChanged()
}

public struct AppLoader{
    
    public static var delegate: AppLoaderDelegate? = nil
    
    public static func initialize(){
        loadPreferences()
        loadAppState()
    }
    
    public static func loadPreferences(){
        if let prefs : Preferences = UserDefaults.standard.load(forKey: Preferences.storeKey){
            Preferences.shared = prefs
        }
        else{
            Log.info("no saved data available for preferences")
            Preferences.shared = Preferences()
        }
    }
    
    public static func loadAppState(){
        if let state : AppState = UserDefaults.standard.load(forKey: AppState.storeKey){
            AppState.shared = state
        }
        else{
            Log.info("no saved data available for state")
            AppState.shared = AppState()
        }
    }
    
    public static func loadData(delegate: AppLoaderDelegate? = nil){
        //Log.debug("loading from user defaults")
        loadFromUserDefaults()
        if Preferences.shared.useICloud{
            CKContainer.default().accountStatus(){ status, error in
                if status == .available{
                    //Log.debug("loading from iCloud")
                    DispatchQueue.main.async{
                        loadDataFromICloud(delegate: delegate)
                    }
                }
                else{
                    Log.warn("iCloud not available")
                }
            }
        }
    }
    
    public static func loadDataFromICloud(delegate: AppLoaderDelegate? = nil){
        let synchronizer = CloudSynchronizer()
        let spinner = delegate?.startSpinner()
        Task{
            try await synchronizer.synchronizeFromICloud(deleteLocalData: false)
            DispatchQueue.main.async{
                delegate?.stopSpinner(spinner)
                delegate?.dataChanged()
            }
            AppData.shared.saveLocally()
        }
    }
    
    public static func loadFromUserDefaults(){
        AppData.shared.loadLocally()
    }
    
    public static func saveInitalizationData(){
        AppState.shared.save()
        Preferences.shared.save()
    }
    
    public static func saveData(delegate: AppLoaderDelegate? = nil){
        if Preferences.shared.useICloud{
            let spinner = delegate?.startSpinner()
            let synchronizer = CloudSynchronizer()
            Task{
                try await synchronizer.synchronizeToICloud(deleteICloudData: true)
                AppData.shared.saveLocally()
                DispatchQueue.main.async{
                    self.delegate?.stopSpinner(spinner)
                }
            }
        }
        else{
            AppData.shared.saveLocally()
        }
    }
    
}
