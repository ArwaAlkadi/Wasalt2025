//
//  GuideMe.swift
//  Wasalt
//
//  Created by Arwa Alkadi on 02/01/2026.
//
//  Project Explanation
//  This file is for documentation purposes only.
//  It does not contain executable code.
//

/*

==================================================
WASALT PROJECT EXPLANATION
==================================================

This document explains the Wasalt application in a clear and easy-to-read way.
It describes how the project components are connected, how trips are tracked,
how notifications work, how wrong-direction detection works, and why a trip
expiration time is used.

==================================================
1️⃣ APP OVERVIEW
==================================================

Wasalt helps users during metro trips.

USER FLOW:
- Select a metro line
- Select a destination station
- Start trip tracking based on user location

THE APP DISPLAYS:
- Start station
- Stations between start and destination
- Estimated Time of Arrival (ETA)

THE APP NOTIFIES THE USER:
- When approaching the destination
- When arriving
- When a wrong direction is detected

The app is designed to work reliably even in the background,
so it relies on Geofencing to trigger notifications.

--------------------------------------------------
APP FLOW – HIGH LEVEL OVERVIEW
--------------------------------------------------

User selects line & destination
        ↓
MetroTripViewModel
- Determines start station
- Determines direction
- Calculates ETA
- Tracks remaining stations
        ↓
User location updates
        ↓
LocationManager
- Updates userLocation
- Monitors geofence regions
        ↓
Geofence events (Enter Region)
        ↓
LocalNotificationManager
- Schedules system notifications
        ↓
System Notification (Background)
OR
In-App Banner (Foreground)

==================================================
2️⃣ PROJECT STRUCTURE (XCODE)
==================================================

APP
--------------------------------------------------
- WasaltApp.swift
  Entry point of the application.
  Displays RootAppView.
  Contains String.localized extension for localization.

- RootAppView.swift
  Controls the initial app flow.
  Shows SplashView first.
  Navigates to MainView or OnboardingView.

MODELS
--------------------------------------------------
- Station.swift
  Represents a metro station.
  Contains:
  - name
  - order within the line
  - coordinates
  - minutes to next / previous station
  - transfer station flag
  - available transfer lines

- MetroLine.swift
  Enum representing metro lines.
  Each line has:
  - color
  - list of stations
  - localized display name

  Helpers:
  - uniqueByCoordinate
  - init(geoJSONName)
  - Station.cleanName

- MetroData.swift
  Holds station lists for each line.
  Provides allStations merged by coordinates.

MANAGERS
--------------------------------------------------
- LocationManager.swift
  Handles:
  - GPS updates
  - Geofencing
  - userLocation updates
  - region entry monitoring
  - trip expiration logic

- LocalNotificationManager.swift
  Responsible for local notifications:
  - Approaching
  - Arrival
  - Wrong direction
  Uses UNLocationNotificationTrigger.

- InAppAlertManager / AppAlertManager
  Manages in-app banners.
  Displays arrival, approaching, and wrong-direction alerts.

VIEW MODELS
--------------------------------------------------
- PermissionsViewModel.swift
  Handles:
  - Location permission
  - Notification permission
  Opens system settings when needed.

- MetroTripViewModel.swift
  Core trip logic.
  Manages:
  - destination selection
  - start station detection
  - trip direction
  - ETA calculation
  - remaining stations
  - wrong direction detection

- MapViewModel.swift
  Prepares map data.
  Manages polylines and station annotations.

VIEWS
--------------------------------------------------
- MainView.swift
  Main screen with the map.
  Displays stations and colored routes.
  Presents sheets:
  - MetroLinesSheet
  - StationSheetView
  - TrackingSheet
  - ArrivedSheet

- MetroLinesSheet.swift
  Displays available metro lines.
  Optionally shows nearest station.
  Calls metroVM.filterStations(for:).

- StationSheetView.swift
  Displays stations of selected line.
  Allows destination selection.
  Starts trip via metroVM.startTrip().

- TrackingSheet.swift
  Displays:
  - start station
  - middle stations
  - destination
  - ETA
  Shows transfer indicators.
  Allows ending or changing the trip.

- ArrivedSheet.swift
  Shown when the user arrives.
  Confirms arrival.

==================================================
3️⃣ TRIP FLOW
==================================================

1) Line Selection
User selects a line in MetroLinesSheet.
metroVM.filterStations(for:) sets active stations.

2) Destination Selection
User selects a station using:
metroVM.selectDestination(station)

3) Start Trip
On “Start Trip”:
- Permissions are checked.
- User location is passed to:
  metroVM.startTrip(userLocation:)

==================================================
4️⃣ PREVENTING WRONG LINE START
==================================================

The app calculates:
- Nearest station from all stations.
- Nearest station within selected line.

If they are not the same physical station:
- Trip is blocked.
- A message is shown.

This prevents incorrect ETA and direction calculations.

==================================================
5️⃣ DIRECTION & ETA CALCULATION
==================================================

Direction:
- dest.order > start.order → Forward
- dest.order < start.order → Backward

ETA:
- minutesToNext for forward
- minutesToPrevious for backward

==================================================
6️⃣ TRIP PROGRESS UPDATES
==================================================

- LocationManager updates userLocation.
- MainView forwards updates to:
  metroVM.userLocationUpdated()

MetroTripViewModel:
- Determines nearest station
- Updates ETA and remaining stations
- Checks approaching and arrival conditions

==================================================
7️⃣ NOTIFICATIONS & GEOFENCING
==================================================

Two mechanisms are used:

1) Location-based notifications
- UNLocationNotificationTrigger
- Triggered by iOS
- Works in background

2) Time-based fallback notifications
- Triggered after region entry
- Used as a safety fallback

==================================================
8️⃣ GEOFENCE REGIONS
==================================================

Approaching:
- Radius: 500m
- Triggers approaching notification

Arrival:
- Radius: 250m
- Triggers arrival notification
- Stops geofences

Wrong Direction:
- Radius: 500m (opposite station)
- Triggers wrong-direction alert
- Used for system + in-app banners

==================================================
9️⃣ WRONG DIRECTION DETECTION
==================================================

Two methods:
- Geofence-based detection
- ViewModel order comparison

Alert is shown once per trip.

==================================================
🔟 TRIP EXPIRATION
==================================================

Purpose:
- Prevent long-running geofences
- Reduce battery usage
- Avoid delayed notifications
- Keep app in a valid state

Implementation:
- Duration: 2.5 hours
- Checked every 15 seconds
- On expiration:
  - Stop geofences
  - Cancel notifications
  - Reset trip state

==================================================
1️⃣1️⃣ IN-APP ALERTS
==================================================

MainView observes:
metroVM.activeAlert

Displays:
- Arrival
- Approaching
- Wrong direction

Alert is cleared using:
metroVM.clearActiveAlert()

==================================================
1️⃣2️⃣ LOCALIZATION
==================================================

Localization files:
- Localizable (English)
- Localizable (Arabic)

Accessed using:
"key".localized

Metro line names use:
MetroLine.displayName

==================================================
SUMMARY
==================================================

- MetroTripViewModel: trip logic brain
- LocationManager: GPS, geofencing, lifecycle
- LocalNotificationManager: background notifications
- MainView: map, sheets, alerts integration

==================================================
END OF EXPLANATION
==================================================

*/
