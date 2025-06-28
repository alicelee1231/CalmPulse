import Foundation
import WatchConnectivity
import SwiftUI

class WatchSessionManager: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = WatchSessionManager()
    @Published var receivedImage: UIImage?

    override private init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    // iPhone에서 이미지 수신
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        let fileURL = file.fileURL
        if let data = try? Data(contentsOf: fileURL), let image = UIImage(data: data) {
            DispatchQueue.main.async {
                self.receivedImage = image
            }
        }
    }

    // 필수: WCSessionDelegate 프로토콜 구현 (필요 최소한)
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    func sessionReachabilityDidChange(_ session: WCSession) {}
} 