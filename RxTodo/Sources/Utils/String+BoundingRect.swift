//
//  String+BoundingRect.swift
//  RxTodo
//
//  Created by 전수열 on 7/2/16.
//  Copyright (c) 2016 StyleShare Inc. All rights reserved.
//

import UIKit

extension String {
    func boundingRect(with size: CGSize, attributes: [String: AnyObject]) -> CGRect {
        let options: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
        let rect = boundingRect(with: size, options: options, attributes: attributes, context: nil)
        return snap(rect)
    }

    func size(fits size: CGSize, font: UIFont, maximumNumberOfLines: Int = 0) -> CGSize {
        let attributes = [NSFontAttributeName: font]
        var size = boundingRect(with: size, attributes: attributes).size
        if maximumNumberOfLines > 0 {
            size.height = min(size.height, CGFloat(maximumNumberOfLines) * font.lineHeight)
        }
        return size
    }

    func width(with font: UIFont, maximumNumberOfLines: Int = 0) -> CGFloat {
        let size = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        return self.size(fits: size, font: font, maximumNumberOfLines: maximumNumberOfLines).width
    }

    func height(fits width: CGFloat, font: UIFont, maximumNumberOfLines: Int = 0) -> CGFloat {
        let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        return self.size(fits: size, font: font, maximumNumberOfLines: maximumNumberOfLines).height
    }
}
