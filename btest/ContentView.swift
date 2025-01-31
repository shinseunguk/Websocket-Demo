//
//  ContentView.swift
//  btest
//
//  Created by ukseung.dev on 1/31/25.
//

import SwiftUI

struct ContentView: View {
    @State var text = ""
    @ObservedObject var viewModel = ContentViewModel()
    var body: some View {
        VStack {
            Text(viewModel.isConnected ? "웹소켓 연결 O" : "웹소켓 연결 X")
            HStack {
                TextField(
                    "보내면 웹소켓에서 그대로 return",
                    text: $text
                )
                .textFieldStyle(.roundedBorder)
                
                Button("보내기") {
                    viewModel.sendMessage(text)
                    text = ""
                }
                .disabled(text.isEmpty ? true : false)
            }
            List(viewModel.publishedResultArray, id: \.self) {
                Text($0)
            }
        }
        .padding()
        .onAppear {
            viewModel.connect()
        }
        .onDisappear {
            viewModel.disconnect()
        }
    }
}

#Preview {
    ContentView()
}
