//
//  AnnivCell.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/11/08.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit

final class AnnivCell: UICollectionViewCell {
    /// 角丸担当のUIView
    @IBOutlet weak var roundedView: UIView!
    @IBOutlet weak var annivNameLabel: UILabel!
    @IBOutlet weak var annivDateLabel: UILabel!
    @IBOutlet weak var remainingDaysLabel: TagLabel!
    @IBOutlet weak var annivIconImage: IconImageView!
    
    // ここで設定した値は不変。全セル共通のプロパティを設定する
    override func draw(_ rect: CGRect) {
        // 一つのViewで影と角丸は両立できない
        // 影の設定
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 5)
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 7
        layer.masksToBounds = false
        // 角丸の設定
        roundedView.layer.cornerRadius = 7
    }
    /// セル再利用の準備、ここでデフォルト設定しないと再利用時に意図しない見た目になる
    override func prepareForReuse() {
        super.prepareForReuse()

        // デフォルト設定でリセットする
        annivNameLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        annivDateLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        remainingDaysLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        remainingDaysLabel.backgroundColor = #colorLiteral(red: 1, green: 0.6629999876, blue: 0.07800000161, alpha: 1)
        contentView.alpha = 1.0
        roundedView.backgroundColor = .white
    }
    /// セルによって違う見た目を設定する
    func configure(anniv: Anniv) {
        // 記念日の名前
        annivNameLabel.text = AnnivUtil.getName(from: anniv)
        // 記念日の日程
        annivDateLabel.text = DateTimeFormat.getMonthDayString(date: anniv.date.dateValue())
        // 記念日のアイコン
        annivIconImage.image = AnnivUtil.getIconImage(from: anniv)
        // 記念日までの残り日数
        guard let remainingDaysInt = anniv.remainingDays else { return }
        // 記念日の残り日数文字列
        remainingDaysLabel.text = AnnivUtil.getRemainingDaysString(from: remainingDaysInt)
        // 記念日の残り日数基本のフォント
        remainingDaysLabel.font = UIFont.systemFont(ofSize: UIFont.labelFontSize, weight: .regular)

        switch RemainingDays(remainingDaysInt) {
        case .today:
            roundedView.backgroundColor = #colorLiteral(red: 0.8235294118, green: 0.0862745098, blue: 0.3921568627, alpha: 1)
            annivNameLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            annivDateLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            remainingDaysLabel.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            remainingDaysLabel.textColor = #colorLiteral(red: 0.8235294118, green: 0.0862745098, blue: 0.3921568627, alpha: 1)
            remainingDaysLabel.font = UIFont.boldSystemFont(ofSize: UIFont.labelFontSize)
            
        case .tomorrow:
            annivNameLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            annivDateLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            roundedView.backgroundColor = #colorLiteral(red: 0.9737553, green: 0.6467057467, blue: 0, alpha: 1)
            remainingDaysLabel.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)

        case .near:
            annivNameLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            annivDateLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            roundedView.backgroundColor = #colorLiteral(red: 0.9737553, green: 0.6467057467, blue: 0, alpha: 1)
            remainingDaysLabel.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
            
        case .past:
            contentView.alpha = 0.5
            
        case .yesterday:
            contentView.alpha = anniv.isAnnualy ? 1 : 0.5
            
        case .distant:
            break
        }
    }
}
