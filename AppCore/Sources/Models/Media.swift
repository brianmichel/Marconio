//
//  Media.swift
//  
//
//  Created by Brian Michel on 1/27/22.
//

import Foundation
/**
 A set of media typically representing a show, broadcast, channel, etc.

 This is not the streamable media used to listen to NTS, but rather they are
 visual media that is used as a static representation of the streamable media.

 Anything prefixed with `background` tend to be optional and only show up as
 populated for a ``Broadcast``.

 Anything prefixed with `picture` _should_ show up as populated with any streamable
 media.
 */
public struct Media: Codable, Equatable {
    public let backgroundLarge: URL?
    public let backgroundMediumLarge: URL?
    public let backgroundMedium: URL?
    public let backgroundSmall: URL?
    public let backgroundThumb: URL?
    public let pictureLarge: URL
    public let pictureMediumLarge: URL
    public let pictureMedium: URL
    public let pictureSmall: URL
    public let pictureThumb: URL
}

extension Media {
    /// A placeholder of media to be used in mocking or previews.
    public static var placeholder: Self {
        return Media(backgroundLarge: nil,
                     backgroundMediumLarge: nil,
                     backgroundMedium: nil,
                     backgroundSmall: nil,
                     backgroundThumb: nil,
                     pictureLarge: URL(string: "https://media2.ntslive.co.uk/resize/1600x1600/cf5afb01-5a68-4fa0-a1c6-415b35d09ed6_1542931200.jpeg")!,
                     pictureMediumLarge: URL(string: "https://media2.ntslive.co.uk/resize/800x800/cf5afb01-5a68-4fa0-a1c6-415b35d09ed6_1542931200.jpeg")!,
                     pictureMedium: URL(string: "https://media.ntslive.co.uk/resize/400x400/cf5afb01-5a68-4fa0-a1c6-415b35d09ed6_1542931200.jpeg")!,
                     pictureSmall: URL(string: "https://media3.ntslive.co.uk/resize/200x200/cf5afb01-5a68-4fa0-a1c6-415b35d09ed6_1542931200.jpeg")!,
                     pictureThumb: URL(string: "https://media3.ntslive.co.uk/resize/100x100/cf5afb01-5a68-4fa0-a1c6-415b35d09ed6_1542931200.jpeg")!)
    }
}
