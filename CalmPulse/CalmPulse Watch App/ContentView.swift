
import SwiftUI
import WatchKit

struct ContentView: View {
    @StateObject private var heartRateManager = HeartRateManager(isTestMode: false)
    @State private var baseHeartRate: Double = 75 // 기준 심박수
    @State private var isMeasuring: Bool = false
    @State private var measuredRates: [Double] = []
    @State private var measureTimer: Timer? = nil
    @State private var inputText: String = "75"
    @State private var didTriggerHaptic: Bool = false
    @StateObject private var sessionManager = WatchSessionManager.shared
    var threshold: Double { baseHeartRate * 1.2 }

    var body: some View {
        VStack {
            if heartRateManager.heartRate >= threshold {
                if let image = sessionManager.receivedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                } else {
                    Image("SampleImage")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                }
            } else {
                Image(systemName: "globe")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .foregroundStyle(.tint)
            }
            Text("심박수: \(Int(heartRateManager.heartRate)) bpm")
                .font(.title3)
                .padding(.top, 8)
            Text("기준 심박수: \(Int(baseHeartRate)) bpm, 20% 상승 임계값: \(Int(threshold)) bpm")
                .font(.footnote)
                .foregroundColor(.secondary)
            Text(heartRateManager.heartRate >= threshold ? "귀여운 이미지를 보며 진정하세요!" : "안정적인 상태입니다.")
                .font(.footnote)
                .foregroundColor(.secondary)
            Divider()
            HStack {
                TextField("직접 입력", text: $inputText)
                    .frame(width: 50)
                    .keyboardType(.numberPad)
                Button("설정") {
                    if let value = Double(inputText), value > 0 {
                        baseHeartRate = value
                    }
                }
            }
            .padding(.vertical, 4)
            Button(isMeasuring ? "측정 중..." : "자동 측정(1분)") {
                if !isMeasuring {
                    isMeasuring = true
                    measuredRates = []
                    measureTimer?.invalidate()
                    measureTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
                        measuredRates.append(heartRateManager.heartRate)
                    }
                    // 1분 후 평균값 저장
                    DispatchQueue.main.asyncAfter(deadline: .now() + 60) {
                        measureTimer?.invalidate()
                        if !measuredRates.isEmpty {
                            baseHeartRate = measuredRates.reduce(0, +) / Double(measuredRates.count)
                            inputText = String(Int(baseHeartRate))
                        }
                        isMeasuring = false
                    }
                }
            }
            .disabled(isMeasuring)
        }
        .padding()
        .onChange(of: heartRateManager.heartRate) { newValue in
            if newValue >= threshold && !didTriggerHaptic {
                WKInterfaceDevice.current().play(.notification)
                didTriggerHaptic = true
            } else if newValue < threshold {
                didTriggerHaptic = false
            }
        }
    }
}