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
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let store = EmojiArtDocumentStore(directory: url)
        WindowGroup {
//            EmojiArtDocumentView(document: EmojiArtDocument())
            EmojiArtDocumentChooser().environmentObject(store)
        }
    }
}
