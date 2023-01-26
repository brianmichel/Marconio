//
//  Settings.swift
//  
//
//  Created by Brian Michel on 1/24/23.
//

import ComposableArchitecture

public enum LCDAccentColor: Int, CaseIterable {
    case green = 0x64BF1F
    case orange = 0xBF5B1F
    case yellow = 0xBEBF1F
    case blue = 0x1FB3BF
    case purple = 0xBF1FB4
    case red = 0xBF1F2B
}

public struct SettingsReducer: ReducerProtocol {
    public struct State: Equatable {
        public var accentColor: LCDAccentColor

        public init(accentColor: LCDAccentColor = .orange) {
            self.accentColor = accentColor
        }
    }

    public enum Action: Equatable {
        case nextAccentColor
    }

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .nextAccentColor:
                state.accentColor = nextAccentColor(state: state)
                return .none
            }
        }
    }

    private func nextAccentColor(state: State) -> LCDAccentColor {
        let allColors = LCDAccentColor.allCases
        guard let currentIndex = allColors.firstIndex(of: state.accentColor) else { return .orange }
        return allColors[(currentIndex + 1) % allColors.count]
    }
}
