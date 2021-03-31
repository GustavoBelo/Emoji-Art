//
//  EmojiArtApp.swift
//  EmojiArt
//
//  Created by Gustavo Belo on 23/03/21.
//

import SwiftUI

@main
struct EmojiArtApp: App {
    var body: some Scene {
        let store = EmojiArtDocumentStore(named: "Emoji Art")
        WindowGroup {
//            EmojiArtDocumentView(document: EmojiArtDocument())
            EmojiArtDocumentChooser().environmentObject(store)
        }
    }
}
