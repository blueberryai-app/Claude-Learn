//
//  Colors.swift
//  Blueberry Learn
//
//  Centralized color definitions for the app
//

import SwiftUI

extension Color {
    // MARK: - Brand Colors

    /// Primary highlight color - warm orange/terracotta
    static let claudeOrange = Color(red: 0.76, green: 0.44, blue: 0.35)

    // MARK: - Background Colors

    /// Off-white background for tiles
    static let tileBackground = Color(red: 0.93, green: 0.91, blue: 0.87)

    /// Light gray surface for cards
    static let cardBackground = Color(red: 0.96, green: 0.96, blue: 0.96)

    /// Search bar background
    static let searchBackground = Color(red: 0.95, green: 0.95, blue: 0.97)

    // MARK: - Text Colors

    /// Off-black text color
    static let textPrimary = Color(red: 0.13, green: 0.13, blue: 0.13)

    /// Medium gray text for secondary content
    static let textSecondary = Color(red: 0.4, green: 0.4, blue: 0.4)

    // MARK: - Icon Colors

    /// Dark icon color
    static let iconDark = Color(red: 0.2, green: 0.2, blue: 0.2)

    /// Search icon color
    static let iconSecondary = Color(red: 0.6, green: 0.6, blue: 0.63)
}
