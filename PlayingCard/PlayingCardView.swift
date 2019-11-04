//
//  PlayingCardView.swift
//  PlayingCard
//
//  Created by Joshua Olson on 11/3/19.
//  Copyright © 2019 solarmist. All rights reserved.
//

import UIKit

@IBDesignable
class PlayingCardView: UIView {

    @IBInspectable
    var rank: Int = 11  { didSet { setNeedsDisplay(); setNeedsLayout() } }
    @IBInspectable
    var suit: String = "❤️" { didSet { setNeedsDisplay(); setNeedsLayout() } }
    @IBInspectable
    var isFaceUp: Bool = true  { didSet { setNeedsDisplay(); setNeedsLayout() } }

    var faceCardScale: CGFloat = SizeRatio.faceCardImageSizeToBoundsSize { didSet { setNeedsDisplay() } }
    private func centeredAttributedString(_ string: String, fontSize: CGFloat) -> NSAttributedString {
        var font = UIFont.preferredFont(forTextStyle: .body).withSize(fontSize)
        font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        return NSAttributedString(string: string, attributes: [.paragraphStyle: paragraphStyle, .font: font])
    }

    @objc func adjustFaceCardSclae(byHandlingGestureRecognizedBy recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
            case .changed, .ended:
                faceCardScale *= recognizer.scale
                recognizer.scale = 1.0
            default: break
        }
    }
    private lazy var upperLeftCornerLabel = createCornerLabel()
    private lazy var lowerRightCornerLabel = createCornerLabel()

    private func drawPips() {
        let pipsPerRowForRank = [
            [0],  // Facecards
            [1],  // 1
            [1,1],  // 2
            [1,1,1], // 3
            [2,2],  // 4
            [2,1,2],  // 5
            [2,2,2],  // 6
            [2,1,2,2],  // 7
            [2,2,2,2],  // 8
            [2,2,1,2,2],  // 9
            [2,2,2,2,2],  // 10
        ]
        func createPipString(thatFits pipRect: CGRect) -> NSAttributedString {
            let maxVerticalPipCount = CGFloat(pipsPerRowForRank.reduce(0) { max($1.count, $0) })
            let maxHorizontalPipCount = CGFloat(pipsPerRowForRank.reduce(0) { max($1.max() ?? 0, $0) })
            let verticalPipRowSpacing = pipRect.size.height / maxVerticalPipCount
            let attemptedPipString = centeredAttributedString(suit, fontSize: verticalPipRowSpacing)
            let probablyOkayPipStringFontSize = verticalPipRowSpacing / (attemptedPipString.size().height / verticalPipRowSpacing)
            let probablyOkayPipString = centeredAttributedString(suit, fontSize: probablyOkayPipStringFontSize)
            if probablyOkayPipString.size().width > pipRect.size.width / maxHorizontalPipCount {
                return centeredAttributedString(suit, fontSize: probablyOkayPipStringFontSize / (probablyOkayPipString.size().width / (pipRect.size.width / maxHorizontalPipCount)))
            } else {
                return probablyOkayPipString
            }
        }

        if pipsPerRowForRank.indices.contains(rank) {
            let pipsPerRow = pipsPerRowForRank[rank]
            var pipRect = bounds
                .insetBy(dx: cornerOffset, dy: cornerOffset)
                .insetBy(dx: cornerString.size().width, dy: cornerString.size().height / 2)
            let pipString = createPipString(thatFits: pipRect)
            let pipRowSpacing = pipRect.size.height / CGFloat(pipsPerRow.count)
            pipRect.size.height = pipString.size().height
            pipRect.origin.y += (pipRowSpacing - pipRect.size.height) / 2
            for pipCount in pipsPerRow {
                switch pipCount {
                    case 1: pipString.draw(in: pipRect)
                    case 2:
                        pipString.draw(in: pipRect.leftHalf)
                        pipString.draw(in: pipRect.rightHalf)
                    default:
                        break
                }
                pipRect.origin.y += pipRowSpacing
            }
        }
    }

    private func createCornerLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0  // Unlimited
        addSubview(label)
        return label
    }

    private func configureCornerLabel(_ label: UILabel) {
        label.attributedText = cornerString
        label.frame.size = CGSize.zero
        // If the label has width it will keep that and only set the height
        label.sizeToFit()
        label.isHidden = !isFaceUp
    }

    // This forces a redraw if, for example, the accessiblity font scale changes
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setNeedsLayout()
        setNeedsDisplay()
    }
    // Called after setNeedsLayout()
    override func layoutSubviews() {
        super.layoutSubviews()  // Runs autolayout stuff

        configureCornerLabel(upperLeftCornerLabel)
        configureCornerLabel(lowerRightCornerLabel)
        // This rotates around the origin point (not the center)
        lowerRightCornerLabel.transform = CGAffineTransform.identity
            .translatedBy(x: lowerRightCornerLabel.frame.size.width, y: lowerRightCornerLabel.frame.size.height)
            .rotated(by: CGFloat.pi)

        // frame is position, bounds is where we draw
        upperLeftCornerLabel.frame.origin = bounds.origin.offsetBy(dx: cornerOffset, dy: cornerOffset)

        lowerRightCornerLabel.frame.origin = CGPoint(x: bounds.maxX, y: bounds.maxY)
            .offsetBy(dx: -lowerRightCornerLabel.bounds.width, dy: -lowerRightCornerLabel.bounds.height)
            .offsetBy(dx: -cornerOffset, dy: -cornerOffset)
    }

    // Called after setNeedsDisplay()
    override func draw(_ rect: CGRect) {
        // Example for how to draw directly with CoreGraphics
//        if let context = UIGraphicsGetCurrentContext() {
//            context.addArc(center: CGPoint(x: bounds.midX, y: bounds.midY), radius: 100.0, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
//            context.setLineWidth(5.0)
//            UIColor.green.setFill()
//            UIColor.red.setStroke()
//            context.strokePath()
//            context.fillPath()
//            // These properties are consumed by the Arc
//        }
        let roundedRect = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        roundedRect.addClip()  // Make this a clipping shape
        UIColor.white.setFill()
        roundedRect.fill()

        // Example for how to draw directly with UIBezierPath
//        let path = UIBezierPath()
//        path.addArc(withCenter: CGPoint(x: bounds.midX, y: 100.0), radius: 100.0, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
//        path.lineWidth = 5.0
//        UIColor.green.setFill()
//        UIColor.red.setStroke()
//        path.stroke()
//        path.fill()
        // This object continues to exist and so these properties remain set on it.
        if !isFaceUp {
            if let cardBackImage = UIImage(named: "cardback", in: Bundle(for: self.classForCoder), compatibleWith: traitCollection) {
                cardBackImage.draw(in: bounds)
            }

        } else {
            if let faceCardImage = UIImage(named: rankString + suit, in: Bundle(for: self.classForCoder), compatibleWith: traitCollection) {
                faceCardImage.draw(in: bounds.zoom(by: faceCardScale))
            } else {
                drawPips()
            }
        }
    }

    private var cornerString: NSAttributedString {
        return centeredAttributedString(rankString + "\n" + suit, fontSize: cornerFontSize)
    }
}

// Customize the PlayingCardView for this application
extension PlayingCardView {
    // This is the convention for doing constants in Swift
    private struct SizeRatio {
        static let cornerFontSizeToBoundsHeight: CGFloat = 0.085
        static let cornerRadiusToBoundsHeight: CGFloat = 0.06
        static let cornerOffsetToCornerRadius: CGFloat = 0.33
        static let faceCardImageSizeToBoundsSize: CGFloat = 0.75
    }
    private var cornerRadius: CGFloat {
        return bounds.size.height * SizeRatio.cornerRadiusToBoundsHeight
    }
    private var cornerOffset: CGFloat {
        return cornerRadius * SizeRatio.cornerOffsetToCornerRadius
    }
    private var cornerFontSize: CGFloat {
        return bounds.size.height * SizeRatio.cornerFontSizeToBoundsHeight
    }
    private var rankString: String {
        switch rank {
            case 1: return "A"
            case 2...10: return String(rank)
            case 11: return "J"
            case 12: return "Q"
            case 13: return "K"
            default: return "?"
        }
    }
}

extension CGRect {
    var leftHalf: CGRect {
        return CGRect(x: minX, y: minY, width: width/2, height: height)
    }
    var rightHalf: CGRect {
        return CGRect(x: midX, y: minY, width: width/2, height: height)
    }
    // Returns a rectangle that is smaller or larger than the source rectangle with the same center point.
    func inset(by size: CGSize) -> CGRect {
        return insetBy(dx: size.width, dy: size.height)
    }
    func size(to size: CGSize) -> CGRect {
        return CGRect(origin: origin, size: size)
    }
    func zoom(by scale: CGFloat) -> CGRect {
        let newWidth = width * scale
        let newHeight = height * scale
        return insetBy(dx: (width - newWidth) / 2, dy: (height - newHeight) / 2)
    }
}

extension CGPoint {
    func offsetBy(dx: CGFloat, dy: CGFloat) -> CGPoint {
        return CGPoint(x: x+dx, y: y+dy)
    }
}
