import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  
    let center = UNUserNotificationCenter.current()
    var deviceToken : String = ""
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        
        let pushNotificationChannel = FlutterMethodChannel(name: AppConstants.CHANNEL_NOTIFICATION, binaryMessenger: controller.binaryMessenger)
        
        pushNotificationChannel
            .setMethodCallHandler{ [weak self] (
                call: FlutterMethodCall,
                result: @escaping FlutterResult
            ) in
                switch call.method {
                case AppConstants.REQUEST_NOTIFICATION_PERMISSION:
                    self?.registerForPushNotifications()
                case AppConstants.REGISTER_FOR_PUSH_NOTIFICATION:
                    self?.registerForPushNotifications(application: application, result: result)
                case AppConstants.RETRIEVEDEVICETOKEN:
                    self?.getDeviceToken(result: result)
                default:
                    result(FlutterMethodNotImplemented)
                }
            }
        
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
    }
    
    private func registerForPushNotifications(application: UIApplication, result: @escaping FlutterResult) {
        application.registerForRemoteNotifications()
        result("Device Token registration initiated")
    }
    
    private func getDeviceToken(result: @escaping FlutterResult) {
        if(deviceToken.isEmpty){
            result(FlutterError(code: "UNAVAILABLE", message: "Device token not available", details: nil))
        } else{
            result(deviceToken)
        }
    }
    
    
    func registerForPushNotifications() {
        center.delegate = self
        center.requestAuthorization(options: [.alert,.sound,.badge,]) {
            [weak self](granted,error) in
            guard let self = self else { return }
            self.getNotificationSettings()
        }
    }

    func getNotificationSettings() {
        center
            .getNotificationSettings { [weak self] settings in
                guard let self = self else {
                    return
                }
                self.setupNotificationSetting(
                    settings: settings
                )
            }
    }

    func setupNotificationSetting(
        settings: UNNotificationSettings
    ) {
        if settings.authorizationStatus == .authorized {
            DispatchQueue.main
                .async {
                    UIApplication.shared
                        .registerForRemoteNotifications()
                }
        } else {

        }
    }

    override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (
            UNNotificationPresentationOptions
        ) -> Void
    ) {
        print("----- debug ----- willPresent")
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .list, .sound, .badge])
        } else {
            completionHandler([.alert, .sound, .badge])
        }
    }

    override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        print("----- debug ----- didReceive \(response.notification)")
        let userInfo = response.notification.request.content.userInfo
        // handle on press notification
        handleNotification(userInfo: userInfo)
        completionHandler()
    }
    
    private func handleNotification(userInfo: [AnyHashable: Any]) {
        //
        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        //        let pushNotificationChannel = FlutterMethodChannel(name: AppConstants.CHANNEL_NOTIFICATION,binaryMessenger: controller.binaryMessenger)
        //        
        //        
        //        if let aps = userInfo["aps"] as? [String: Any],
        //           let customData = aps["customData"] as? String {
        //            print("----- debug ----- handle Notfi \(customData)")
        //            pushNotificationChannel.invokeMethod(AppConstants.METHOD_PUSH_NOTIFICATION, arguments: customData)
        //        }
        
    }
}
