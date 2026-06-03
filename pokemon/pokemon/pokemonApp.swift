//
//  pokemonApp.swift
//  pokemon
//
//  Created by myone on 5/21/26.
//

import SwiftUI
import UIKit
import CoreText

@main
struct pokemonApp: App {
    init() {
        Self.registerPretendard()
        Self.configureNavigationBar()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }

    /// Registers the bundled Pretendard variable font at runtime,
    /// so no Info.plist (UIAppFonts) entry is required.
    private static func registerPretendard() {
        guard let url = Bundle.main.url(forResource: "PretendardVariable", withExtension: "ttf") else {
            print("⚠️ PretendardVariable.ttf not found in bundle")
            return
        }
        CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
    }

    /// Applies Pretendard to the navigation bar titles.
    private static func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.largeTitleTextAttributes = [.font: UIFont.pretendard(34, weight: .bold)]
        appearance.titleTextAttributes = [.font: UIFont.pretendard(17, weight: .semibold)]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}
