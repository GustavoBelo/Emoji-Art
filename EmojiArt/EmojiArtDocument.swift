//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by Gustavo Belo on 23/03/21.
//

import SwiftUI
import Combine

class EmojiArtDocument: ObservableObject, Hashable, Identifiable {
    
    static func == (lhs: EmojiArtDocument, rhs: EmojiArtDocument) -> Bool {
        lhs.id == rhs.id
    }
    
    
    let id: UUID
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static let palete: String = "ππ¦πΆπ€ππ¦π"
    private static let untitled = "EmojiArtDocument.Untitled"
    
    @Published private var emojiArt: EmojiArt
        
    private var autosaveCancellable: AnyCancellable?
    
    init(id: UUID? = nil) {
        self.id = id ?? UUID()
        let defaultKey = "EmojiArtDocument.\(self.id.uuidString)"
        emojiArt = EmojiArt(json: UserDefaults.standard.data(forKey: defaultKey)) ?? EmojiArt()
        autosaveCancellable  = $emojiArt.sink { emojiArt in
            UserDefaults.standard.set(emojiArt.json, forKey: defaultKey)
        }
        fetchBackgroundImageData()
    }
    
    var url: URL? { didSet{ self.save(emojiArt) } }
    
    init(url: URL) {
        self.id = UUID()
        self.url = url
        self.emojiArt = EmojiArt(json: try? Data(contentsOf: url)) ?? EmojiArt()
        fetchBackgroundImageData()
        autosaveCancellable  = $emojiArt.sink { emojiArt in
            self.save(emojiArt)
        }
    }
    
    private func save(_ emojiArt: EmojiArt){
        if url != nil{
            try? emojiArt.json?.write(to: url!)
        }
    }
    
    @Published private(set) var backgroundImage: UIImage?
    
    @Published var steadyStateZoomScale: CGFloat = 1.0
    @Published var steadyStatePanOffset: CGSize = .zero

    
    var emojis: [EmojiArt.Emoji]{ emojiArt.emojis }
    
    //MARK: - Intent
    
    func addEmoji(_ emoji: String, at location: CGPoint, size: CGFloat ) {
        emojiArt.addEmoji(emoji, x: Int(location.x), y: Int(location.y), size: Int(size))
    }
    
    func moveEmoji(_ emoji: EmojiArt.Emoji, by offset: CGSize) {
        if let index = emojiArt.emojis.firstIndex(matching: emoji){
            emojiArt.emojis[index].x += Int(offset.width)
            emojiArt.emojis[index].x += Int(offset.height)
        }
    }
    
    func scaleEmoji(_ emoji: EmojiArt.Emoji, by scale: CGFloat) {
        if let index = emojiArt.emojis.firstIndex(matching: emoji ) {
            emojiArt.emojis[index].size = Int((CGFloat(emojiArt.emojis[index].size) * scale).rounded(.toNearestOrEven))
        }
    }
    
    var backgroundURL: URL? {
        get {
            emojiArt.backgroundURL
        }
        set {
            emojiArt.backgroundURL = newValue?.imageURL
            fetchBackgroundImageData()
        }
    }
    
    private var fetchImageCancellable: AnyCancellable?
    
    private func fetchBackgroundImageData() {
        backgroundImage = nil
        if let url = self.emojiArt.backgroundURL {
            fetchImageCancellable?.cancel()
            fetchImageCancellable = URLSession.shared.dataTaskPublisher(for: url)
                .map { data, urlResponse in UIImage(data: data) }
                .receive(on: DispatchQueue.main)
                .replaceError(with: nil)
                .assign(to: \EmojiArtDocument.backgroundImage, on: self)
        }
    }
}

extension EmojiArt.Emoji {
    var fontSize: CGFloat { CGFloat(self.size) }
    var location: CGPoint { CGPoint(x: CGFloat(x), y: CGFloat(y)) }
}
