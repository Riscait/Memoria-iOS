//
//  ContactAccess.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/10/25.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit
import Contacts
import Firebase

final class ContactAccess: EventTrackable {
    
    /// Taptic Engine
    var feedbackGenerator: UINotificationFeedbackGenerator?
    
    // 連絡先を取得するクラスのインスタンス
    let store = CNContactStore.init()
    
    /// 端末の連絡先アクセス許可状態をチェックする
    ///
    /// - Returns: アクセス可能状態ならTrue、それ以外はfalse
    func checkStatusAndImport(rootVC: UIViewController, compltion: (() -> ())? = nil) {
        
        // Instantiate a new feedback-generator
        feedbackGenerator = UINotificationFeedbackGenerator()
        // 連絡帳へのアクセス許可状態を取得する
        let accessStatus = CNContactStore.authorizationStatus(for: .contacts)
        
        switch accessStatus {
        case .notDetermined:  // まだ許可されていないか、機能制限等により利用不可
            Log.info("連絡先へのアクセスは、まだ許可されていないか、機能制限等により利用不可です")
            // 連絡先へのアクセスを許可するかどうかのダイアログボックスを表示
            store.requestAccess(for: .contacts, completionHandler: {(granted, Error) in
                if granted {
                    self.trackEvent(eventName: "Granted access to Contact")
                    Log.info("連絡先へのアクセスが許可されました")
                    DialogBox.showAlertWithIndicator(on: rootVC, message: NSLocalizedString("importingContact", comment: "")) {
                        self.importContact { count in
                            DialogBox.dismissAlertWithIndicator(on: rootVC) {
                                self.importedBirthday(rootVC: rootVC, count: count, compltion: compltion)
                            }
                        }
                    }
                } else {
                    self.trackEvent(eventName: "Denied access to Contact")
                    Log.info("連絡先へのアクセスが拒否されました")
                    /// 設定アプリへの遷移を促すダイアログをポップアップ
                    DialogBox.showAlert(on: rootVC,
                                        hasCancel: true,
                                        title: NSLocalizedString("pleasePermitToContactTitle", comment: ""),
                                        message: NSLocalizedString("pleasePermitToContactMessage", comment: ""),
                                        defaultAction: OpenOtherApp().openSettingsApp)
                }
            })
        case .restricted:  // 連絡先情報を使用できません
            Log.info("このアプリケーションは 連絡先情報を使用できません")
            // TODO: 連絡先を取得できない旨を表示する
            
        case .denied:  // 連絡先へのアクセスが拒否されている
            Log.info("連絡先へのアクセスが拒否されている")
            DialogBox.showAlert(on: rootVC,
                                hasCancel: true,
                                title: NSLocalizedString("pleasePermitToContactTitle", comment: ""),
                                message: NSLocalizedString("pleasePermitToContactMessage", comment: ""),
                                defaultAction: OpenOtherApp().openSettingsApp)
            
        case .authorized:  // 連絡先へのアクセス可能
            Log.info("連絡先へのアクセス可能")
            DialogBox.showAlertWithIndicator(on: rootVC, message: NSLocalizedString("importingContact", comment: "")) {
                self.importContact { count in
                    DialogBox.dismissAlertWithIndicator(on: rootVC) {
                        self.importedBirthday(rootVC: rootVC, count: count, compltion: compltion)
                    }
                }
            }
        @unknown default:
            Log.error("accessStatusで新しいケースが追加されています")
        }
    }
    
    /// 連絡先にアクセスして、連絡先情報を取得する
    func importContact(callback: ((Int) -> ())? = nil) {
        
        // 個々の連絡先のデータを格納する配列
        var contacts = [CNContact]()
        
        do {
            // 誕生日情報を持つ連絡先から「名・姓・誕生日・サムネイル画像」を取得する
            try store.enumerateContacts(with: CNContactFetchRequest(
                keysToFetch: [CNContactIdentifierKey as CNKeyDescriptor,
                              CNContactGivenNameKey as CNKeyDescriptor,
                              CNContactFamilyNameKey as CNKeyDescriptor,
                              CNContactBirthdayKey as CNKeyDescriptor,
                              CNContactThumbnailImageDataKey as CNKeyDescriptor])) {
                                contact, cursor -> Void in
                                // 誕生日が入力されている連絡先だったら追加
                                if contact.birthday?.date != nil {
                                    contacts.append(contact)
                                }
            }
        } catch {
            Log.warn("連絡先データの取得に失敗！")
            // TODO: なんらかのエラーアラートを出す
        }
        
        Log.info("\(contacts.count)件の連絡先情報を確認")
        
        for contact in contacts {
            
            guard let date = contact.birthday?.date else {
                Log.warn("\(contact.familyName) \(contact.givenName)の誕生日がnilだったため処理を終了します")
                return
            }
            let birthday = Anniv(id: contact.identifier,
                                 category: .birthday,
                                 title: nil,
                                 familyName: contact.familyName,
                                 givenName: contact.givenName,
                                 date: Timestamp(date: date),
                                 iconImage: contact.thumbnailImageData,
                                 isHidden: false,
                                 isAnnualy: true,
                                 isFromContact: true,
                                 memo: "",
                                 remainingDays: nil)
            
            // データベースに連絡先の誕生日情報を保存する
            AnnivDAO.set(documentPath: contact.identifier, data: birthday.toDictionary)
        }
        // 取得した連絡先情報の件数をコールバックで返す
        if let callback = callback {
            callback(contacts.count)
        }
    }
    
    // MARK: - Private method
    private func importedBirthday(rootVC: UIViewController, count: Int, compltion: (() -> Void)?) {
        feedbackGenerator?.prepare()
        DialogBox.showAlert(on: rootVC,
                            hasCancel: false,
                            title: String(format: NSLocalizedString("importedBirthdayTitle", comment: ""), count.description),
                            message: NSLocalizedString("importedBirthdayMessage", comment: ""),
                            defaultAction: compltion)
        feedbackGenerator?.notificationOccurred(.success)
    }
}
