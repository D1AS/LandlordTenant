//
//  FireDBHelper.swift
//  LandlordTenandt
//
//  Created by Henrique Machitte on 02/03/25.
//

import Foundation
import FirebaseFirestore

class FireDBHelper : ObservableObject {

    @Published var propertyList = [Property]()
    @Published var isUpdateComplete: Bool = false

    private let COLLECTION_PROPERTIES: String = "Properties"
    private let FIELD_DESC : String = "desc"
    private let FIELD_ADDRESS : String = "address"
    private let FIELD_CITY : String = "city"
    private let FIELD_ISAVAILLABLE : String = "isAvailable"
    private let FIELD_AVAILABILITYDATE : String = "availabilityDate"


    private let db: Firestore
    private static var shared: FireDBHelper?

    init(db: Firestore) {
        self.db = db
    }

    static func getInstance() -> FireDBHelper {
        if(shared == nil) {
            shared = FireDBHelper(db: Firestore.firestore())
        }
        return shared!
    }

    func insertListing(newProperty: Property) {
        do {
            try db
                .collection(COLLECTION_PROPERTIES)
                .addDocument(from: newProperty)
        } catch let err as NSError {
            print("Unable to add listing \(err)")
        }
    }

    func getListing(propertyId: String) -> Property? {
        if let foundProperty = propertyList.first(where: { $0.id == propertyId }) {
            return foundProperty
        }
        return nil
    }


    func getAllListings() {
        db
            .collection(COLLECTION_PROPERTIES)
            .addSnapshotListener({ (querySnapshot, error) in
                guard let snapshot = querySnapshot else {
                    print("Unable to get data")
                    return
                }

                snapshot.documentChanges.forEach { docChange in
                    do {
                        var property: Property = try docChange.document.data(as: Property.self)
                        //listing.id = docChange.document.documentID

                        let matchedIndex = self.propertyList.firstIndex(where: {($0.id?.elementsEqual(docChange.document.documentID))!})

                        switch docChange.type {
                        case .added:
//                            print("Movie Added")
                            self.propertyList.append(property)
                        case .modified:
//                            print("Movie Updated: \(docChange.document.documentID)")
                            if(matchedIndex != nil) {
                                self.propertyList[matchedIndex!] = property
                            }
                        case .removed:
                            print("Movie Deleted \(docChange.document.documentID)")
                            self.propertyList.remove(at: matchedIndex!)
                        } // switch end
                    } catch let err as NSError {
                        print("Unable to fetch listings \(err)")
                    } // do..catch end
                } // forEach end
            })
    }

    func deleteListing(listingToDelete: Property) {
        db
            .collection(COLLECTION_PROPERTIES)
            .document(listingToDelete.id!)
            .delete { error in
                if let err = error {
                    print("Unable to delete a property \(err)")
                } else {
                    print("Property Deleted: \(listingToDelete.address)")
                }

            }
    }

    func updateProperty(propertyToUpdate: Property){
        guard let propertyId = propertyToUpdate.id else {
            print("Error: Property ID is missing.")
            self.isUpdateComplete = true
            return
        }

        let propertyData: [String: Any] = [
            "desc": propertyToUpdate.desc,
            "address": propertyToUpdate.address,
            "city": propertyToUpdate.city,
            "availabilityDate": propertyToUpdate.availabilityDate,
            "isAvailable": propertyToUpdate.isAvailable,
            "numberOfBedrooms": propertyToUpdate.numberOfBedrooms,
            "numberOfBathrooms": propertyToUpdate.numberOfBathrooms,
            "monthlyRentalPrice": propertyToUpdate.monthlyRentalPrice as NSDecimalNumber,
            "propertyType": propertyToUpdate.propertyType.rawValue,
            "buildingAmenities": propertyToUpdate.buildingAmenities.map { $0.rawValue },
            "unitFeatures": propertyToUpdate.unitFeatures.map { $0.rawValue }
        ]

        db.collection(COLLECTION_PROPERTIES).document(propertyId).updateData(propertyData) { error in
            if let err = error {
                print("Unable to update a property \(err)")
            } else {
                print("Property Updated: \(propertyToUpdate.address)")
            }
            self.isUpdateComplete = true
        }
    }
}
