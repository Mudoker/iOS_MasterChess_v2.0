import SwiftUI

struct TabBar: View {
    @State private var tabSelection = 0
    @AppStorage("selectedLanguage") var selectedLanguage = "en" // Default language is English

    var body: some View {
        TabView(selection: $tabSelection) {
            NavigationView {
                MenuView()
            }
            .tag(0)
            .toolbarBackground(.hidden, for: .tabBar)
            
            
            NavigationView {
                SettingView()
            }
            .tag(1)
            .toolbarBackground(.hidden, for: .tabBar)

        }
        .environment(\.locale, Locale(identifier: selectedLanguage)) // Apply the selected language
        .overlay(alignment: .bottom) {
            CustomTabbar(tabSelection: $tabSelection)
        }
    }
}


struct CustomTabbar: View {
    @Binding var tabSelection: Int
    @Namespace var namespace
    @AppStorage("selectedLanguage") var selectedLanguage = "en" // Default language is English

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
                    HStack(spacing: (proxy.size.width - 180) / CGFloat(tabItems.count + 1)) {
                        ForEach(0..<2) { index in // Use tabItems.count here
                            Button {
                                tabSelection = index // Update the binding
                            } label: {
                                VStack {
                                    Image(systemName: tabItems[index].image)
                                        .font(.title3)
                                        .foregroundColor(tabSelection == index ? .blue : .gray)
                                        .frame(width: 24, height: 24)
                                        .cornerRadius(10)
                                        .matchedGeometryEffect(id: tabItems[index].page, in: namespace)
                                    Text(LocalizedStringKey(tabItems[index].page))
                                        .font(.caption)
                                        .foregroundColor(tabSelection == index ? .blue : .gray)
                                }
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding(.vertical)
            }
            .edgesIgnoringSafeArea(.all)
        }
        .environment(\.locale, Locale(identifier: selectedLanguage)) // Apply the selected language
    }
}

struct TabBar_Previews: PreviewProvider {
    static var previews: some View {
        TabBar()
    }
}
