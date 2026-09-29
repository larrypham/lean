import AppKit
import SwiftUI

extension View {
    @ViewBuilder
    func liquidGlassBarSurface(legacyBackground: Color) -> some View {
        if #available(macOS 26.0, *) {
            glassEffect(.regular, in: .rect(cornerRadius: 0))
        } else {
            background(legacyBackground)
        }
    }

    @ViewBuilder
    func liquidGlassSelectedSurface(
        isSelected: Bool,
        cornerRadius: CGFloat,
        legacyBackground: Color,
        legacyStroke: Color,
        legacyShadow: Color = .clear,
        legacyShadowRadius: CGFloat = 0
    ) -> some View {
        if #available(macOS 26.0, *), isSelected {
            glassEffect(.regular.interactive(), in: .rect(cornerRadius: cornerRadius))
        } else if isSelected {
            background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(legacyBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(legacyStroke, lineWidth: 1)
                    )
                    .shadow(color: legacyShadow, radius: legacyShadowRadius, x: 0, y: 1)
            )
        } else {
            self
        }
    }

    @ViewBuilder
    func liquidGlassControlSurface(
        cornerRadius: CGFloat,
        legacyBackground: Color,
        legacyStroke: Color
    ) -> some View {
        if #available(macOS 26.0, *) {
            glassEffect(.regular.interactive(), in: .rect(cornerRadius: cornerRadius))
        } else {
            background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(legacyBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(legacyStroke, lineWidth: 1)
                    )
            )
        }
    }

    @ViewBuilder
    func liquidGlassDialogSurface(
        cornerRadius: CGFloat,
        legacyBackground: Color,
        legacyStroke: Color,
        legacyMaterial: NSVisualEffectView.Material = .popover,
        usesLegacyBlur: Bool = true,
        primaryShadow: Color,
        primaryShadowRadius: CGFloat,
        primaryShadowY: CGFloat,
        secondaryShadow: Color = .clear
    ) -> some View {
        if #available(macOS 26.0, *) {
            clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .glassEffect(.regular, in: .rect(cornerRadius: cornerRadius))
        } else {
            background(legacyBackground)
                .background {
                    if usesLegacyBlur {
                        VisualEffectBlur(material: legacyMaterial, blendingMode: .withinWindow)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(legacyStroke, lineWidth: 0.75)
                )
                .shadow(
                    color: primaryShadow,
                    radius: primaryShadowRadius,
                    x: 0,
                    y: primaryShadowY
                )
                .shadow(color: secondaryShadow, radius: 2, x: 0, y: 1)
        }
    }
}
