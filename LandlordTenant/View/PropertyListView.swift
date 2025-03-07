//
//  PropertyListView.swift
//  LandlordTenandt
//
//  Created by Henrique Machitte on 02/03/25.
//

import SwiftUI

struct PropertyListView: View {
//    @ObservedObject var fireDBHelper = FireDBHelper.getInstance()
    @EnvironmentObject var fireAuthHelper: FireAuthHelper
    @EnvironmentObject var fireDBHelper: FireDBHelper

    @State private var searchText = ""
    @State private var showDetailView = false
    @StateObject private var selectedPropertyWrapper = SelectedPropertyWrapper()
    @State private var showingCreatePropertyView = false
    
    @Binding var rootScreen: RootView

    
    var filteredProperties: [Property] {
        if searchText.isEmpty {
            return fireDBHelper.propertyList
        } else {
            return fireDBHelper.propertyList.filter { property in
                property.city.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                TextField("Search by City", text: $searchText)
                    .padding(7)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)

                List {
                    ForEach(filteredProperties.enumerated().map({ $0 }), id: \.element.id) { index, currentProperty in
                    //ForEach(fireDBHelper.propertyList.enumerated().map({$0}), id: \.element.id) { index, currentProperty in
                        Button(action: {
                            selectedPropertyWrapper.selectedProperty = currentProperty // Set via wrapper
                            print("Selected Property: \(String(describing: selectedPropertyWrapper.selectedProperty)))")
                            showDetailView = true
                        }) {
                            PropertyRow(property: currentProperty)
                        }
                    }
                }
                .onAppear {
                    fireDBHelper.propertyList = []
                    fireDBHelper.getAllListings()
                }
                .navigationTitle("Properties")
                .toolbar { // Moved the button to the toolbar
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showingCreatePropertyView = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $showDetailView) {
                if let property = selectedPropertyWrapper.selectedProperty {
                    PropertyDetailsView(property: property, isNew: false)
                        .environmentObject(fireDBHelper)
                        .environmentObject(selectedPropertyWrapper)

                        .onAppear {
                            print("Presenting DetailView for: \(property.id ?? "no id")")
                        }
                }
            }
            .sheet(isPresented: $showingCreatePropertyView) {
                CreatePropertyView()
                    .environmentObject(fireDBHelper)
            }
        }
    }
}

struct PropertyRow: View {
    let property: Property
    
    var body: some View {
        HStack {
            AsyncImage(url: property.imageUrl) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            VStack(alignment: .leading) {
                Text(property.address)
                    .font(.headline)
                    .lineLimit(1)
                Text("\(property.city), \(property.isAvailable ? "Available" : "Not Available")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}


class SelectedPropertyWrapper: ObservableObject {
    @Published var selectedProperty: Property? = nil
}
