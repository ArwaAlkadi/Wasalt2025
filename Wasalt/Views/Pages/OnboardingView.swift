import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        if viewModel.isOnboardingFinished {
            Text("Main App Screen")
                .transition(.opacity)
        } else {
            VStack {
                
                // MARK: Top fixed - Skip button
                HStack {
                    Spacer()
                    Button("تخطي") {
                        viewModel.skip()
                    }
                    .padding()
                    .foregroundColor(Color(colorScheme == .light ? "Green light" : "GD"))
                }
                
                Spacer()
                
                // MARK: Middle dynamic content
                TabView(selection: $viewModel.currentPage) {
                    ForEach(0..<viewModel.pages.count, id: \.self) { index in
                        let page = viewModel.pages[index]
                        let iconName = (colorScheme == .light) ? page.lightIcon : page.darkIcon
                        
                        VStack(spacing: 25) {
                            ZStack {
                                Circle()
                                    .frame(width: 290, height: 290)
                                    .foregroundColor(Color(colorScheme == .light ? "GL" : "GD"))
                                    .opacity(0.12)
                                
                                Image(colorScheme == .light ? "GL" : "GD")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 230)
                                
                                Image(iconName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 270)
                            }
                            
                            Text(page.title)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(colorScheme == .light ? .black : .white)
                            
                            Text(page.subtitle)
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .foregroundColor(colorScheme == .light ? .black : .white)
                                .padding(.horizontal, 40)
                        }
                        .tag(index)
                        .padding(.horizontal, 20)
                        .transition(.slide)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                
                // MARK: Bottom fixed - Indicators + Next button
                VStack {
                    HStack(spacing: 8) {
                        ForEach(0..<viewModel.pages.count, id: \.self) { dotIndex in
                            
                            let circleColor = Color(colorScheme == .light ? "GL" : "GD")
                            let capsuleColor = Color(colorScheme == .light ? "Green Light" : "Green Dark")
                            
                            if dotIndex == viewModel.currentPage {
                                // Active page → Capsule
                                Capsule()
                                    .fill(capsuleColor)
                                    .frame(width: 50, height: 8)
                                    .animation(.easeInOut, value: viewModel.currentPage)
                            } else {
                                // Inactive pages → Circle
                                Circle()
                                    .fill(circleColor.opacity(0.4))
                                    .frame(width: 10, height: 10)
                            }
                        }
                    }

                    .padding(.bottom, 50)
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            viewModel.next()
                        }) {
                            Image(systemName: "chevron.right.circle.fill")
                                .font(.system(size: 45))
                                .foregroundColor(Color(colorScheme == .light ? "Green light" : "GD"))
                                .padding(.trailing, 20)
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
        }
    }
}


#Preview {
    OnboardingView()
}
