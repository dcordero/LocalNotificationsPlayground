import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func applicationDidFinishLaunching(_ application: UIApplication) {
        setUpWindow()
        registerForLocalNotifications()
        scheduleLocalNotification()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        clearBadge()
    }
    
    // MARK: - Private
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    private func setUpWindow() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = ViewController()
        window?.makeKeyAndVisible()
    }
    
    private func registerForLocalNotifications() {
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound], completionHandler: {
            granted, _ in
            
            if (granted) {
                print("auth request granted")
            }
            else {
                print("auth request NOT granted")
            }
        })
    }
    
    private func scheduleLocalNotification() {
        notificationCenter.delegate = self
        
        let content = UNMutableNotificationContent()
        content.badge = 1
        
        #if !os(tvOS)
        content.body = "Hi there, I am a local notification"
        content.sound = .default
        #endif
        
        content.userInfo = [
            "custom key 1": "custom value 1",
            "custom key 2": "custom value 2",
            "custom key 3": "custom value 3"
        ]
        
        let date = Date(timeInterval: 5, since: Date())
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        notificationCenter.add(request) {
            error in
            if let error = error {
                print("Error: \(error)")
            }
        }
    }
    
    private func clearBadge() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        print(">> userNotificationCenter:willPresentNotification")
        
        #if os(tvOS)
        
        completionHandler(.badge)
        
        #else
        completionHandler([.alert, .sound, .badge])
        
        let userInfo = notification.request.content.userInfo
        print("UserInfo: \(userInfo)")
        
        #endif
    }
    
    #if !os(tvOS)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        print(">> userNotificationCenter: didReceiveResponse")
        
        let userInfo = response.notification.request.content.userInfo
        print("UserInfo: \(userInfo)")
        
        completionHandler()
    }
    #endif
}
