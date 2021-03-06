//
//  AnnivDAO.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/10/26.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit
import Firebase

/// データベースへのアクセスを担うクラス
class AnnivDAO {
    
    // MARK: - プロパティ
    
    /// FirestoreDB
    private static var db = Firestore.firestore()
    /// Firebase Auth - User ID
    private static let uid = Auth.auth().currentUser?.uid
    // Unique collection
    private static let usersCollection = db.collection("users")
    static let annivCollection = usersCollection.document(uid!).collection("anniversary")


    // MARK: - データ取得
    
    /// Firestoreから記念日データを全件取得する
    ///
    /// - Parameter:
    ///   - id: 記念日ID
    ///   - callback: ドキュメントのデータを受け取る
    static func getAll(callback: @escaping ([Anniv]) -> Void) {
        annivCollection.getDocuments { (querySnapshot, error) in
            if let error = error {
                Log.warn(error.localizedDescription)
            }

            var anniversarysArray = [[String: Any]]()
            
            querySnapshot?.documents.forEach { anniversarysArray.append($0.data()) }
            let anniversaryData = anniversarysArray.map { Anniv(dictionary: $0)}
            
            callback(anniversaryData as! [Anniv])
        }
//        { (document, error) in
//            if let error = error {
//                print("エラー発生: \(error)")
//            } else {
//                print("\(#function)の実行に成功しました！")
//            }
//            // ドキュメントのアンラップと存在チェック
//            if let document = document, document.exists {
//                callback(document.data()!)
//            }
//        }
    }
    
    /// Firestoreから記念日データを1件取得する
    ///
    /// - Parameter:
    ///   - id: 記念日ID
    ///   - callback: ドキュメントのデータを受け取る
    static func get(by id: String, callback: @escaping ([String: Any]) -> Void) {
        annivCollection.document(id).getDocument { (document, error) in
            if let error = error {
                Log.warn(error.localizedDescription)
            }
            // ドキュメントのアンラップと存在チェック
            if let document = document, document.exists {
                callback(document.data()!)
            }
        }
    }

    /// Anniversaryドキュメントの検索結果Queryを取得する
    ///
    /// - Parameters:
    ///   - whereField: 検索対象
    ///   - equalTo: 検索条件
    /// - Returns: 検索結果
    static func getQuery(whereField: String, equalTo: Any) -> Query? {
        return annivCollection.whereField(whereField, isEqualTo: equalTo)
    }
    
    /// getAnniversaryQuery()の検索結果ドキュメントを取得する
    ///
    /// - Parameter:
    ///   - whereField: 検索対象
    ///   - equalTo: 検索条件
    ///   - callback: ドキュメントのデータを受け取る
    static func getFilteredDocuments(whereField: String,
                             equalTo: Any,
                             callback: @escaping ([QueryDocumentSnapshot]) -> Void) {
        getQuery(whereField: whereField, equalTo: equalTo)?.getDocuments { (querySnapshot, error) in
            if let error = error {
                Log.warn(error.localizedDescription)
            }
            // ドキュメントのアンラップと存在チェック
            if let documents = querySnapshot?.documents {
                callback(documents)
            }
        }
    }

    static func getDocumentsAtDualFilter(first whereField: String, equalTo: Any,
                             secondWhereField: String, secondEqualTo: Any,
                             callback: @escaping ([QueryDocumentSnapshot]) -> Void) {
        getQuery(whereField: whereField, equalTo: equalTo)?.whereField(secondWhereField, isEqualTo: secondEqualTo).getDocuments { (querySnapshot, error) in
            if let error = error {
                Log.warn(error.localizedDescription)
            }
            // ドキュメントのアンラップと存在チェック
            if let documents = querySnapshot?.documents {
                callback(documents)
            }
        }
    }

    // MARK: - データ登録・更新
    
    /// Firestoreへのデータ登録・更新
    ///
    /// - Parameters:
    ///   - documentPath: 一意のID
    ///   - data: 登録するデータ
    ///   - marge: 既存のドキュメントにデータを統合するか否か
    static func set(documentPath: String,
                    data: Anniv,
                    merge: Bool = true) {
        annivCollection.document(documentPath).setData(data.toDictionary, merge: merge) { error in
            if let error = error {
                Log.warn(error.localizedDescription)
            }
        }
    }
    
    /// Firestoreへのデータ登録・更新
    ///
    /// - Parameters:
    ///   - documentPath: 一意のID
    ///   - data: 登録するデータ
    ///   - marge: falseなら既存のフィールドは削除され、新しくsetしたフィールドのみとなる
    static func set(documentPath: String,
                    data: [String: Any],
                    merge: Bool = true) {
        annivCollection.document(documentPath).setData(data, merge: merge) { error in
            if let error = error {
                Log.warn(error.localizedDescription)
            }
        }
    }
    

    // MARK: - データ更新

    /// 登録済みのデータを更新する
    ///
    /// - Parameters:
    ///   - documentPath: 一意のID
    ///   - field: 更新データ名
    ///   - content: 更新データ内容
    static func update(with id: String, field: String, content: Any) {
        annivCollection.document(id).updateData([field: content]) { error in
            if let error = error {
                Log.warn(error.localizedDescription)
            }
        }
    }
    
    /// ドキュメントを検索して、更新する
    ///
    /// - Parameters:
    ///   - searchField: 検索対象フィールド
    ///   - isEqualTo: 検索条件
    ///   - updateField: 更新対象フィールド
    ///   - turns content: 更新データ
    static func update(searchField: String,
                       isEqualTo: Any,
                       updateField: String,
                       turns content: Any,
                       callback: (() -> Void)?) {
        annivCollection.whereField(searchField, isEqualTo: true).getDocuments { (query, error) in
            if let error = error {
                Log.warn(error.localizedDescription)
            }
            query?.documents.forEach { $0.reference.updateData([updateField : content]) }
            if let callback = callback {
                callback()
            }
        }
    }

    /// 2つの検索条件でドキュメントを検索して、更新する
    ///
    /// - Parameters:
    ///   - searchField: 検索対象フィールド
    ///   - isEqualTo: 検索条件
    ///   - updateField: 更新対象フィールド
    ///   - turns content: 更新データ
    static func update(searchField: String,
                       isEqualTo: Any,
                       secondSearchField: String,
                       secondIsEqualTo: Any,
                       updateField: String,
                       turns content: Any,
                       callback: (() -> Void)?) {
        annivCollection.whereField(searchField, isEqualTo: true)
            .whereField(secondSearchField, isEqualTo: secondIsEqualTo).getDocuments { (query, error) in
            if let error = error {
                Log.warn(error.localizedDescription)
                }
            query?.documents.forEach { $0.reference.updateData([updateField : content]) }
            if let callback = callback {
                callback()
            }
        }
    }


    // MARK: - データ削除
    
    /// 検索して該当したAnniversaryドキュメントを削除する
    ///
    /// - Parameters:
    ///   - whereField: 検索対象
    ///   - equalTo: 検索条件
    static func delete(with id: String) {
        annivCollection.document(id).delete() { error in
            if let error = error {
                Log.warn(error.localizedDescription)
            }
        }
    }

    /// 検索して該当したAnniversaryドキュメントを削除する
    ///
    /// - Parameters:
    ///   - whereField: 検索対象
    ///   - equalTo: 検索条件
    static func deleteByQuery(with whereField: String, isEqualTo: Any,
                                on roorVC: UIViewController, compltion: (() -> Void)? = nil) {
        annivCollection.whereField(whereField, isEqualTo: isEqualTo).getDocuments { (querySnapshot, error) in
            // Instantiate a new feedback-generator
            let feedbackGenerator = UINotificationFeedbackGenerator()
            feedbackGenerator.prepare()
            
            if let error = error {
                Log.warn(error.localizedDescription)
                DialogBox.showAlert(on: roorVC, message: NSLocalizedString("deleteAnniversaryFilure", comment: ""))
                feedbackGenerator.notificationOccurred(.error)
                
            } else if let documents = querySnapshot?.documents,
                !documents.isEmpty {
                documents.forEach { $0.reference.delete() }
                DialogBox.showAlert(on: roorVC, message: NSLocalizedString("deleteAnniversarySuccess", comment: ""))
                feedbackGenerator.notificationOccurred(.success)
                
            } else {
                Log.info("documentsが空")
                DialogBox.showAlert(on: roorVC, message: NSLocalizedString("deleteAnniversaryEmpty", comment: ""))
                feedbackGenerator.notificationOccurred(.warning)
            }
        }
    }
}
