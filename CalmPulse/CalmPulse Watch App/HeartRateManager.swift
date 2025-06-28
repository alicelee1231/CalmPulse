import Foundation
import HealthKit
import Combine

class HeartRateManager: ObservableObject {
    private var healthStore = HKHealthStore()
    private var query: HKAnchoredObjectQuery?
    @Published var heartRate: Double = 0.0
    var isTestMode: Bool = false
    private var timer: Timer?

    init(isTestMode: Bool = false) {
        self.isTestMode = isTestMode
        if isTestMode {
            startDummyData()
        } else {
            requestAuthorization()
        }
    }

    func startDummyData() {
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            self.heartRate = Double(Int.random(in: 70...120))
        }
    }

    func requestAuthorization() {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        healthStore.requestAuthorization(toShare: [], read: [heartRateType]) { success, error in
            if success {
                self.startHeartRateQuery()
            }
        }
    }

    func startHeartRateQuery() {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictEndDate)
        query = HKAnchoredObjectQuery(type: heartRateType, predicate: predicate, anchor: nil, limit: HKObjectQueryNoLimit) { [weak self] _, samples, _, _, _ in
            self?.process(samples: samples)
        }
        query?.updateHandler = { [weak self] _, samples, _, _, _ in
            self?.process(samples: samples)
        }
        if let query = query {
            healthStore.execute(query)
        }
    }

    private func process(samples: [HKSample]?) {
        guard let samples = samples as? [HKQuantitySample] else { return }
        DispatchQueue.main.async {
            if let sample = samples.last {
                self.heartRate = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
            }
        }
    }

    deinit {
        timer?.invalidate()
    }
} 