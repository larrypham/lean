//
//  LeanIcons.swift
//  Lean
//
//  SF Symbols used throughout the Lean Browser UI.
//

import AppKit
import SwiftUI

public enum LeanIcon: String, CaseIterable, Identifiable, Hashable, Codable {
    case appWindow
    case appleLogo
    case arrowCircleDown
    case arrowCircleRight
    case arrowClockwise
    case arrowCounterClockwise
    case arrowLeft
    case arrowRight
    case arrowSquareOut
    case arrowUpRight
    case arrowsCounterClockwise
    case arrowsOutSimple
    case bookmark
    case bookmarkSimple
    case browser
    case caretDown
    case caretLeft
    case caretRight
    case chatText
    case chats
    case check
    case checkCircle
    case checkSquare
    case circleHalf
    case clock
    case clockCounterClockwise
    case cloud
    case code
    case columns
    case command
    case compass
    case copy
    case cpu
    case dotsThree
    case `extension` = "extension"
    case eyeSlash
    case file
    case fileArchive
    case fileAudio
    case fileCsv
    case fileImage
    case filePdf
    case filePpt
    case fileText
    case fileVideo
    case fire
    case folder
    case folderPlus
    case gear
    case githubLogo
    case hash
    case key
    case layout
    case leaf
    case lightning
    case list
    case lock
    case magnifyingGlass
    case minus
    case minusCircle
    case moon
    case mouse
    case package
    case palette
    case pin
    case pinSlash
    case play
    case plus
    case plusCircle
    case redditLogo
    case shield
    case shieldCheck
    case sidebar
    case slackLogo
    case sliders
    case slidersHorizontal
    case sparkle
    case speakerHigh
    case speakerSlash
    case squaresFour
    case star
    case sun
    case tabs
    case textAlignLeft
    case trash
    case tray
    case warning
    case x
    case xCircle
    case youtubeLogo

    public static let puzzlePiece: LeanIcon = .extension
    public static let extensionIcon: LeanIcon = .extension
    public static let speaker: LeanIcon = .speakerHigh
    public static let speakerMute: LeanIcon = .speakerSlash
    public static let mute: LeanIcon = .speakerSlash
    public static let split: LeanIcon = .columns

    public var id: String { rawValue }

    private static let imageCache = NSCache<NSString, NSImage>()

    /// Regular-weight SF Symbol for compatibility with AppKit call sites.
    public var nsImage: NSImage {
        configuredImage(weight: .regular, prefersFill: false)
    }

    /// Filled SF Symbol when the symbol provides a filled variant.
    public var fill: Image {
        Image(nsImage: configuredImage(weight: .regular, prefersFill: true))
            .interpolation(.high)
            .resizable()
    }

    /// Bold SF Symbol for compact controls and emphasized actions.
    public var bold: Image {
        Image(nsImage: configuredImage(weight: .bold, prefersFill: false))
            .interpolation(.high)
            .resizable()
    }

    /// Regular SF Symbol for standard interface affordances.
    public var uiIcon: Image {
        Image(nsImage: nsImage)
            .interpolation(.high)
            .resizable()
    }

    private func configuredImage(weight: NSFont.Weight, prefersFill: Bool) -> NSImage {
        let requestedName = prefersFill ? "\(symbolName).fill" : symbolName
        let cacheKey = "\(requestedName)-\(weight.rawValue)" as NSString
        if let cached = Self.imageCache.object(forKey: cacheKey) {
            return cached
        }

        let baseImage = NSImage(
            systemSymbolName: requestedName,
            accessibilityDescription: accessibilityDescription
        ) ?? NSImage(
            systemSymbolName: symbolName,
            accessibilityDescription: accessibilityDescription
        ) ?? NSImage(
            systemSymbolName: "questionmark.square",
            accessibilityDescription: accessibilityDescription
        ) ?? NSImage(size: NSSize(width: 24, height: 24))

        let configuration = NSImage.SymbolConfiguration(pointSize: 24, weight: weight)
        let image = baseImage.withSymbolConfiguration(configuration) ?? baseImage
        image.isTemplate = true
        Self.imageCache.setObject(image, forKey: cacheKey)
        return image
    }

    private var accessibilityDescription: String {
        rawValue.reduce(into: "") { result, character in
            if character.isUppercase {
                result.append(" ")
                result.append(character.lowercased())
            } else {
                result.append(character)
            }
        }
    }

    private var symbolName: String {
        switch self {
        case .appWindow: "macwindow"
        case .appleLogo: "apple.logo"
        case .arrowCircleDown: "arrow.down.circle"
        case .arrowCircleRight: "arrow.right.circle"
        case .arrowClockwise: "arrow.clockwise"
        case .arrowCounterClockwise: "arrow.counterclockwise"
        case .arrowLeft: "arrow.left"
        case .arrowRight: "arrow.right"
        case .arrowSquareOut: "arrow.up.forward.square"
        case .arrowUpRight: "arrow.up.right"
        case .arrowsCounterClockwise: "arrow.triangle.2.circlepath"
        case .arrowsOutSimple: "arrow.up.left.and.arrow.down.right"
        case .bookmark, .bookmarkSimple: "bookmark"
        case .browser: "safari"
        case .caretDown: "chevron.down"
        case .caretLeft: "chevron.left"
        case .caretRight: "chevron.right"
        case .chatText: "text.bubble"
        case .chats: "bubble.left.and.bubble.right"
        case .check: "checkmark"
        case .checkCircle: "checkmark.circle"
        case .checkSquare: "checkmark.square"
        case .circleHalf: "circle.lefthalf.filled"
        case .clock: "clock"
        case .clockCounterClockwise: "clock.arrow.circlepath"
        case .cloud: "icloud"
        case .code: "chevron.left.forwardslash.chevron.right"
        case .columns: "rectangle.split.2x1"
        case .command: "command"
        case .compass: "location.north.circle"
        case .copy: "doc.on.doc"
        case .cpu: "cpu"
        case .dotsThree: "ellipsis"
        case .extension: "puzzlepiece.extension"
        case .eyeSlash: "eye.slash"
        case .file: "doc"
        case .fileArchive: "doc.zipper"
        case .fileAudio: "waveform"
        case .fileCsv: "tablecells"
        case .fileImage: "photo"
        case .filePdf: "doc.richtext"
        case .filePpt: "rectangle.stack"
        case .fileText: "doc.text"
        case .fileVideo: "film"
        case .fire: "flame"
        case .folder: "folder"
        case .folderPlus: "folder.badge.plus"
        case .gear: "gearshape"
        case .githubLogo: "chevron.left.forwardslash.chevron.right"
        case .hash: "number"
        case .key: "key"
        case .layout: "rectangle.3.group"
        case .leaf: "leaf"
        case .lightning: "bolt"
        case .list: "list.bullet"
        case .lock: "lock"
        case .magnifyingGlass: "magnifyingglass"
        case .minus: "minus"
        case .minusCircle: "minus.circle"
        case .moon: "moon"
        case .mouse: "computermouse"
        case .package: "shippingbox"
        case .palette: "paintpalette"
        case .pin: "pin"
        case .pinSlash: "pin.slash"
        case .play: "play"
        case .plus: "plus"
        case .plusCircle: "plus.circle"
        case .redditLogo: "bubble.left.and.bubble.right"
        case .shield: "shield"
        case .shieldCheck: "checkmark.shield"
        case .sidebar: "sidebar.left"
        case .slackLogo: "number"
        case .sliders: "slider.vertical.3"
        case .slidersHorizontal: "slider.horizontal.3"
        case .sparkle: "sparkles"
        case .speakerHigh: "speaker.wave.3"
        case .speakerSlash: "speaker.slash"
        case .squaresFour: "square.grid.2x2"
        case .star: "star"
        case .sun: "sun.max"
        case .tabs: "rectangle.on.rectangle"
        case .textAlignLeft: "text.alignleft"
        case .trash: "trash"
        case .tray: "tray"
        case .warning: "exclamationmark.triangle"
        case .x: "xmark"
        case .xCircle: "xmark.circle"
        case .youtubeLogo: "play.rectangle"
        }
    }
}
