//
//  OptionalImage.swift
//  EmojiArt
//
//  Created by Gustavo Belo on 24/03/21.
//

import SwiftUI

struct OptionalImage: View {
    var uiImage: UIImage?
    
    var body: some View {
        if uiImage != nil {
            Image(uiImage: uiImage!)
        }
    }
}
