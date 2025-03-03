import Foundation

struct TransformOptions {
    let width: Int?
    let height: Int?
    let resize: String?  // "cover", "contain", or "fill"
    let quality: Int?    // 1-100
    
    init(
        width: Int? = nil,
        height: Int? = nil,
        resize: String? = nil,
        quality: Int? = nil
    ) {
        self.width = width
        self.height = height
        self.resize = resize
        self.quality = quality
    }
} 