//
//  PaletteChooser.swift
//  EmojiArt
//
//  Created by Gustavo Belo on 29/03/21.
//

import SwiftUI

struct PaletteChooser: View {
    @ObservedObject var document: EmojiArtDocument
    @Binding var chosenPalette: String
    @State private var showPaletteEditor = false
    
    var body: some View {
        HStack {
            Stepper(
                onIncrement: {
                    self.chosenPalette = self.document.palette(after: self.chosenPalette)
                },
                onDecrement: {
                    self.chosenPalette = self.document.palette(before: self.chosenPalette)
                },
                label: {
                    EmptyView()
                })
            Text(self.document.paletteNames[chosenPalette] ?? "")
            Image(systemName: "keyboard").imageScale(.large)
                .onTapGesture{
                    self.showPaletteEditor = true
                }
                .popover(isPresented: $showPaletteEditor, content: {
                    PaletteEditor(chosenPalette: $chosenPalette, isShowing: $showPaletteEditor)
                        .environmentObject(self.document)
                        .frame(minWidth: 300, minHeight: 500)
                })
        }
        .fixedSize(horizontal: true, vertical: false)
        .onAppear{ self.chosenPalette = self.document.defaultPalette }
    }
}

struct PaletteEditor: View {
    @EnvironmentObject var document: EmojiArtDocument
    
    @Binding var chosenPalette: String
    @Binding var isShowing: Bool
    @State private var paletteName: String = ""
    @State private var emojiToAdd: String = ""
    
    var body: some View{

        VStack(spacing: 0){
            ZStack{
                Text("Edite seus emojis 😆").font(.headline).padding()
                HStack{
                    Spacer()
                    Button(action: {
                        self.isShowing = false
                    }, label: {
                        Text("Feito")
                    }).padding()
                }
            }
            Divider()
            Form{
                Section() {
                    TextField("Nome da paleta", text: $paletteName, onEditingChanged: { began in
                        if !began{
                            self.document.renamePalette(self.chosenPalette, to: self.paletteName)
                        }
                    })
    
                    TextField("Adicione um emoji!", text: $emojiToAdd, onEditingChanged: { began in
                        if !began{
                            self.chosenPalette = self.document.addEmoji(self.emojiToAdd,toPalette: self.chosenPalette)
                            self.emojiToAdd = ""
                        }
                    })
                }
                Section(header: Text("Remova um Emoji :(")){
                    Grid(chosenPalette.map{ String($0) }, id: \.self) {emoji in
                        Text(emoji)
                            .font(Font.system(size: self.fontSize))
                            .onTapGesture{
                                    self.chosenPalette = self.document.removeEmoji(emoji,fromPalette: self.chosenPalette)
                            }
                    }
                    .frame(height: self.height)
                }
            }
        }
        .onAppear{ self.paletteName = self.document.paletteNames[chosenPalette] ?? "" }
    }
    
    var fontSize: CGFloat = 40
    
    var height: CGFloat {
        CGFloat((chosenPalette.count - 1)/6) * 70+70
    }
}



//struct PaletteChooser_Previews: PreviewProvider {
//    static var previews: some View {
//        PaletteChooser(document: EmojiArtDocument(), chosenPalette: Binding.constant(""))
//    }
//}
