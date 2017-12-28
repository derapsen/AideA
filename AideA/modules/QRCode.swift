//
//  QRCode.swift
//  XmasPB
//
//  Created by 石郷 祐介 on 2015/10/26.
//  Copyright © 2015年 Yusk. All rights reserved.
//

import UIKit

class QRCode
{
	class func generateQRCode(_ text:String, size:CGSize = CGSize(width: 480, height: 480)) -> UIImage?
	{
		if let ciFilter = CIFilter(name: "CIQRCodeGenerator")
		{
			let data = text.data(using: String.Encoding.utf8)
			ciFilter.setValue(data, forKey: "inputMessage")
			ciFilter.setValue("L", forKey: "inputCorrectionLevel")
			
			if let outputImage = ciFilter.outputImage
			{
				let ciContext = CIContext(options: nil)
				let cgImg = ciContext.createCGImage(outputImage, from: outputImage.extent)
				var img = UIImage(cgImage: cgImg!, scale: 1.0, orientation: UIImageOrientation.up)
				
				UIGraphicsBeginImageContext(size)
				
				let context = UIGraphicsGetCurrentContext()
				context!.interpolationQuality = CGInterpolationQuality.none
				
				img.draw(in: CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height))
				img = UIGraphicsGetImageFromCurrentImageContext()!
				
				UIGraphicsEndImageContext()
				
				return img
			}
		}
		return nil
	}
}
