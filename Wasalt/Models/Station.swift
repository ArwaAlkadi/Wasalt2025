//
//  Station 2.swift
//  Wasalt
//
//  Created by Rana Alqubaly on 12/06/1447 AH.
//



//بيانات واحداثيات مواقع محطات المترو

// Models/Place.swift
import Foundation
import CoreLocation

struct Station: Identifiable {
    let id = UUID()
    let name: String
    let order: Int              // position along the line
    let coordinate: CLLocationCoordinate2D
    let minutesToNext: Int?     // travel time to the next station
}