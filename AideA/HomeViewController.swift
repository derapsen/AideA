//
//  HomeViewController.swift
//  AideA
//
//  Created by AppCircle on 2017/11/10.
//  Copyright © 2017年 NichibiAppCircle. All rights reserved.
//

import UIKit
import RealmSwift
import AVFoundation
import QRCodeReader

class MyDictionary: Object
{
    @objc dynamic var word = ""
    @objc dynamic var meaning = ""
}

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, QRCodeReaderViewControllerDelegate
{
    @IBOutlet weak var mywordLabel: UILabel!
    
    @IBOutlet weak var themeMeaningTableView: UITableView!
    @IBOutlet weak var leftThemeLabel: UILabel!
    @IBOutlet weak var centerThemeLabel: UILabel!
    @IBOutlet weak var rightThemeLabel: UILabel!
    
    @IBOutlet weak var alphabetsCollectionView: UICollectionView!
    
    @IBOutlet weak var btnDicitionary: UIButton!
    @IBOutlet weak var btnSignal: UIButton!
    
    var themeItems: Results<ThemeModel>?
    {
        do
        {
            let config = Realm.Configuration(fileURL: Bundle.main.url(forResource: "ThemeDB",withExtension: "realm"),readOnly: true)
            let realm = try Realm(configuration: config)
            return realm.objects(ThemeModel.self)
        }
        catch
        {
            print("ThemeDB.realm file not found")
        }
        return nil
    }
    
    var dicItems: Results<DictionaryModel>?
    {
        do
        {
            let config = Realm.Configuration(fileURL: Bundle.main.url(forResource: "DictionaryDB",withExtension: "realm"),readOnly: true)
            let realm = try Realm(configuration: config)
            return realm.objects(DictionaryModel.self)
        }
        catch
        {
            print("ThemeDB.realm file not found")
        }
        return nil
    }
    
    var mydicItems: Results<MyDictionary>?
    {
        do
        {
            let realm = try Realm()
            return realm.objects(MyDictionary.self)
        }
        catch
        {
            print("MyDictionary not found")
        }
        return nil
    }
    
    // ユーザーデータ格納変数
    var combiedAlphabets = ""
    var meWord = ""
    var todaysTheme = ""
    var todaysMeans: [String] = []
    
    // QRコード表示用変数
     var flgHide: Bool!
    var vwBackground: UIView!
    var lblMessage: UILabel!
    var imgQR: UIImageView!
    var btnClose: UIButton!
    
    // QRコードリーダーインスタンス変数
    lazy var reader = QRCodeReaderViewController(builder: QRCodeReaderViewControllerBuilder {
        $0.reader          = QRCodeReader(metadataObjectTypes: [AVMetadataObject.ObjectType.qr])
        $0.showTorchButton = true
    })
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let nibWord = UINib(nibName: "WordCell", bundle: nil)
        self.themeMeaningTableView.register(nibWord, forCellReuseIdentifier: "meaningCell")
        let nibAlphabet = UINib(nibName: "AlphabetCell", bundle: nil)
        self.alphabetsCollectionView.register(nibAlphabet, forCellWithReuseIdentifier: "alphabetCell")
        
        self.themeMeaningTableView.backgroundColor = UIColor.clear
        self.alphabetsCollectionView.backgroundColor = UIColor.clear
        
        let cellWidth: CGFloat = 50.0
        let cellHeight: CGFloat = 70.0
        
        let widthSpace = (self.alphabetsCollectionView.frame.width - cellWidth) / 2
        let heightSpace = (self.alphabetsCollectionView.frame.height - cellHeight) / 2
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: heightSpace, left: widthSpace, bottom: heightSpace, right: widthSpace)
        layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.scrollDirection = .horizontal
        self.alphabetsCollectionView.collectionViewLayout = layout
        
        self.btnDicitionary.layer.cornerRadius = 10
        self.btnDicitionary.clipsToBounds = true
        self.btnSignal.layer.cornerRadius = 10
        self.btnSignal.clipsToBounds = true
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        // 本日初回のログインなら今日のMyWordを表示
        if (self.checkLogin())
        {
            self.decideTodaysAlphabet()
            self.loadTheme()
            self.setData()
        }
        else
        {
            self.loadTheme()
            self.setData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(true)
        
        if (self.flgHide == false)
        {
            self.flgHide = true
            self.vwBackground.isHidden = true
        }
    }
    
    /*---------------------------------------------------------
     *今日のアルファベット処理
     ---------------------------------------------------------*/
    func decideTodaysAlphabet()
    {
        let operationAlphabets = OperationAlphabets()
        self.meWord = operationAlphabets.selectAlphabetAtRandom()
        if (operationAlphabets.notFoundAlphabet(word: self.meWord))
        {
            print("add myWord in carryAlphabets")
            operationAlphabets.carryingAlphabets.append(self.meWord)
            operationAlphabets.carryingAlphabets.sort()
            UserSettings.carryLists.setData(value: operationAlphabets.carryingAlphabets)
            print(operationAlphabets.carryingAlphabets)
            self.alphabetsCollectionView.reloadData()
        }
        
        UserSettings.myword.set(value: self.meWord)
        
        self.showAlertSimple(title: "今日のあなたのMyWordは、『" + self.meWord + "』です!",
                             message: "MyWordを所持しているアルファベットリストに追加します。\n※ 所持しているアルファベットと重複した場合追加されません。")
        
    }
    
    /*---------------------------------------------------------
     *シンプルアラート表示処理
     ---------------------------------------------------------*/
    func showAlertSimple(title: String, message: String)
    {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        
        let closingAction = UIAlertAction(title: "閉じる",
                                          style: .cancel,
                                          handler: nil)
        
        alert.addAction(closingAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    /*---------------------------------------------------------
     *QR読み取り後のアルファベット処理
     ---------------------------------------------------------*/
    func decideTodaysAlphabet(partner: String, partnerMyword: String)
    {
        let operationAlphabets = OperationAlphabets()
        if (operationAlphabets.notFoundAlphabet(word: partnerMyword))
        {
            print("add partnerMyword in carryAlphabets")
            operationAlphabets.carryingAlphabets.append(partnerMyword)
            operationAlphabets.carryingAlphabets.sort()
            UserSettings.carryLists.setData(value: operationAlphabets.carryingAlphabets)
            print(operationAlphabets.carryingAlphabets)
            self.alphabetsCollectionView.reloadData()
            
            self.showAlertSimple(title: "\(partner)からアルファベットを獲得しました!",
                                 message: "\(partner)のMyWordを所持しているアルファベットリストに追加します。")
        }
        else
        {
            print("The acquired partnerMyword is a duplicate in carryAlphabets")
            self.showAlertSimple(title: "アルファベットを獲得できませんでした。",
                                 message: "所持しているアルファベットと重複した場合、追加されません。")
        }
    }
    
    /*---------------------------------------------------------
     *テーマと意味の読み込み処理
     ---------------------------------------------------------*/
    func loadTheme()
    {
        let calendar = Calendar(identifier: .gregorian)
        let startdate = calendar.date(from: DateComponents(year: 2017, month: 6, day: 25))
        let now = Date()
        let date = calendar.dateComponents([.day], from: startdate!, to: now).day
        
        if let object = self.themeItems?[date!]
        {
            self.todaysTheme = object.word
            self.todaysMeans = object.meaning.components(separatedBy: "/")
            self.themeMeaningTableView.reloadData()
            
            print("本日のテーマ： " + self.todaysTheme)
            for i in 0..<self.todaysMeans.count
            {
                print("本日の意味 " + i.description + "： " + self.todaysMeans[i])
            }
            
            UserSettings.theme.set(value: self.todaysTheme)
        }
    }
    
    /*---------------------------------------------------------
     *データ表示処理
     ---------------------------------------------------------*/
    func setData()
    {
        // myWordをラベルに表示
        guard let myword = UserSettings.myword.object() as? String else
        {
            print("Could not convert string : myWord")
            self.mywordLabel.text = ""
            return
        }
        self.mywordLabel.text = myword
        // 本日の英単語をラベルに表示
        guard let theme = UserSettings.theme.object() as? String else
        {
            print("Could not convert string : theme")
            self.leftThemeLabel.text = ""
            self.centerThemeLabel.text = ""
            self.rightThemeLabel.text = ""
            return
        }
        self.leftThemeLabel.text = theme.first?.description
        let substr = theme[theme.index(theme.startIndex, offsetBy: 1)..<theme.index(theme.endIndex, offsetBy: -1)]
        self.centerThemeLabel.alpha = 0.7
        self.centerThemeLabel.text = String(substr)
        self.rightThemeLabel.text = theme.last?.description
    }
    
    /*---------------------------------------------------------
     *今日初めてのログインチェック処理
     ---------------------------------------------------------*/
    func checkLogin() -> Bool
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        let nowDay = formatter.string(from: Date())
        
        guard let loginDay = UserSettings.login.object() as? String else
        {
            // My辞書Realm初期化
            let newMydic = MyDictionary()
            let realm = try! Realm()
            try! realm.write {
                realm.delete(newMydic)
            }
            
            print("initialize login")
            UserSettings.login.set(value: nowDay)
            
            self.showNameEntry()
            return true
        }
        
        let nowYMD = nowDay.components(separatedBy: "/")
        let loginYMD = loginDay.components(separatedBy: "/")
        print(nowYMD)
        print(loginYMD)
        for i in 0..<3
        {
            guard let now = Int(nowYMD[i]) else
            {
                print("Could not convert string to number")
                return false
            }
            guard let login = Int(loginYMD[i]) else
            {
                print("Could not convert string to number")
                return false
            }
            if (now > login)
            {
                print("first login today")
                UserSettings.login.set(value: nowDay)
                return true
            }
        }
        print("already login today")
        UserSettings.login.set(value: nowDay)
        return false
    }
    
    /*---------------------------------------------------------
     *ユーザー名入力アラート生成処理
     ---------------------------------------------------------*/
    func showNameEntry()
    {
        let alertNameEntry = UIAlertController(title: "ユーザー名の入力",
                                               message: "ユーザー名を入力してください。",
                                               preferredStyle: .alert)
        let actionOk = UIAlertAction(title: "OK",
                                     style: .default,
                                     handler:
            {
                (UIAlertAction) in
                
                guard let textFields = alertNameEntry.textFields else
                {
                    print("Text field not found in alertNameEntry")
                    return
                }
//                print(textFields)
                for textField in textFields
                {
                    
                    guard let name = textField.text else
                    {
                        print("text not found")
                        return
                    }
//                    print(name)
                    if(name == "")
                    {
                        print("Name is not entered")
                        self.showErrorNameEntry()
                        return
                    }
                    UserSettings.name.set(value: name)
                }
            }
        )
        
        alertNameEntry.addAction(actionOk)
        
        alertNameEntry.addTextField { (text:UITextField) in
            text.placeholder = "ユーザー名"
        }
        self.present(alertNameEntry, animated: true, completion: nil)
    }
    
    /*---------------------------------------------------------
     *ユーザー名空入力エラーアラート生成処理
     ---------------------------------------------------------*/
    func showErrorNameEntry()
    {
        let alertError = UIAlertController(title: "入力エラー",
                                           message: "入力していない部分があります。",
                                           preferredStyle: .alert)
        let actionOk = UIAlertAction(title: "OK",
                                     style: .default,
                                     handler:
            {
                (UIAlertAction) in
                self.showNameEntry()
            }
        )
        alertError.addAction(actionOk)
        self.present(alertError, animated: true, completion: nil)
    }
    
    /*---------------------------------------------------------
     *MyWordのQRコードビューの生成処理
     ---------------------------------------------------------*/
    func initQRView()
    {
        // 背景を生成.
        self.vwBackground = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        self.vwBackground.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.75)
        
        // vwBackgroundを非表示.
        self.flgHide = false
        self.vwBackground.isHidden = false
        
        // メッセージを生成
        self.lblMessage = UILabel(frame: CGRect(x: 0, y: 0, width: self.vwBackground.frame.width, height: 50))
        self.lblMessage.center.x = self.vwBackground.center.x
        self.lblMessage.center.y = 70
        self.lblMessage.backgroundColor = UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 0.75)
        self.lblMessage.font = UIFont(name: "Makinas", size: 20)
        self.lblMessage.textAlignment = .center
        self.lblMessage.textColor = UIColor.white
        self.lblMessage.text = "あなたのMyWordのQRコードです。"
        
        // QRを生成
        self.imgQR = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.height/2, height: self.view.frame.height/2))
        self.imgQR.layer.position = CGPoint(x: self.vwBackground.frame.width/2, y: (self.vwBackground.frame.height/2)-40)
        guard let myword = UserSettings.myword.object() as? String else
        {
            print("Could not convert string : myWord")
            return
        }
        guard let name = UserSettings.name.object() as? String else
        {
            print("Could not convert string : name")
            return
        }
        let userData = "AideA:" + name + ":" + myword
        self.imgQR.image = QRCode.generateQRCode(userData)
        
        // ボタンを生成.
        self.btnClose = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        self.btnClose.backgroundColor = UIColor.red
        self.btnClose.layer.cornerRadius = 20.0
        self.btnClose.layer.position = CGPoint(x: self.vwBackground.frame.width/2, y: self.vwBackground.frame.height-50-60)
        self.btnClose.setTitle("閉じる", for: .normal)
        self.btnClose.setTitleColor(UIColor.white, for: .normal)
        self.btnClose.titleLabel?.font = UIFont(name: "Makinas", size: 20)
        self.btnClose.addTarget(self, action: #selector(onClickCloseButton(sender:)), for: .touchUpInside)
        
        // vwBackgroundをviewに追加.
        self.view.addSubview(self.vwBackground)
        
        // メッセージをviewに追加.
        self.vwBackground.addSubview(self.lblMessage)
        // QRをviewに追加.
        self.vwBackground.addSubview(self.imgQR)
        // ボタンをviewに追加.
        self.vwBackground.addSubview(self.btnClose)
    }
    
    @objc func onClickCloseButton(sender: UIButton)
    {
        // flagがtrueならvwBackgroundを表示.
        if (self.flgHide)
        {
            // 背景を表示.
            self.vwBackground.isHidden = false
            
            self.flgHide = false
        }
        else
        {
            // 背景を非表示.
            self.vwBackground.isHidden = true
            
            self.flgHide = true
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*---------------------------------------------------------
     *今日の英単語のテーブルビュー
     ---------------------------------------------------------*/
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.todaysMeans.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "meaningCell", for: indexPath) as! WordCell
//        print(self.todaysMeans[indexPath.row])
        cell.lblWord.text = self.todaysMeans[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        guard let theme = UserSettings.theme.object() as? String else
        {
            print("Could not convert string : theme")
            return
        }
        self.showAlertSimple(title: "\(theme)\n意味\(indexPath.row + 1)",
                             message: "\(self.todaysMeans[indexPath.row])")
    }

    /*---------------------------------------------------------
     *所持しているアルファベットのコレクションビュー
     ---------------------------------------------------------*/
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        let operationAlphabets = OperationAlphabets()
//        print(operationAlphabets.carryingAlphabets)
        return operationAlphabets.carryingAlphabets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "alphabetCell", for: indexPath) as! AlphabetCell
        
        let operationAlphabets = OperationAlphabets()
        cell.lblAlphabet.text = operationAlphabets.carryingAlphabets[indexPath.row]
//        print(self.combiedAlphabets)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let operationAlphabets = OperationAlphabets()
        self.combiedAlphabets += operationAlphabets.carryingAlphabets[indexPath.row]
        self.centerThemeLabel.alpha = 1.0
        self.centerThemeLabel.text = self.combiedAlphabets
        
        // 単語一致確認処理
        guard let theme = UserSettings.theme.object() as? String else
        {
            print("Could not convert string : theme")
            return
        }
        let searchWord = (theme.first?.description)! + self.combiedAlphabets + (theme.last?.description)!
        self.searchFromDictionary(search: searchWord)
    }
    
    /*---------------------------------------------------------
     *辞書から一致する単語を検索する処理
     ---------------------------------------------------------*/
    func searchFromDictionary(search: String)
    {
        guard let resultsDic = self.dicItems?.filter("word = '\(search)'").first else
        {
            print("search results not found")
            return
        }
        print("search results : \(resultsDic) item found")
        print("\(resultsDic.word)\n\(resultsDic.meaning)")
        
        if self.mydicItems?.filter("word = '\(resultsDic.word)'").count == 0
        {
            print("Word added to MyDictionary")
            let newMydic = MyDictionary()
            newMydic.word = resultsDic.word
            newMydic.meaning = resultsDic.meaning
            
            let realm = try! Realm()
            try! realm.write {
                realm.add(newMydic)
            }
            
            self.showAlertSimple(title: "新しい英単語を発見しました!\n\(resultsDic.word)",
                                 message: "\(resultsDic.meaning)\n\n英単語はMY辞書に登録されます。これまでに発見した英単語の一覧はDictionaryボタンで確認できます。")
            // 本日の英単語をラベルに表示
            guard let theme = UserSettings.theme.object() as? String else
            {
                print("Could not convert string : theme")
                return
            }
            let substr = theme[theme.index(theme.startIndex, offsetBy: 1)..<theme.index(theme.endIndex, offsetBy: -1)]
            self.centerThemeLabel.alpha = 0.7
            self.centerThemeLabel.text = String(substr)
        }
        else
        {
            print("A word has already been added to the MyDictionary")
        }
    }
    
    /*---------------------------------------------------------
     *入力を一文字消す処理
     ---------------------------------------------------------*/
    @IBAction func clearAction(_ sender: Any)
    {
        if (self.combiedAlphabets.count == 0)
        {
            return
        }
        
        self.combiedAlphabets = String(self.combiedAlphabets[self.combiedAlphabets.startIndex..<self.combiedAlphabets.index(before:self.combiedAlphabets.endIndex)])
        self.centerThemeLabel.text = self.combiedAlphabets
        
        if (self.combiedAlphabets.count == 0)
        {
            // 本日の英単語をラベルに表示
            guard let theme = UserSettings.theme.object() as? String else
            {
                print("Could not convert string : theme")
                return
            }
            let substr = theme[theme.index(theme.startIndex, offsetBy: 1)..<theme.index(theme.endIndex, offsetBy: -1)]
            self.centerThemeLabel.alpha = 0.7
            self.centerThemeLabel.text = String(substr)
        }
    }
    
    /*---------------------------------------------------------
     *QRモード選択表示処理
     ---------------------------------------------------------*/
    @IBAction func selectQRModeAction(_ sender: Any)
    {
        let alert = UIAlertController(title: "QRモード選択",
                                      message: "MyWordのQRコードを表示するか、読み取るかを選択してください。",
                                      preferredStyle: .actionSheet)
        let showAction = UIAlertAction(title: "MyWordの表示",
                                       style: .default)
        { (UIAlertAction) in
            
            self.initQRView()
        }
        let readAction = UIAlertAction(title: "MyWordの読み取り",
                                       style: .default)
        { (UIAlertAction) in
            do
            {
                if try QRCodeReader.supportsMetadataObjectTypes()
                {
                    self.reader.modalPresentationStyle = .formSheet
                    self.reader.delegate               = self
                    
                    self.reader.completionBlock = {
                        (result: QRCodeReaderResult?) in
                        if let result = result
                        {
                            // 読み取ってキャプチャ画面が閉じる前に走る処理
                            print("Completion with result: \(result.value) of type \(result.metadataType)")
                        }
                    }
                    
                    self.present(self.reader, animated: true, completion: nil)
                }
            }
            catch let error as NSError
            {
                //エラー処理
            }
        }
        let closingAction = UIAlertAction(title: "閉じる",
                                          style: .cancel,
                                          handler: nil)
        
        alert.addAction(showAction)
        alert.addAction(readAction)
        alert.addAction(closingAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    /*---------------------------------------------------------
     *QRモード読み取り後処理
     ---------------------------------------------------------*/
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult)
    {
        reader.stopScanning()
        
        dismiss(animated: true)
        { [weak self] in
            //キャプチャ画面を閉じた後に走る処理
            //result.valueで取得
            print("result value: \(result.value)")
            
            if result.value.contains("AideA")
            {
                print("AideA QRcode found")
                let data = result.value.components(separatedBy: ":")
                
                self?.decideTodaysAlphabet(partner: data[1], partnerMyword: data[2])
            }
            else
            {
                print("AideA QRcode not found")
                self?.showAlertSimple(title: "MyWord読み取りエラー",
                                      message: "AideAアプリ内のMyWord表示画面で表示されているQRコードを読み込んでください。")
            }
        }
    }
    
    func reader(_ reader: QRCodeReaderViewController, didSwitchCamera newCaptureDevice: AVCaptureDeviceInput)
    {
        let cameraName = newCaptureDevice.device.localizedName
        print("Switching capturing to: \(cameraName)")
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController)
    {
        reader.stopScanning()
        
        dismiss(animated: true, completion: nil)
    }
}

