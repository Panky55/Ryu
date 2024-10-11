//
//  AppDelegate.swift
//  Ryu
//
//  Created by Francesco on 20/06/24.
//

import UIKit
import AVFoundation

#if canImport(GoogleCast)
import GoogleCast
#endif

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var backgroundCompletionHandler: (() -> Void)?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupDefaultUserPreferences()
        setupGoogleCast()
        
        return true
    }
    
    private func setupDefaultUserPreferences() {
        let defaultValues: [String: Any] = [
            "selectedMediaSource": "AnimeWorld",
            "AnimeListingService": "AniList",
            "maxRetries": 10,
            "holdSpeedPlayer": 2,
            "preferredQuality": "1080p",
            "subtitleHiPrefe": "English",
            "serverHiPrefe": "hd-1",
            "audioHiPrefe": "Always Ask",
            "syncWithSystem": true
        ]
        
        for (key, value) in defaultValues {
            if UserDefaults.standard.object(forKey: key) == nil {
                UserDefaults.standard.set(value, forKey: key)
            }
        }
        
        if UserDefaults.standard.object(forKey: "accessToken") != nil {
            UserDefaults.standard.removeObject(forKey: "accessToken")
        }
        
        UserDefaults.standard.register(defaults: [
            "fullTitleCast": true,
            "animeImageCast": true
        ])
        
        if UserDefaults.standard.string(forKey: "mediaPlayerSelected") == "Experimental" {
            UserDefaults.standard.set("Custom", forKey: "mediaPlayerSelected")
        }
    }
    
    private func setupGoogleCast() {
        #if os(iOS)
        let options = GCKCastOptions(discoveryCriteria: GCKDiscoveryCriteria(applicationID: kGCKDefaultMediaReceiverApplicationID))
        GCKCastContext.setSharedInstanceWith(options)
        #endif
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if url.scheme == "ryu" {
            if let queryParams = url.queryParameters, let code = queryParams["code"] {
                NotificationCenter.default.post(name: Notification.Name("AuthorizationCodeReceived"), object: nil, userInfo: ["code": code])
            }
        }
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        backgroundCompletionHandler = completionHandler
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        UserDefaults.standard.set(false, forKey: "isToDownload")
        deleteTemporaryDirectory()
    }
    
    func deleteTemporaryDirectory() {
        let fileManager = FileManager.default
        let tmpURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        
        do {
            let tmpContents = try fileManager.contentsOfDirectory(at: tmpURL, includingPropertiesForKeys: nil, options: [])
            
            for fileURL in tmpContents {
                try fileManager.removeItem(at: fileURL)
            }
        } catch {
            print("Error clearing tmp folder: \(error.localizedDescription)")
        }
    }
}
