//
//  ProfileView.swift
//  SWE_Project
//
//  Created by Khalid R on 30/03/1446 AH.
//

import SwiftUI



struct ProfileView: View {
    @StateObject private var authVM = AuthViewModel()
    @State var isInprogress: Bool = false
    @State var isLogout: Bool = false
    var body: some View {
        NavigationStack {
            VStack {
               
                Text("Profile")
                    .font(.ericaOne(size: 32))
                
                Spacer().frame(height: 20)
                
                // Profile Image and Info
                VStack() {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.black)
                        .padding(.bottom, 10)
                    
                    Text(UserService.shared.user.username)
                        .font(.ericaOne(size: 20))
                        .foregroundColor(.black)
                    
                    Text(UserService.shared.auth.currentUser?.email ?? "khalidaldz@gmail.com")
                        .font(.ericaOne(size: 16))
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 40)
                
                
                VStack(alignment: .leading,spacing: 55) {
                    NavigationLink {
                        SavePlacesView(isFromSaved: false)
                    }label: {
                        
                        
                        ProfileMenuItem(iconName: "MR", title: "Manage Reservation")
                    }
                    NavigationLink {
                        SavePlacesView(isFromSaved: true)
                    }label: {
                        
                        
                        ProfileMenuItem(iconName: "Book", title: "Saved Places")
                    }
                  
                }
                .padding(.trailing, 20)
                
                Spacer()
                
                // Log Out Button
                Button(action: {
                    withAnimation(.spring) {
                        isInprogress = true
                        Task {
                            try await authVM.logOut()
                            try await Task.sleep(nanoseconds: 3_000_000_000)
                            isLogout = true
                        }
                    }
                }) {
                    Group {
                        if isInprogress {
                            Spinner(lineWidth: 10, height: 30, width: 30)
                        } else {
                            Text("Log Out")
                        }
                    }
                    
                    .foregroundColor(.white)
                    .font(.ericaOne(size: 24))
                    .padding()
                    .frame(width: isInprogress ? 80 : 340)
                    .background(Color.red)
                    .cornerRadius(40)
                }
                .padding(.bottom, 10)
                
                }
                .padding(.bottom, 40)
            
            
                .fullScreenCover(isPresented: $isLogout) {
                    OnboardingView()
                }
            }
            .background(Color.white.ignoresSafeArea())
        }
    }


// Helper view for profile menu items
struct ProfileMenuItem: View {
    var iconName: String
    var title: String

    var body: some View {
        HStack {
            Image(iconName)
                .resizable()
                .frame(width: 30, height: 30)
                .padding()
                .background(Color(.systemGray6))
                .clipShape(Circle())
            
            Text(title)
                .font(.ericaOne(size: 20))
                .foregroundColor(.black)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    ProfileView()
}
