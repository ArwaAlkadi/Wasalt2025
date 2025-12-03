
import SwiftUI

struct SheetPreviewHost: View {
    @State private var show = true
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.2).ignoresSafeArea()
            
            Text("هذه صفحة معاينة فقط")
                .font(.headline)
                .opacity(0.5)
        }
        .sheet(isPresented: $show) {
            ArrivedSheet(isPresented: $show)
                .presentationDetents([.medium]) // ✦ يعطيه شكل شيت حقيقي
                .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    SheetPreviewHost()
}
