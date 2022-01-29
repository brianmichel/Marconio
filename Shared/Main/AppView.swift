//
//  AppView.swift
//  Lace
//
//  Created by Brian Michel on 1/29/22.
//

import Combine
import SwiftUI
import ComposableArchitecture
import LaceKit
import StoreKit

struct AppState: Equatable {
    var channels: [Channel] = []
    var mixtapes: [Mixtape] = []
    var currentlyPlayingMixtape: Mixtape?
    var currentlyPlayingChannel: Channel?
}

enum AppAction: Equatable {
    case loadInitialData
    case loadChannels
    case channelsResponse(Result<LiveBroadcastsResponse, RunnerError>)
    case loadMixtapes
    case mixtapesResponse(Result<MixtapesResponse, RunnerError>)
    case playMixtape(Mixtape)
    case playChannel(Channel)
    case pauseMixtape(Mixtape)
    case pauseChannel(Channel)
}

struct AppEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var uuid: () -> UUID
    var api: NTSAPI
}


let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
    Reducer { state, action, environment in
        switch action {
        case .loadInitialData:
            return .merge(
                try! environment.api.live()
                    .receive(on: environment.mainQueue)
                    .catchToEffect(AppAction.channelsResponse),

                try! environment.api.mixtapes()
                    .receive(on: environment.mainQueue)
                    .catchToEffect(AppAction.mixtapesResponse)
            )
        case .loadChannels:
            return try! environment.api.live()
                .receive(on: environment.mainQueue)
                .catchToEffect(AppAction.channelsResponse)
        case let .channelsResponse(.success(channels)):
            state.channels = channels.results
            return .none
        case let .channelsResponse(.failure(error)):
            // Do something with the error here
            print("unable to load channels: \(error)")
            return .none
        case .loadMixtapes:
            return try! environment.api.mixtapes()
                .receive(on: environment.mainQueue)
                .catchToEffect(AppAction.mixtapesResponse)
        case let .mixtapesResponse(.success(mixtapes)):
            state.mixtapes = mixtapes.results
            return .none
        case let .mixtapesResponse(.failure(error)):
            // Do something with the error here
            print("unable to load mixtapes: \(error)")
            return .none
        case let .playMixtape(mixtape):
            state.currentlyPlayingMixtape = mixtape
            return .none
        case let .playChannel(channel):
            state.currentlyPlayingChannel = channel
            return .none
        case let .pauseMixtape(mixtape):
            // Do nothing for right now
            return .none
        case let .pauseChannel(channel):
            // Do nothing for right now
            return .none
        }
    }
)
.debug()

struct AppView: View {
    let store: Store<AppState, AppAction>
    @ObservedObject var viewStore: ViewStore<ViewState, AppAction>

    init(store: Store<AppState, AppAction>) {
        self.store = store
        self.viewStore = ViewStore(self.store.scope(state: ViewState.init(state:)))
    }

    struct ViewState: Equatable {
        var channels: [Channel]
        var mixtapes: [Mixtape]

        init(state: AppState) {
            channels = state.channels
            mixtapes = state.mixtapes
        }
    }

    var body: some View {
        NavigationView {
            List {
                Section("Live") {
                    ForEach(viewStore.channels) { channel in
                        NavigationLink(destination: PlayerView(core: PlayerCore(playable: channel))) {
                            Label("Channel \(channel.channelName)", systemImage: "radio")
                        }
                    }
                }

                Section("Infinite Mixtapes") {
                    ForEach(viewStore.mixtapes) { mixtape in
                        NavigationLink(destination: PlayerView(core: PlayerCore(playable: mixtape))) {
                            Label("\(mixtape.title)", systemImage: mixtape.systemIcon)
                        }
                    }
                }
            }
            .listStyle(.sidebar)
            .navigationTitle("Channels")
#if os(macOS)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: toggleSidebar, label: {
                        Image(systemName: "sidebar.leading")
                    })
                }
                ToolbarItem(placement: .automatic) {
                    Button(action: refresh, label: {
                        Image(systemName: "arrow.clockwise")
                    }).keyboardShortcut(KeyEquivalent("r"), modifiers: [.command])
                }
            }
#endif
            Text("Now Playing").font(.largeTitle)
        }.onAppear {
            viewStore.send(.loadInitialData)
        }
    }

    private func refresh() {
        self.viewStore.send(.loadInitialData)
    }

    private func toggleSidebar() { // 2
#if os(iOS)
#else
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
#endif
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView(
            store: Store(
                initialState: AppState(
                    channels: [],
                    mixtapes: [],
                    currentlyPlayingMixtape: nil,
                    currentlyPlayingChannel: nil
                ),
                reducer: appReducer,
                environment: AppEnvironment(
                    mainQueue: .main,
                    uuid: UUID.init,
                    api: LiveAPI()
                )
            )
        )
    }
}
