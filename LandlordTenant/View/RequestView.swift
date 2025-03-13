//
//  RequestView.swift
//  LandlordTenant
//
//  Created by Juan Wang on 2025/3/13.
//

import SwiftUI

struct RequestView: View {
    @EnvironmentObject var fireAuthHelper: FireAuthHelper

    var body: some View {
        NavigationView {
            List {
                let propertyKeys = fireAuthHelper.propertyRequestMap.keys.sorted()
                ForEach(propertyKeys, id: \.self) { propertyId in
                    Section(header: Text("Property: \(fireAuthHelper.propertyAddresses[propertyId] ?? "Unknown Address")").font(.headline)) {  // Show property address
                        let userIds = fireAuthHelper.propertyRequestMap[propertyId] ?? []
                        ForEach(userIds, id: \.self) { userId in
                            let userName = fireAuthHelper.userNames[userId] ?? "Unknown"
                            Text("User: \(userName)")
                                .padding(.leading, 10)
                        }
                    }
                }
            }
            .navigationTitle("Property Requests")
            .onAppear {
                fireAuthHelper.fetchPropertyRequestMap()  // Fetch property requests (user to propertyId mapping)
                fireAuthHelper.fetchPropertyAddresses()  // Fetch property addresses using the document ID
            }
        }
    }
}


