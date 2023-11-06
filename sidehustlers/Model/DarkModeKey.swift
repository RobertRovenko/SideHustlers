//
//  DarkModeKey.swift
//  sidehustlers
//
//  Created by Robert Falkbäck on 2023-11-06.
//

import Foundation
import SwiftUI

struct DarkModeKey: EnvironmentKey {
    static var defaultValue: Binding<Bool> = .constant(false)
}

extension EnvironmentValues {
    var isDarkModeEnabled: Binding<Bool> {
        get { self[DarkModeKey.self] }
        set { self[DarkModeKey.self] = newValue }
    }
}
