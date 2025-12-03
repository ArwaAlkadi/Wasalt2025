//
//  test.swift
//  Wasalt
//
//  Created by Aryam on 03/12/2025.
//
import SwiftUI

struct TestView: View {

    @State private var showTracking = false

    var body: some View {
        ZStack {

            Color.gray.opacity(0.2)
                .ignoresSafeArea()

            Button("عرض الشيت") {
                withAnimation {
                    showTracking = true
                }
            }
            .font(.title2)
            .padding()
            .background(Color.green.opacity(0.8))
            .cornerRadius(15)

            if showTracking {
                Color.black.opacity(0.65)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            showTracking = false
                        }
                    }
            }

            TrackingSheet(isPresented: $showTracking)
                .offset(y: showTracking ? 150 : UIScreen.main.bounds.height)   // ← هنا السر
                .animation(.spring(response: 0.45, dampingFraction: 0.85), value: showTracking)
        }
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
