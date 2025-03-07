//
//  PropertyDetailsView.swift
//  LandlordTenandt
//
//  Created by Henrique Machitte on 02/03/25.
//

import SwiftUI

struct PropertyDetailsView: View {
    @EnvironmentObject var fireDBHelper: FireDBHelper
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var selectedPropertyWrapper: SelectedPropertyWrapper

    @State var property: Property?
    var isNew: Bool

    @State private var desc: String = ""
    @State private var address: String = ""
    @State private var city: String = ""
    @State private var monthlyRentalPrice: Decimal = 0.0
    @State private var availabilityDate: Date
    @State private var numberOfBedrooms: Int = 0
    @State private var numberOfBathrooms: Int = 0
    @State private var isAvailable: Bool = false
    @State private var propertyType: PropertyType = .apartment // Default value
    @State private var buildingAmenities: Set<BuildingAmenity> = []
    @State private var unitFeatures: Set<UnitFeature> = [] // ADD THIS

    init(property: Property?, isNew: Bool) {
        self.property = property
        self.isNew = isNew
        _desc = State(initialValue: property?.desc ?? "")
        _address = State(initialValue: property?.address ?? "")
        _city = State(initialValue: property?.city ?? "")
        _monthlyRentalPrice = State(initialValue: property?.monthlyRentalPrice ?? 0.0)
        _availabilityDate = State(initialValue: property?.availabilityDate ?? Date())
        _numberOfBedrooms = State(initialValue: property?.numberOfBedrooms ?? 0)
        _numberOfBathrooms = State(initialValue: property?.numberOfBathrooms ?? 0)
        _isAvailable = State(initialValue: property?.isAvailable ?? false)
        _propertyType = State(initialValue: property?.propertyType ?? .apartment)
        _buildingAmenities = State(initialValue: Set(property?.buildingAmenities ?? []))
        _unitFeatures = State(initialValue: Set(property?.unitFeatures ?? [])) // ADD THIS
    }

    var body: some View {
        VStack {
            if property != nil {
                Form {
                    TextField("Description", text: $desc)

                    TextField("Address", text: $address)

                    TextField("City", text: $city)

                    TextField("Rent Amount", value: $monthlyRentalPrice, format: .currency(code: Locale.current.currency?.identifier ?? "CAN"))

                    Stepper("Number of Bedrooms: \(numberOfBedrooms)", value: $numberOfBedrooms, in: 0...10)

                    Stepper("Number of Bathrooms: \(numberOfBathrooms)", value: $numberOfBathrooms, in: 0...10)

                    DatePicker("Select Availability Date", selection: $availabilityDate, displayedComponents: .date)

                    Toggle("Available", isOn: $isAvailable)

                    Picker("Property Type", selection: $propertyType) {
                        ForEach(PropertyType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }

                    Collapsible(label: {
                        Text("Building Amenities")
                            .font(.headline)
                            .fontWeight(.bold)
                    }, content: {
                        MultiSelectionView(options: BuildingAmenity.allCases, selected: $buildingAmenities)
                    })

                    Collapsible(label: {
                        Text("Unit Features")
                            .font(.headline)
                            .fontWeight(.bold)
                    }, content: {
                        MultiSelectionView(options: UnitFeature.allCases, selected: $unitFeatures)
                    })
                }

                Button(action: {
                    updateProperty()
                }) {
                    Text("Update Property")
                }
            } else {
                Text("Loading property data...")
            }
            Spacer()
        }
        .navigationTitle(Text("Detail View"))
        .onChange(of: fireDBHelper.isUpdateComplete) { _ in
            if fireDBHelper.isUpdateComplete {
                dismiss()
            }
        }
    }

    private func updateProperty() {
        if monthlyRentalPrice == 0.0 {
            print("Please provide all the fields")
        } else {
            if var propertyToUpdate = property {
                propertyToUpdate.desc = desc
                propertyToUpdate.address = address
                propertyToUpdate.city = city
                propertyToUpdate.monthlyRentalPrice = monthlyRentalPrice
                propertyToUpdate.availabilityDate = availabilityDate
                propertyToUpdate.numberOfBedrooms = numberOfBedrooms
                propertyToUpdate.numberOfBathrooms = numberOfBathrooms
                propertyToUpdate.isAvailable = isAvailable
                propertyToUpdate.propertyType = propertyType
                propertyToUpdate.buildingAmenities = Array(buildingAmenities)
                propertyToUpdate.unitFeatures = Array(unitFeatures) // ADD THIS

                print("Before Update: Desc: \(propertyToUpdate.desc), Address: \(propertyToUpdate.address), City: \(propertyToUpdate.city), Price: \(propertyToUpdate.monthlyRentalPrice), Bedrooms: \(propertyToUpdate.numberOfBedrooms), Bathrooms: \(propertyToUpdate.numberOfBathrooms), isAvailable: \(propertyToUpdate.isAvailable), propertyType: \(propertyToUpdate.propertyType), buildingAmenities: \(propertyToUpdate.buildingAmenities), unitFeatures: \(propertyToUpdate.unitFeatures)")

                fireDBHelper.updateProperty(propertyToUpdate: propertyToUpdate)

                print("After Update Call (Check dismiss): Desc: \(propertyToUpdate.desc), Address: \(propertyToUpdate.address), City: \(propertyToUpdate.city), Price: \(propertyToUpdate.monthlyRentalPrice), Bedrooms: \(propertyToUpdate.numberOfBedrooms), Bathrooms: \(propertyToUpdate.numberOfBathrooms), isAvailable: \(propertyToUpdate.isAvailable), propertyType: \(propertyToUpdate.propertyType), buildingAmenities: \(propertyToUpdate.buildingAmenities), unitFeatures: \(propertyToUpdate.unitFeatures)")

            } else {
                print("Property is nil, cannot update.")
            }
        }
    }
}
