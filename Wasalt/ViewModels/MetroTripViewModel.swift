//
//  MetroTripViewModel.swift
//  Wasalt
//
//  Created by Arwa Alkadi on 19/11/2025.
//
import SwiftUI
import MapKit
import AVFoundation
import Combine


/*
 🔴 File Contents | محتوى الكود
     •    MetroTripViewModel → handles trip flow, ETA updates, and arrival logic.
     •    InAppAlertManager → manages in-app alerts (banner + vibration + flash).
     •    LocalNotificationManager → sends local notifications (arrival/approaching + backup timers).
 */


// MARK: - MetroTripViewModel → handles trip flow, ETA updates, and arrival logic.
final class MetroTripViewModel: ObservableObject {
    
    private let stations: [Station]
    private let notificationManager: LocalNotificationManager
    
    @Published var selectedDestination: Station?
    @Published var isTracking: Bool = false
    @Published var startStation: Station?
    @Published var currentNearestStation: Station?
    @Published var lastPassedStation: Station?
    @Published var nextStation: Station?
    @Published var stationsRemaining: Int = 0
    @Published var etaMinutes: Int = 0
    @Published var statusText: String = ""
    @Published var showArrivalSheet: Bool = false
    @Published var activeAlert: MetroAlertType? = nil
    @Published var upcomingStations: [Station] = []
    
    /// الوصول الفعلي للمحطة (≈ 120 م)
    private let arrivalDistance: CLLocationDistance = 120.0
    /// بداية «الاقتراب» من المحطة (≈ كم)
    private let approachingDistance: CLLocationDistance = 500.0
    
    private enum TripDirection { case forward, backward }
    private var tripDirection: TripDirection?
    private var didFireApproachingAlert = false
    private var didFireArrivalAlert = false
    private var isChangingDestination: Bool = false
    
    init(
        stations: [Station],
        notificationManager: LocalNotificationManager = .shared
    ) {
        self.stations = stations
        self.notificationManager = notificationManager
    }
    
    func selectDestination(_ station: Station) {
        selectedDestination = station
    }
    
    // - Start Trip
    func startTrip(userLocation: CLLocation?) {
        guard let dest = selectedDestination else {
            statusText = "sheet.status.chooseDestination".localized
            return
        }
        
        if isChangingDestination {
            guard let baseStation = lastPassedStation ?? startStation else {
                statusText = "ما قدرنا نعرف آخر محطة ركبت منها."
                return
            }
            startStation = baseStation
            
            if dest.order == baseStation.order {
                currentNearestStation = dest
                stationsRemaining = 0
                etaMinutes = 0
                nextStation = nil
                upcomingStations = []
                
                statusText = String(
                    format: "status.alreadyAtDestination".localized,
                    dest.name
                )
                
                isTracking = false
                notificationManager.cancelTripNotifications()
                // 👈 لا arrival sheet ولا in-app alert ولا إشعار محلي
                return
            }
            
            tripDirection = dest.order > baseStation.order ? .forward : .backward
            
            isTracking = true
            showArrivalSheet = false
            didFireApproachingAlert = false
            didFireArrivalAlert = false
            statusText = ""
            isChangingDestination = false
            
            let fakeLocation = CLLocation(latitude: baseStation.coordinate.latitude,
                                          longitude: baseStation.coordinate.longitude)
            
            notificationManager.scheduleLocationNotifications(for: dest)
            
            updateProgress(for: fakeLocation)
            return
        }
        
        guard let location = userLocation else {
            statusText = "sheet.status.noLocation".localized
            return
        }
        
        guard let startSt = nearestStation(to: location) else {
            statusText = "ما قدرنا نحدد أقرب محطة."
            return
        }
        
        startStation = startSt
        lastPassedStation = startSt
        
        if dest.order == startSt.order {
            currentNearestStation = dest
            stationsRemaining = 0
            etaMinutes = 0
            nextStation = nil
            upcomingStations = []
            
            statusText = String(
                format: "status.alreadyAtDestination".localized,
                dest.name
            )
            
            isTracking = false
            notificationManager.cancelTripNotifications()
            return
        }
        
        tripDirection = dest.order > startSt.order ? .forward : .backward
        
        isTracking = true
        showArrivalSheet = false
        didFireApproachingAlert = false
        didFireArrivalAlert = false
        statusText = ""
        
        notificationManager.scheduleLocationNotifications(for: dest)
        
        updateProgress(for: location)
    }
    
    func userLocationUpdated(_ location: CLLocation?) {
        guard isTracking, let location = location else { return }
        updateProgress(for: location)
    }
    
    func endTripAndReset() {
        isTracking = false
        resetProgress(keepDestination: false)
        statusText = ""
        notificationManager.cancelTripNotifications()
    }
    
    func cancelAndChooseAgain() {
        isTracking = false
        
        if let current = currentNearestStation {
            lastPassedStation = current
        }
        
        selectedDestination = nil
        nextStation = nil
        stationsRemaining = 0
        etaMinutes = 0
        upcomingStations = []
        showArrivalSheet = false
        tripDirection = nil
        didFireApproachingAlert = false
        didFireArrivalAlert = false
        activeAlert = nil
        statusText = ""
        isChangingDestination = true
        notificationManager.cancelTripNotifications()
    }
    
    func clearActiveAlert() {
        activeAlert = nil
    }
    
    var middleStations: [Station] {
        guard
            let start = startStation,
            let dest  = selectedDestination
        else { return [] }
        
        if dest.order > start.order {
            return stations
                .filter { $0.order > start.order && $0.order < dest.order }
                .sorted { $0.order < $1.order }
        } else if dest.order < start.order {
            return stations
                .filter { $0.order < start.order && $0.order > dest.order }
                .sorted { $0.order > $1.order }
        } else {
            return []
        }
    }
    
    func isStationReached(_ station: Station) -> Bool {
        guard let direction = tripDirection else { return false }
        
        let refOrder: Int? =
            lastPassedStation?.order ??
            currentNearestStation?.order ??
            startStation?.order
        
        guard let currentOrder = refOrder else { return false }
        
        switch direction {
        case .forward:
            return station.order <= currentOrder
        case .backward:
            return station.order >= currentOrder
        }
    }
    
    private func updateProgress(for location: CLLocation) {
        guard let dest = selectedDestination,
              let nearest = nearestStation(to: location) else { return }
        
        if currentNearestStation?.order != nearest.order {
            lastPassedStation = nearest
        }
        currentNearestStation = nearest
        
        let result = computeRemainingStationsAndTime(from: nearest, to: dest)
        stationsRemaining = result.stations
        etaMinutes = result.minutes
        nextStation = result.next
        upcomingStations = computeUpcomingStations(from: nearest, to: dest)
        
        let destLocation = CLLocation(latitude: dest.coordinate.latitude,
                                      longitude: dest.coordinate.longitude)
        let distanceToDest = destLocation.distance(from: location)
        
        if distanceToDest <= arrivalDistance {
            statusText = "وصلت إلى محطتك \(dest.name)"
            isTracking = false
            showArrivalSheet = true
            upcomingStations = []
            
            if !didFireArrivalAlert {
                activeAlert = .arrival(stationName: dest.name)
                didFireArrivalAlert = true
                notificationManager.cancelTripNotifications()
            }
            return
        }
        
        statusText = ""
        
        if !didFireApproachingAlert,
           !didFireArrivalAlert,
           distanceToDest <= approachingDistance,
           distanceToDest > arrivalDistance {
            
            activeAlert = .approaching(
                stationName: dest.name,
                etaMinutes: etaMinutes
            )
            didFireApproachingAlert = true
        }
    }
    
    private func computeRemainingStationsAndTime(from current: Station, to dest: Station)
    -> (stations: Int, minutes: Int, next: Station?) {
        guard let direction = tripDirection else {
            let diff = abs(dest.order - current.order)
            return (diff, 0, nil)
        }
        
        var totalMinutes = 0
        var count = 0
        var next: Station?
        
        switch direction {
        case .forward:
            if current.order >= dest.order { return (0, 0, nil) }
            for order in current.order..<dest.order {
                if let st = stations.first(where: { $0.order == order }) {
                    if count == 0 {
                        next = stations.first(where: { $0.order == order + 1 })
                    }
                    totalMinutes += st.minutesToNext ?? 0
                    count += 1
                }
            }
        case .backward:
            if current.order <= dest.order { return (0, 0, nil) }
            for order in stride(from: current.order, to: dest.order, by: -1) {
                if let st = stations.first(where: { $0.order == order }) {
                    if count == 0 {
                        next = stations.first(where: { $0.order == order - 1 })
                    }
                    totalMinutes += st.minutesToNext ?? 0
                    count += 1
                }
            }
        }
        
        return (count, totalMinutes, next)
    }
    
    private func computeUpcomingStations(from current: Station, to dest: Station) -> [Station] {
        guard let direction = tripDirection else { return [] }
        
        switch direction {
        case .forward:
            guard current.order < dest.order else { return [] }
            return stations
                .filter { $0.order > current.order && $0.order <= dest.order }
                .sorted { $0.order < $1.order }
            
        case .backward:
            guard current.order > dest.order else { return [] }
            return stations
                .filter { $0.order < current.order && $0.order >= dest.order }
                .sorted { $0.order > $1.order }
        }
    }
    
    private func nearestStation(to location: CLLocation) -> Station? {
        stations.min { lhs, rhs in
            let lhsLoc = CLLocation(latitude: lhs.coordinate.latitude,
                                    longitude: lhs.coordinate.longitude)
            let rhsLoc = CLLocation(latitude: rhs.coordinate.latitude,
                                    longitude: rhs.coordinate.longitude)
            return lhsLoc.distance(from: location) < rhsLoc.distance(from: location)
        }
    }
    
    private func resetProgress(keepDestination: Bool) {
        if !keepDestination {
            selectedDestination = nil
            startStation = nil
            lastPassedStation = nil
        }
        currentNearestStation = nil
        nextStation = nil
        stationsRemaining = 0
        etaMinutes = 0
        upcomingStations = []
        showArrivalSheet = false
        tripDirection = nil
        didFireApproachingAlert = false
        didFireArrivalAlert = false
        activeAlert = nil
        isChangingDestination = false
    }
}










// MARK: - InAppAlertManager → manages in-app alerts (banner + vibration + flash)
final class InAppAlertManager: ObservableObject {
    @Published var isShowingBanner: Bool = false
    @Published var bannerMessage: String = ""
    @Published var isArrival: Bool = false
    
    private var flashTimer: Timer?
    private var isTorchOn: Bool = false
    private var isPatternRunning: Bool = false
    
    /// أقصى مدة للنمط (فلاش +/أو اهتزاز)
    private let maxPatternDuration: TimeInterval = 10
    /// مدة بقاء البانر قبل الاختفاء التلقائي
    private let bannerAutoDismiss: TimeInterval = 2 * 60
        
    func showApproaching(message: String) {
        bannerMessage = message
        isArrival = false
        showBanner(shouldUseFlash: false)
    }
    
    func showArrival(message: String) {
        bannerMessage = message
        isArrival = true
        showBanner(shouldUseFlash: true)
    }
    
    func dismiss() {
        isShowingBanner = false
        bannerMessage = ""
        stopPatternVibrationAndFlash()
    }
    
    
    private func showBanner(shouldUseFlash: Bool) {
        isShowingBanner = true
        startPatternVibrationAndFlash(useFlash: shouldUseFlash)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + bannerAutoDismiss) { [weak self] in
            guard let self = self, self.isShowingBanner else { return }
            self.dismiss()
        }
    }
    
    private func startPatternVibrationAndFlash(useFlash: Bool) {
        stopPatternVibrationAndFlash()
        isPatternRunning = true
        
        flashTimer = Timer.scheduledTimer(withTimeInterval: 0.35, repeats: true) { [weak self] _ in
            guard let self = self, self.isPatternRunning else { return }
            self.vibrateOnce()
            if useFlash {
                self.toggleTorch()
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + maxPatternDuration) { [weak self] in
            self?.stopPatternVibrationAndFlash()
        }
    }
    
    private func stopPatternVibrationAndFlash() {
        isPatternRunning = false
        flashTimer?.invalidate()
        flashTimer = nil
        setTorch(on: false)
    }
    
    private func vibrateOnce() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
    
    private func toggleTorch() {
        isTorchOn.toggle()
        setTorch(on: isTorchOn)
    }
    
    private func setTorch(on: Bool) {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                   for: .video,
                                                   position: .back),
              device.hasTorch else { return }
        do {
            try device.lockForConfiguration()
            if on {
                try device.setTorchModeOn(level: 1.0)
            } else {
                device.torchMode = .off
            }
            device.unlockForConfiguration()
        } catch {
            print("Torch error:", error.localizedDescription)
        }
    }
}

enum MetroAlertType: Equatable {
    case approaching(stationName: String, etaMinutes: Int)
    case arrival(stationName: String)
}










//MARK: -LocalNotificationManager → sends local notifications (arrival/approaching + backup timers).
final class LocalNotificationManager {
    
    static let shared = LocalNotificationManager()
    private init() {}
    
    func requestAuthIfNeeded() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in
            print("🔔 Notification auth granted? \(granted), error: \(String(describing: error))")
        }
    }
    
    func cancelTripNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [
                "approaching_notification",
                "arrival_notification"
            ]
        )
    }
    
    func scheduleLocationNotifications(for station: Station) {
        cancelTripNotifications()
        scheduleApproachingNotification(for: station)
        scheduleArrivalNotification(for: station)
    }
    
        private func scheduleApproachingNotification(for station: Station) {
        let content = UNMutableNotificationContent()
        content.title = String(
            format: "alert.approaching".localized,
            station.name
        )
        content.sound = .default
        
        let center = station.coordinate
        let region = CLCircularRegion(
            center: center,
            radius: 2000,
            identifier: "approaching_notification"
        )
        region.notifyOnEntry = true
        region.notifyOnExit  = false
        
        let trigger = UNLocationNotificationTrigger(region: region, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "approaching_notification",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Approaching notif error:", error.localizedDescription)
            } else {
                print("✅ Scheduled APPROACHING location notification for \(station.name)")
            }
        }
    }
    
    private func scheduleArrivalNotification(for station: Station) {
        let content = UNMutableNotificationContent()
        content.title = String(
            format: "alert.arrived".localized,
            station.name
        )
        content.sound = .default
        
        let center = station.coordinate
        let region = CLCircularRegion(
            center: center,
            radius: 120,
            identifier: "arrival_notification"
        )
        region.notifyOnEntry = true
        region.notifyOnExit  = false
        
        let trigger = UNLocationNotificationTrigger(region: region, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "arrival_notification",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Arrival notif error:", error.localizedDescription)
            } else {
                print("✅ Scheduled ARRIVAL location notification for \(station.name)")
            }
        }
    }

    func notifyApproaching(stationName: String) {
        let content = UNMutableNotificationContent()
        content.title = String(format: "alert.approaching".localized, stationName)
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let req = UNNotificationRequest(
            identifier: "approaching_notification_geofence",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(req, withCompletionHandler: nil)
    }

    func notifyArrival(stationName: String) {
        let content = UNMutableNotificationContent()
        content.title = String(format: "alert.arrived".localized, stationName)
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let req = UNNotificationRequest(
            identifier: "arrival_notification_geofence",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(req, withCompletionHandler: nil)
    }
}
