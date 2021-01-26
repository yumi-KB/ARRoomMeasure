//
//  UIView+ConvertToImage.swift
//  ARRoomMeasure
//
//  Created by yumi kanebayashi on 2021/01/26.
//

import UIKit

public extension UIView {
    func convertToImage() -> UIImage {
       let imageRenderer = UIGraphicsImageRenderer.init(size: bounds.size)
        return imageRenderer.image { context in
            layer.render(in: context.cgContext)
        }
    }
}
