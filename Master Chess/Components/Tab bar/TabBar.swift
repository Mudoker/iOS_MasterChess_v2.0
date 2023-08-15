import SwiftUI

struct TabBar: View {
    @State private var tabSelection = 1
    
    var body: some View {
        TabView(selection: $tabSelection) {
            NavigationView {
                MenuView()
            }
            .tag(0)
            
            NavigationView {
                ProfileView()
            }
            .tag(1)
        }
        .overlay(alignment: .bottom) {
            CustomTabbar(tabSelection: $tabSelection) // Use binding
        }
    }
}


struct CustomTabbar: View {
    @Binding var tabSelection: Int // Use binding instead of local @State
    @Namespace var namespace

    let tabItems: [(image: String, page: String)] = [
        ("house", "Dashboard"),
        ("gear", "Profile")
    ]
    
    var body: some View {
        GeometryReader { proxy in
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    
                    ZStack {
                        Capsule()
                            .frame(width: proxy.size.width / 1.7, height: proxy.size.height/12)
                            .foregroundColor(.gray.opacity(0.2))
                            .shadow(radius: 2)
                        
                        HStack(spacing: (proxy.size.width - 180) / CGFloat(tabItems.count + 1)) {
                            ForEach(0..<2) { index in // Use tabItems.count here
                                Button {
                                    tabSelection = index // Update the binding
                                    print(tabSelection)
                                } label: {
                                    VStack {
                                        Image(systemName: tabItems[index].image)
                                            .font(.title3)
                                            .foregroundColor(tabSelection == index ? .blue : .gray) // Update index comparison
                                            .frame(width: 24, height: 24)
                                            .cornerRadius(10)
                                            .matchedGeometryEffect(id: tabItems[index].page, in: namespace)
                                        Text(tabItems[index].page)
                                            .font(.caption)
                                            .foregroundColor(tabSelection == index ? .blue : .gray) // Update index comparison
                                    }
                                }
                            }
                        }
                    }
                    
                    Spacer()
                }
            }
        }
    }
}



struct TabBar_Previews: PreviewProvider {
    static var previews: some View {
        TabBar()
    }
}
