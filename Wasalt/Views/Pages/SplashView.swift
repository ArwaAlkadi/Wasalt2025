import SwiftUI

struct SplashView: View {

    @StateObject private var viewModel = SplashViewModel()
    @Environment(\.colorScheme) var colorScheme   

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 1) {

                
                Image(colorScheme == .dark ? "icon Dark" : "icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80)
                    .opacity(viewModel.showLogo ? 1 : 0)
                    .offset(
                        x: viewModel.shake ? -10 : (viewModel.moveLeftDown ? -21 : 0),
                        y: viewModel.moveLeftDown ? -2 : 0
                    )
                    .animation(viewModel.shake ?
                        Animation.linear(duration: 0.1).repeatCount(4, autoreverses: true)
                        : .default,
                        value: viewModel.shake
                    )

             
                if viewModel.showText {
                    Image(colorScheme == .dark ? "wasalt Dark" : "wasalt")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 170)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
    }

}
#Preview {
    SplashView()
}
