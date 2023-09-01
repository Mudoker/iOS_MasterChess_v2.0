import SwiftUI

struct Test_ArrayAnimation: View {
    @State private var items1: [String] = []
    @State private var items2: [String] = []
    @State private var showScrollToEndButton: Bool = false
    @State private var scrollToBottom: Bool = false

    var body: some View {
        VStack {
            // Horizontal array with easeIn animation
            HStack(spacing: 10) {
                            ForEach(items1, id: \.self) { item in
                                Text(item)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .id(item)
                                    .transition(AnyTransition.opacity.animation(.easeIn))
                            }
                            
                            Spacer()
                        }
            ScrollView(.horizontal) {
                            ScrollViewReader { scrollViewProxy in
                                HStack {
                                    ForEach(items2, id: \.self) { item in
                                        Text(item)
                                            .padding()
                                            .background(Color.green)
                                            .foregroundColor(.white)
                                            .cornerRadius(10)
                                            .id(item) // Use item as the id
                                    }
                                    .onChange(of: items2.count) { _ in
                                        withAnimation {
                                            scrollViewProxy.scrollTo(items2.last, anchor: .trailing)
                                        }
                                    }
                                }
                            }
                        }
            
            if showScrollToEndButton {
                Button("Scroll to End") {
                    withAnimation {
                        items2.append(items2.remove(at: 0))
                    }
                }
                .padding(.bottom, 20)
            }
            
            Button("Add Item") {
                let newItem = "Item \(items1.count + 1)"
                withAnimation {
                    items1.append(newItem)
                    items2.append(newItem)
                }
            }
        }
        .padding()
    }
}

struct Test_ArrayAnimation_Previews: PreviewProvider {
    static var previews: some View {
        Test_ArrayAnimation()
    }
}
