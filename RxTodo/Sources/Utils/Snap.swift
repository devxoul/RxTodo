//
//  CeilUtil.swift
//  StyleShare
//
//  Created by 전수열 on 8/27/15.
//  Copyright (c) 2015 StyleShare Inc. All rights reserved.
//

import UIKit

/// Ceil to snap pixel
func snap(x: CGFloat) -> CGFloat {
    let scale = UIScreen.mainScreen().scale
    return ceil(x * scale) / scale
}

func snap(point: CGPoint) -> CGPoint {
    return CGPoint(x: snap(point.x), y: snap(point.y))
}

func snap(size: CGSize) -> CGSize {
    return CGSize(width: snap(size.width), height: snap(size.height))
}

func snap(rect: CGRect) -> CGRect {
    return CGRect(origin: snap(rect.origin), size: snap(rect.size))
}
