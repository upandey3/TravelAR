//
//  FlightData.swift
//  TravelAR
//
//  Created by Utkarsh Pandey on 9/17/17.
//  Copyright © 2017 Utkarsh Pandey. All rights reserved.
//

import Foundation

struct FlightData {
    let flightName: String
    let flightDate: String
    let flightTotalPrice: String
    let flightPPAPrice: String
    let flightTax: String
    let flightDest: String
    let flightOrig: String
    let flightDestTerm: String
    let flightOrigTerm: String
    init(fn: String, fd: String, ftp: String, fpp: String, ft: String, fde: String, frg: String, fdt: String, frgt: String ) {
        flightName = fn
        flightDate = fd
        flightTotalPrice = ftp
        flightPPAPrice = fpp
        flightTax = ftp
        flightDest = fde
        flightOrig = frg
        flightDestTerm = fdt
        flightOrigTerm = frgt
    }
}
