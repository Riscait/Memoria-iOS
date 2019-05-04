//
//  AnnivEmptyView.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2019/04/30.
//  Copyright © 2019 nerco studio. All rights reserved.
//

import UIKit

// MARK: - Notification.Name
extension Notification.Name {
    // 文字列の定数化（通知側・受信側で使用）
    static let presentAnnivEditVC = Notification.Name("presentAnnivEditVC")
    static let importBirthday = Notification.Name("importBirthday")
}

final class AnnivEmptyView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNib()
    }

    private func loadNib() {
        
        guard let view = UINib(nibName: "AnnivEmptyView", bundle: nil)
            .instantiate(withOwner: self, options: nil).first as? UIView else {
                Log.warn("nib = nilです")
                return
        }

        view.frame = self.bounds
        addSubview(view)
    }
    
    @IBAction private func didTapAddAnnivButton(_ sender: RoundedButton) {
        NotificationCenter.default.post(name: .presentAnnivEditVC, object: nil)
    }
    
    @IBAction private func didTapImportBirthdayButton(_ sender: RoundedButton) {
        NotificationCenter.default.post(name: .importBirthday, object: nil)
    }
}
