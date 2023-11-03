import AppKit
import Foundation

public extension NSMutableAttributedString {
    func setTextAttribute(_ key: Key, to newValue: Any, at range: NSRange) {
        let safeRange = safeRange(for: range)
        guard length > 0, range.location >= 0 else { return }
        beginEditing()
        removeAttribute(key, range: safeRange)
        addAttribute(key, value: newValue, range: safeRange)
        endEditing()
    }
    
    func setAttributes(_ attrs: [NSAttributedString.Key: Any], range: NSRange) {
        let safeRange = self.safeRange(for: range)
        guard length > 0, safeRange.location >= 0 else { return }
        beginEditing()
        attrs.forEach { key, value in
            removeAttribute(key, range: safeRange)
            addAttribute(key, value: value, range: safeRange)
        }
        endEditing()
    }
    
    func makeBold(range: NSRange) {
        let boldFont = NSFont.boldSystemFont(ofSize: NSFont.systemFontSize)
        setTextAttribute(.font, to: boldFont, at: range)
    }
    
    func makeItalic(range: NSRange) {
        let italicFont = NSFont.systemFont(ofSize: NSFont.systemFontSize)
        italicFont.fontDescriptor.withSymbolicTraits([.italic])
        setTextAttribute(.font, to: italicFont, at: range)
    }
}
