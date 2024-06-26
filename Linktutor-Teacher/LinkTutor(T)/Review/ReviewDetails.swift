//
//  ReviewDetails.swift
//  LinkTutor(T)
//
//  Created by Aditya Pandey on 30/03/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

struct reviewData : Identifiable, Codable ,  Equatable {
    var id: String
    var comment : String
    var documentUid: String
    var ratingStar : Int
    var teacherUid: String
    var time: Date
    var skillUid: String
    var userUid : String
    var skillOwnerDetailsUid : String
}

class ReviewViewModel: ObservableObject {
    @Published var reviewDetails = [reviewData]()
    private let db = Firestore.firestore()
    static let shared = ReviewViewModel()
    
    init() {
        // Initialize the view model asynchronously
        initialize()
    }
    
    func initialize() {
        Task {
            do {
                let snapshot = try await db.collection("review").getDocuments()
                DispatchQueue.main.async {
                    var details: [reviewData] = []
                    for document in snapshot.documents {
                        let data = document.data()
                        let id = document.documentID
                        let comment = data["comment"] as? String ?? ""
                        let documentUid = data["documentUid"] as? String ?? ""
                        let ratingStar = data["ratingStar"] as? Int ?? 0
                        let teacherUid = data["teacherUid"] as? String ?? ""
                        let time = data["time"] as? Date ?? Date()
                        let skillUid = data["skillUid"] as? String ?? ""
                        let userUid = data["userUid"] as? String ?? ""
                        let skillOwnerDetailsUid = data["skillOwnerDetailsUid"] as? String ?? ""
                        
                        let reviewDetail = reviewData(id: id,
                                                      comment: comment,
                                                      documentUid: documentUid,
                                                      ratingStar: ratingStar,
                                                      teacherUid: teacherUid,
                                                      time: time,
                                                      skillUid: skillUid,
                                                      userUid: userUid,
                                                      skillOwnerDetailsUid: skillOwnerDetailsUid)
                        details.append(reviewDetail)
                    }
                    self.reviewDetails = details
                }
            } catch {
                print("Error fetching review details: \(error.localizedDescription)")
            }
        }
    }
}

struct ReviewDetails: View {
    @ObservedObject var reviewViewModel = ReviewViewModel()
    @State private var isFetching = false // Track whether fetching is in progress

    var body: some View {
        NavigationView {
            ScrollView {
                ForEach(reviewViewModel.reviewDetails.filter { $0.teacherUid == "1" && $0.skillUid == "dance" &&  $0.skillOwnerDetailsUid == "1" }) { teacherDetail in
                    if let formattedDate = formatDate(teacherDetail.time) {
                        reviewCard(reviewRating: teacherDetail.ratingStar, review: "\(teacherDetail.comment)", time : "\(formattedDate)")
                    }
                }
            }
            .navigationBarTitle("Teacher Details")
        }
        .onAppear {
            // Fetch review details only if not already fetching
            if !isFetching {
                fetchReviewDetails()
            }
        } // end of on appear
    }
    
    func fetchReviewDetails() {
        Task {
            do {
                // Mark fetching as in progress
                isFetching = true
                 reviewViewModel.initialize()
            }
            // Mark fetching as completed
            isFetching = false
        }
    }
    
    func formatDate(_ date: Date) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM YYYY" // Date format: dayOfMonth month
        return dateFormatter.string(from: date)
    }
}





#Preview {
    ReviewDetails()
}



import SwiftUI

struct reviewCard: View {
    var reviewRating: Int
    var review: String
    var time: String
    
    var body: some View {
        VStack {
            HStack {
                Text("\(String(repeating: "⭐️", count: reviewRating))")
                    .font(AppFont.actionButton)
                Spacer()
                Text("\(time)")
                    .font(AppFont.actionButton)
                    .foregroundStyle(.gray)
            }
            HStack {
                Text("\(review)")
                    .font(AppFont.smallReg)
                Spacer()
            }
            .padding([.top, .bottom], 5)
            Divider()
                .background(Color.elavated)
        }
    }
}
