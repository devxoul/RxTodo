//
//  String+BoundingRect.swift
//  RxTodo
//
//  Created by 전수열 on 7/2/16.
//  Copyright (c) 2016 StyleShare Inc. All rights reserved.
//

import UIKit

extension String {

    func boundingRectWithSize(_ size: CGSize, attributes: [String: AnyObject]) -> CGRect {
        let options: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
        return snap(self.boundingRect(with: size, options: options, attributes: attributes, context: nil))
    }

    func sizeThatFits(_ size: CGSize, font: UIFont, maximumNumberOfLines: Int = 0) -> CGSize {
        let attributes = [NSFontAttributeName: font]
        var size = self.boundingRectWithSize(size, attributes: attributes).size
        if maximumNumberOfLines > 0 {
            size.height = min(size.height, CGFloat(maximumNumberOfLines) * font.lineHeight)
        }
        return snap(size)
    }

    func widthWithFont(_ font: UIFont, maximumNumberOfLines: Int = 0) -> CGFloat {
        let size = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        return snap(self.sizeThatFits(size, font: font, maximumNumberOfLines: maximumNumberOfLines).width)
    }

    func heightThatFitsWidth(_ width: CGFloat, font: UIFont, maximumNumberOfLines: Int = 0) -> CGFloat {
        let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        return snap(self.sizeThatFits(size, font: font, maximumNumberOfLines: maximumNumberOfLines).height)
    }

}
