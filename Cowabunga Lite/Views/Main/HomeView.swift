//
//  ContentView.swift
//  CowabungaJailed
//
//  Created by lemin on 3/16/23.
//

import SwiftUI

struct LinkCell: View {
    var imageName: String
    var url: String? = nil
    var title: String
    var contribution: String
    var systemImage: Bool = false
    var circle: Bool = true
    @Environment(\.openURL) var openURL
    
    var body: some View {
        NiceButton(text: AnyView(
            HStack(alignment: .center) {
                Group {
                    if systemImage {
                        Image(systemName: imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        if imageName != "" {
                            Image(imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }
                    }
                }
                .cornerRadius(circle ? .infinity : 0)
                .frame(width: 24, height: 24)
                Text(title).fontWeight(.bold)
                Text(contribution).foregroundColor(.secondary)
            }.padding(0)
        ), action: {
            if let url = url {
                openURL(URL(string: url)!)
            }
        })
    }
}

struct HomeView: View {
    
    @State private var versionBuildString: String?
    
    @State private var logger = Logger.shared
    @StateObject private var dataSingleton = DataSingleton.shared
    
    @ObservedObject var patreonAPI = PatreonAPI.shared
    @State private var patrons: [Patron] = []
    
    var body: some View {
        List {
            Group {
                HStack {
                    Image(systemName: dataSingleton.currentDevice?.ipad == true ? "ipad" : "iphone")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 35, height: 35)
                    VStack {
                        HStack {
                            Text(dataSingleton.currentDevice?.name ?? "No Device")
                                .bold()
                            Spacer()
                        }
                        HStack {
                            Text(dataSingleton.currentDevice?.version ?? "Please connect a device.")
                            if (dataSingleton.currentDevice?.uuid != nil) {
                                if (!DataSingleton.shared.deviceAvailable) {
                                    Text("Not Supported.")
                                        .foregroundColor(.red)
                                } else {
                                    if (!DataSingleton.shared.deviceTested) {
                                        Text("Possibly Supported (Untested).")
                                            .foregroundColor(.yellow)
                                    } else {
                                        Text("Supported!")
                                            .foregroundColor(.green)
                                    }
                                }
                            }
                            Spacer()
                        }
                    }
                }
                Divider()
                Group {
                    HStack {
                        LinkCell(imageName: "LeminLimez", url: "https://github.com/leminlimez", title: "LeminLimez", contribution: "Main Dev")
                        LinkCell(imageName: "avangelista", url: "https://github.com/Avangelista", title: "Avangelista", contribution: "Main Dev")
                    }
                    HStack {
                        LinkCell(imageName: "iTechExpert", url: "https://twitter.com/iTechExpert21", title: "iTech Expert", contribution: "Airdrop to Everyone, Known WiFi Networks")
                    }
                }
                Divider()
                HStack {
                    LinkCell(imageName: "discord.fill", url: "https://discord.gg/Cowabunga", title: "Join the Discord", contribution: "", circle: false)
                    LinkCell(imageName: "heart.fill", url: "https://patreon.com/Cowabunga_iOS", title: "Support us on Patreon", contribution: "", systemImage: true, circle: false)
                }
                Divider()
                Text("Cowabunga Lite - Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown") (\(versionBuildString ?? "Release"))")
                Divider()
                Text("Thanks to our Patrons:")
                    .bold()
                    .padding(.bottom, 10)
                LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 4), spacing: 10) {
                    ForEach($patrons) { patron in
                        Text(patron.name.wrappedValue)
                    }
                }
                .onAppear(perform: {
                    if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String, build != "0" {
                        versionBuildString = "Beta \(build)"
                    }
                    
                    // add the patreon supporters
                    loadPatrons()
                })
//                TextEditor(text: $logger.logText).font(Font.system(.body, design: .monospaced)).frame(height: 250).disabled(true)
            }
        }
    }
    
    func loadPatrons() {
        Task {
            do {
                patrons = try await patreonAPI.fetchPatrons()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
