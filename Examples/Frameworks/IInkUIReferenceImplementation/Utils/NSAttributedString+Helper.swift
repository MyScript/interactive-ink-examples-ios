// Copyright @ MyScript. All rights reserved.

import Foundation

/// Extension for NSAttributedString to create an Instance of NSAttributedString with an IINKText and a collection of IINKTextSpan

extension NSAttributedString {

    static func attributedString(text: IINKText, spans:[IINKTextSpan]) -> NSAttributedString {
        let completeAttributedString = NSMutableAttributedString(string: text.label)
        // Construct the line with all styles inside
        for span in spans {
            let begin = text.getGlyphUtf16Begin(at: span.beginPosition, error: nil)
            let end = text.getGlyphUtf16End(at: span.endPosition - 1, error: nil)
            let range = NSMakeRange(Int(begin), Int(end - begin))
            if let newFont = UIFont.fontFromStyle(style: span.style,
                                                  string: text.label) {
                let dict: [Key:Any] = [.font : newFont,
                                       .ligature : NSNumber(value: 0)]
                completeAttributedString.setAttributes(dict, range: range)
            }
        }
        return completeAttributedString
    }
}
