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
                        NavigationLink {
                           PropertyDetailsView(property: currentProperty, isNew: false)
                            .environmentObject(fireDBHelper)
                            .environmentObject(selectedPropertyWrapper)

                            .onAppear {
                                print("Presenting DetailView for: \(currentProperty.id ?? "no id")")
                            }
                        } label: {
                            PropertyRow(property: currentProperty)
                                .buttonStyle(.plain)
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
            .sheet(isPresented: $showingCreatePropertyView) {
                CreatePropertyView()
                    .environmentObject(fireDBHelper)
            }
        }
    }
}

// .font(.callout) // Slightly smaller than .subheadline

struct PropertyRow: View {
    let property: Property
    @State private var isFavorite: Bool = false // Add state

    var body: some View {
        HStack(alignment: .top) {
            AsyncImage(url: property.imageUrl) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 100, height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.trailing, 20)
          
            
            VStack(alignment: .leading) {
                Text(property.monthlyRentalPrice, format: .currency(code: Locale.current.currency?.identifier ?? "CAN"))
                    .font(.title3)
                    .fontWeight(.bold)
                    .lineLimit(1)

                HStack {
                    Text("\(property.numberOfBedrooms) Beds")
                    Text("|")
                    Text("\(property.numberOfBathrooms) Baths")
                }
                .font(.callout)
                .foregroundColor(Color.gray)

                Text(property.address)
                    .font(.subheadline)
                    .lineLimit(1)
                    .foregroundColor(Color.green)

                Text(property.city)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button {
                isFavorite.toggle()
                if isFavorite {
                    print("Favorite!")
                } else {
                    print("Not favorite")
                }
            } label: {
                Image(systemName: isFavorite ? "star.fill" : "star")
                    .font(.title2)
                    .foregroundColor(.yellow)
            }
        }
        .padding(.vertical, 2)
    }
}

class SelectedPropertyWrapper: ObservableObject {
    @Published var selectedProperty: Property? = nil
}
