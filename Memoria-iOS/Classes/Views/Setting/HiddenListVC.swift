
//
//  HiddenListVC.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/11/24.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit
import Firebase

class HiddenListVC: UITableViewController, EventTrackable {

    @IBOutlet var hiddenTableView: UITableView!
    
    var selectedRow: Int!
    /// リスナー登録
    var listenerRegistration: ListenerRegistration?
    
    var annivs: [[String: Any]]?
    
    
    // MARK: - ライフサイクル
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Title of this screen
        title = "hiddenList".localized
    }
    
    /// Viewが表示される直前に呼ばれる（タブ切り替え等も含む）
    override func viewWillAppear(_ animated: Bool) {
        trackScreen()
        
        // anniversaryコレクションの変更を監視する
        listenerRegistration = AnnivDAO.getQuery(whereField: "isHidden", equalTo: true)?
            .addSnapshotListener { documentSnapshot, error in
                if let error = error {
                    Log.warn(error.localizedDescription)
                    return
                }
                guard let documentSnapshot = documentSnapshot else { return }
                self.annivs = [[String: Any]]()
                // 記念日データが入ったドキュメントの数だけ繰り返す
                for doc in documentSnapshot.documents {
                    // ドキュメントから記念日データを取り出す
                    let data = doc.data()
                    // 記念日データをローカル配列に記憶
                    self.annivs?.append(data)
                }
                self.tableView.reloadData()
        }
        super.viewWillAppear(animated)
    }
    
    /// Viewが非表示になる直前に呼ばれる
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // リスナー登録を破棄する
        if let listenerRegistration = listenerRegistration {
            listenerRegistration.remove()
        }
    }

    /// セルの編集ボタンが押された
    @IBAction func didTapEditButton(_ sender: InspectableButton) {
        guard let indexPath = hiddenTableView.indexPath(for: sender.superview!.superview as! UITableViewCell) else { return }
        
        let defaultActionSet = ["redisplay".localized: redisplayThisAnniv]
        let destructiveActionSet = ["delete".localized: deleteThisAnniv]
        // 選択されたセルの行番号
        selectedRow = indexPath.row
        // ActionSheetを表示
        DialogBox.showActionSheet(rootVC: self, title: nil, message: nil,
                                  defaultActionSet: defaultActionSet,
                                  destructiveActionSet: destructiveActionSet)
    }
    
    /// 選択したセルの記念日を削除する
    func deleteThisAnniv() {
        let documentPath = annivs?[selectedRow]["id"] as! String
        AnnivDAO.delete(with: documentPath)
    }
    /// 選択したセルの記念日を再表示する
    func redisplayThisAnniv() {
        let documentPath = annivs?[selectedRow]["id"] as! String
        AnnivDAO.update(with: documentPath, field: "isHidden", content: false)
    }

    
    // MARK: - Table view data source

    /// セクション数
    override func numberOfSections(in tableView: UITableView) -> Int { return 1 }

    /// 行数
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return annivs?.count ?? 0
    }

    /// セルの内容
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "hiddenAnniversaryCell", for: indexPath)

        let iconImageView = cell.viewWithTag(1) as! UIImageView
        let titleLabel = cell.viewWithTag(2) as! UILabel

        guard let anniversary = annivs?[indexPath.row],
            let anniv = Anniv(dictionary: anniversary) else { return cell }
        
        switch anniv.category {
        case .anniv:
            titleLabel.text = anniv.title

        case .birthday:
            titleLabel.text = String(format: "whoseBirthday".localized,
                                     arguments: [anniv.familyName ?? "",
                                                 anniv.givenName ?? ""])
        }
        iconImageView.image = AnnivUtil.getIconImage(from: anniv)

        return cell
    }
    
    /// セクションごとのヘッダータイトル
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "titleForHeaderInSection".localized

        default:
            return nil
        }
    }
}
