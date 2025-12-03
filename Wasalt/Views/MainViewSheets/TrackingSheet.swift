//
//  TrackingSheet.swift
//  Wasalt
//
//  Created by Arwa Alkadi on 19/11/2025.
//

import SwiftUI

struct TrackingSheet: View {

    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 20) {

            // --- السحب من الأعلى ---
            Rectangle()
                .frame(width: 40, height: 5)
                .foregroundColor(.gray.opacity(0.4))
                .cornerRadius(3)
                .padding(.top, 10)


            // --- الوقت ---
            Text("الوقت المتوقع للوصول : 4 دقائق")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
                .padding(.top, 3)


            // --- المحتوى الداخلي (البداية + الوجهة) ---
            HStack(spacing: 25) {

                VStack(alignment: .trailing, spacing: 20) {

                    // البداية
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("البداية")
                            .foregroundColor(Color(hex: "#ACCF71"))
                            .font(.system(size: 16, weight: .semibold))

                        Text("المركز المالي")
                            .foregroundColor(.white)
                            .font(.system(size: 18))
                    }

                    // الوجهة
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("الوجهة")
                            .foregroundColor(Color(hex: "#ACCF71"))
                            .font(.system(size: 16, weight: .semibold))

                        Text("طريق عثمان بن عفان")
                            .foregroundColor(.white)
                            .font(.system(size: 18))
                    }
                }

                // --- الدبوسين + الخط ---
                VStack(spacing: 25) {

                    // دبوس البداية — صورة loca
                    ZStack {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color(hex: "#ACCF71"))
                            .frame(width: 90, height: 55)

                        Image("loca")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 35, height: 35)
                    }

                    // الخط المتقطع
                    Rectangle()
                        .fill(Color(hex: "#ACCF71"))
                        .frame(width: 3, height: 35)
                        .opacity(0.6)

                    // دبوس الوجهة
                    ZStack {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color(hex: "#ACCF71"))
                            .frame(width: 90, height: 55)

                        Image("loca")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 35, height: 35)
                    }
                }
            }

            Spacer()

            // --- زر إنهاء الرحلة ---
            Button(action: {
                isPresented = false
            }) {
                Text("إنهاء الرحلة")
                    .foregroundColor(.white)
                    .font(.system(size: 18, weight: .medium))
                    .padding(.horizontal, 45)
                    .padding(.vertical, 12)
                    .background(Color(hex: "#6D7446"))
                    .cornerRadius(20)
            }
            .padding(.bottom, 22)

        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
        .frame(height: 360)     // ← أصغر من قبل
        .background(Color.black)
        .cornerRadius(32, corners: [.topLeft, .topRight])
    }
}
