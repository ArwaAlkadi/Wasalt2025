//
//  MetroData.swift
//  Wasalt
//
//  Created by Rana Alqubaly on 12/06/1447 AH.
//


import CoreLocation

struct MetroData {
    static let yellowLineStations: [Station] = [
        Station(name: "KAFD",         order: 8, coordinate: .init(latitude: 24.7671553, longitude: 46.6432711), minutesToNext: 5),
        Station(name: "Ar Rabi",      order: 7, coordinate: .init(latitude: 24.7862360, longitude: 46.6601248), minutesToNext: 5),
        Station(name: "Uthman Bin Affan", order: 6, coordinate: .init(latitude: 24.8013955, longitude: 46.6961421), minutesToNext: 4),
        Station(name: "SABIC",        order: 5, coordinate: .init(latitude: 24.8070691, longitude: 46.7095294), minutesToNext: 3),
        Station(name: "PNU 1",          order: 4, coordinate: .init(latitude: 24.8414744, longitude: 46.7174164), minutesToNext: 6),
        Station(name: "PNU 2",        order: 3, coordinate: .init(latitude: 24.8596218, longitude: 46.7045103), minutesToNext: 3),
        Station(name: "Airport T5",   order: 2, coordinate: .init(latitude: 24.9407856, longitude: 46.7102385), minutesToNext: 11),
        Station(name: "Airport T3–4", order: 1, coordinate: .init(latitude: 24.9560402, longitude: 46.7021429), minutesToNext: 3),
        Station(name: "Airport T1–2", order: 0, coordinate: .init(latitude: 24.9609970, longitude: 46.6989819), minutesToNext: 3)
    ]
}
