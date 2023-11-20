//
//  ContentView.swift
//  KMP-ios
//
//  Created by Sokolova Vita on 18.11.2023.
//

import SwiftUI
import shared


struct ContentView: View {
    @ObservedObject private(set) var viewModel: ViewModel
    
    @State private var userInput: String = ""

    var body: some View {
        VStack {
             TextField("Enter Text", text: $userInput)
                 .padding()
                 .textFieldStyle(RoundedBorderTextFieldStyle())
                 .onChange(of: userInput) { newValue in
                     Task { await viewModel.fetchSearchResults(query: userInput)}
                 }
             
            List(viewModel.phrases, id: \.self) { phrase in
                Text(phrase)
            }
         }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: ContentView.ViewModel())
    }
}

extension ContentView {
    class ViewModel: ObservableObject {
        @Published var phrases: [String] = ["Loading..."]
        
        let repository = MoviesRepositoryImpl(httpClient:HttpClientHolder.init().client);
        
        init() {}
        
        func fetchSearchResults(query: String) async {
            do {
                let movies = try await repository.getSearchResults(query: query)
                let titles = movies.map { $0.title }
                
                DispatchQueue.main.async {
                    self.phrases = titles
                }
            } catch {
                print("Error fetching search results: \(error.localizedDescription)")
            }
        }
    }
}
