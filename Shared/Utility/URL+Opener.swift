//
//  URL+Opener.swift
//  Lace (iOS)
//
//  Created by Brian Michel on 1/29/22.
//

import Foundation

#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif

extension URL {
    func openExternally() {
        #if os(macOS)
        NSWorkspace.shared.open(self)
        #elseif os(iOS)
        UIApplication.shared.open(self, options: [:], completionHandler: nil)
        #endif
    }
}
