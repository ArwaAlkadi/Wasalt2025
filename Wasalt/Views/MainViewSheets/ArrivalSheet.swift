//
//  ArrivalSheet.swift
//  Wasalt
//
//  Created by Arwa Alkadi on 19/11/2025.
//

import SwiftUI

struct ArrivedSheet: View {
    
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 20) {

            Rectangle()
                .frame(width: 40, height: 5)
                .foregroundColor(.gray.opacity(0.4))
                .cornerRadius(3)
                .padding(.top, 10)

            ZStack {
                Circle()
                    .fill(Color(hex: "#ACCF71"))
                    .frame(width: 220, height: 220)

                Image("metro")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120)
            }

            Text("وصلت محطتك!")
                .font(.system(size: 26, weight: .semibold))
                .foregroundColor(.white)

            Spacer()

            Button(action: { isPresented = false }) {
                Text("العودة")
                    .foregroundColor(.white)
                    .font(.system(size: 20, weight: .medium))
                    .padding(.horizontal, 45)
                    .padding(.vertical, 14)
                    .background(Color(hex: "#6D7446"))
                    .cornerRadius(20)
            }
            .padding(.bottom, 35)

        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
        .frame(height: 460) // ← ارتفاع الشيت
        .background(Color.black)   // ← الشيت نفسه أسود بالكامل
        .cornerRadius(30, corners: [.topLeft, .topRight])
    }
}
