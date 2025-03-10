//
//  PropertyListView.swift
//  LandlordTenant
//
//  Created by Henrique Machitte on 02/03/25.
//

import SwiftUI

struct PropertyListView: View {
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
        TabView {
            // PROPERTIES TAB
            NavigationStack {
                ZStack {
                    VStack {
                        // header with search bar
                        ZStack {
                            RoundedRectangle(cornerRadius: 0)
                                .fill(Color(uiColor: .systemTeal))
                                .frame(height: 50)
                                .frame(maxWidth: .infinity)

                            HStack {
                                Image(systemName: "sun.max")
                                    .padding(.leading, 5)
                                    .foregroundColor(Color.white)

                                Text("Rentals.ca")
                                    .padding(.trailing, 5)
                                    .foregroundColor(Color.white)

                                Spacer()

                                TextField("Search by City", text: $searchText)
                                    .padding(7)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                    .padding(.trailing, 5)
                                    .frame(maxWidth: .infinity)
                            }
                            .frame(height: 50)
                            .padding(.horizontal, 10)
                        }

                        // Property list
                        List {
                            ForEach(filteredProperties.enumerated().map({ $0 }), id: \.element.id) { _, currentProperty in
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
                        .listStyle(.plain)
                        .onAppear {
                            fireDBHelper.propertyList = []
                            fireDBHelper.getAllListings()
                        }
                    }

                    // Floating Action Button (FAB) to add new property
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: {
                                showingCreatePropertyView = true
                            }) {
                                Image(systemName: "plus")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .clipShape(Circle())
                                    .shadow(radius: 4)
                            }
                            .padding()
                        }
                    }
                }
                .navigationTitle("Properties")
                .sheet(isPresented: $showingCreatePropertyView) {
                    CreatePropertyView()
                        .environmentObject(fireDBHelper)
                }
            }
            .tabItem {
                Label("Properties", systemImage: "building.2.fill")
            }

            // FAVORITES TAB
            NavigationStack {
                Text("Favorites")
            }
            .tabItem {
                Label("Favorites", systemImage: "star.fill")
            }

            // REQUESTS TAB
            NavigationStack {
                Text("Requests")
            }
            .tabItem {
                Label("Requests", systemImage: "envelope.fill")
            }

            // PROFILE TAB
            NavigationStack {
                ProfileView()
                                    .environmentObject(fireAuthHelper)
            }
            .tabItem {
                Label("Profile", systemImage: "person.crop.circle.fill")
            }

            // LOGOUT TAB
            Button("Logout") {
                fireAuthHelper.signOut()
                rootScreen = .Login
            }
            .tabItem {
                Label("Logout", systemImage: "arrow.backward.circle.fill")
            }
        }
    }
}


struct PropertyRow: View {
    let property: Property
    @State private var isFavorite: Bool = false

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
