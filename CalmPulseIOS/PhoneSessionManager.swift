import Foundation
import WatchConnectivity
import UIKit

class PhoneSessionManager: NSObject, WCSessionDelegate {
    static let shared = PhoneSessionManager()
    override private init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    // 필수 delegate 메서드
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {}
    // 이미지 전송
    func sendImageToWatch(image: UIImage) {
        if let data = image.jpegData(compressionQuality: 0.8) {
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("photo.jpg")
            try? data.write(to: tempURL)
            WCSession.default.transferFile(tempURL, metadata: nil)
        }
    }
} 