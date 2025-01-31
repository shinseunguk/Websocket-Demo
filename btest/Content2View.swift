//
//  Content2View.swift
//  btest
//
//  Created by ukseung.dev on 1/31/25.
//

import SwiftUI

struct Content2View: View {
    @ObservedObject var viewModel = Content2ViewModel()
    
    var body: some View {
        VStack(alignment: .center) {
            TextField(
                "입력",
                text: $viewModel.query
            )
            .textFieldStyle(.roundedBorder)
            .frame(width: 250)
            
            if let result = viewModel.results {
                Text(result.args.query)
            } else {
                Text("result 없음")
            }
        }
    }
}

#Preview {
    Content2View()
}
