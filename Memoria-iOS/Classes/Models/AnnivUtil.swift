//
//  AnnivUtil.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2019/03/02.
//  Copyright © 2019 nerco studio. All rights reserved.
//

import UIKit

struct AnnivUtil {
    /// 記念日か誕生日かによってタイトルが違うので、ここで判断して返す
    static func getName(from anniv: Anniv) -> String? {
        // 記念日の名称。誕生日だったら苗字と名前を繋げて表示
        switch anniv.category {
        case .anniv:
            return anniv.title
            
        case .birthday:
            return String(format: "whoseBirthday".localized,
                          arguments: [anniv.familyName ?? "",
                                      anniv.givenName ?? ""])
        }
    }
    static func getName(from anniv: [String : Any]) -> String? {
        // 記念日の分類
        let category = AnnivType(category: anniv["category"] as! String)
        // 記念日の名称。誕生日だったら苗字と名前を繋げて表示
        switch category {
        case .anniv:
            return anniv["title"] as? String
            
        case .birthday:
            return String(format: "whoseBirthday".localized,
                          arguments: [anniv["familyName"] as! String,
                                      anniv["givenName"] as! String])
        }
    }

    /// 次の記念日までの日数を文字列で取得する
    ///
    /// - Parameter remainingDays: 次回記念日までの日数
    /// - Returns: 後何日か、もしくは何日過ぎたかを文字列で返す
    static func getRemainingDaysString(from remainingDays: Int) -> String {
        return remainingDays >= 0
            ? String(format: "remainingDays".localized, remainingDays.description)
            : String(format: "elapsedDays".localized, (-remainingDays).description)
        
    }
    
    /// 記念日のアイコン画像を返す、ない場合はデフォルト画像を返す
    static func getIconImage(from anniv: Anniv) -> UIImage {
        if let iconImageData = anniv.iconImage,
            let iconImage = UIImage(data: iconImageData) {
            return iconImage
        } else {
            // アイコンがない場合はデフォルトアイコンを使用
            return anniv.category == .birthday
                ? #imageLiteral(resourceName: "Ribbon") // 誕生日
                : #imageLiteral(resourceName: "giftBox") // それ以外
        }
    }
    static func getIconImage(from anniv: [String : Any]) -> UIImage {
        if let iconImageData = anniv["iconImage"] as? Data,
            let iconImage = UIImage(data: iconImageData) {
            return iconImage
        } else {
            // 記念日の分類
            let category = AnnivType(category: anniv["category"] as! String)
            // アイコンがない場合はデフォルトアイコンを使用
            return category == .birthday
                ? #imageLiteral(resourceName: "Ribbon") // 誕生日
                : #imageLiteral(resourceName: "giftBox") // それ以外
        }
    }
}