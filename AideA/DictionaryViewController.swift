//
//  DictionaryViewController.swift
//  AideA
//
//  Created by AppCircle on 2017/11/13.
//  Copyright © 2017年 NichibiAppCircle. All rights reserved.
//

import UIKit
import RealmSwift

class DictionaryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate
{
    @IBOutlet weak var combinedLabel: UILabel!
    @IBOutlet weak var wordTableView: UITableView!
    @IBOutlet weak var alphabetsCollectionView: UICollectionView!
    
    let operationAlphabets = OperationAlphabets()
    var combinAlphabets: String = ""
    
    var tempMydicItems: Results<MyDictionary>?
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
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.didSwipe(sender:)))
        rightSwipe.direction = .right
        view.addGestureRecognizer(rightSwipe)
        
        let nibWord = UINib(nibName: "WordCell", bundle: nil)
        self.wordTableView.register(nibWord, forCellReuseIdentifier: "wordCell")
        let nibAlphabet = UINib(nibName: "AlphabetCell", bundle: nil)
        self.alphabetsCollectionView.register(nibAlphabet, forCellWithReuseIdentifier: "alphabetCell")
        
        self.wordTableView.backgroundColor = UIColor.clear
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
        
        self.combinedLabel.text = self.combinAlphabets
        self.tempMydicItems = self.mydicItems
    }
    
    @objc func didSwipe(sender: UISwipeGestureRecognizer)
    {
        if (sender.direction == .right)
        {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    /*---------------------------------------------------------
     *英単語検索処理
     ---------------------------------------------------------*/
    func selectFilterRealm(column: String, condition: String) -> Results<MyDictionary>?
    {
        return self.mydicItems?.filter(column + " LIKE '" + condition + "'")
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*---------------------------------------------------------
     *獲得している英単語のテーブルビュー
     ---------------------------------------------------------*/
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        guard let mydic = self.tempMydicItems else
        {
            return 0
        }
        return mydic.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "wordCell", for: indexPath) as! WordCell
        let object = self.tempMydicItems![indexPath.row]
        cell.lblWord.text = object.word
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let object = self.tempMydicItems![indexPath.row]
        print("word: \(object.word)")
        print("meaning: \(object.meaning)")
        self.showWordMeaning(word: object.word, meaning: self.semanticSubdivisionProcess(meaning: object.meaning))
        self.wordTableView.deselectRow(at: indexPath, animated: true)
    }
    
    /*---------------------------------------------------------
     *英単語の意味編集処理
     ---------------------------------------------------------*/
    func semanticSubdivisionProcess(meaning: String) -> String
    {
        if meaning.contains("/")
        {
            let meanings = meaning.components(separatedBy: "/")
            var str = ""
            for mean in meanings
            {
                str += mean + "\n"
            }
            str = str.dropLast().description
//            print(str)
            
            return str
        }
        return meaning
    }
    
    /*---------------------------------------------------------
     *英単語の意味表示アラート
     ---------------------------------------------------------*/
    func showWordMeaning(word: String, meaning: String)
    {
        let alert = UIAlertController(title: word,
                                      message: meaning,
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        let closingAction = UIAlertAction(title: "閉じる",
                                          style: UIAlertActionStyle.cancel,
                                          handler: nil)
        
        alert.addAction(closingAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    /*---------------------------------------------------------
     *アルファベット選択コレクションビュー
     ---------------------------------------------------------*/
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.operationAlphabets.returnWithWildcardAlphabets().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "alphabetCell", for: indexPath) as! AlphabetCell
        
        cell.lblAlphabet.text = self.operationAlphabets.returnWithWildcardAlphabets()[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        self.combinAlphabets += self.operationAlphabets.returnWithWildcardAlphabets()[indexPath.row]
        self.combinedLabel.text = self.combinAlphabets
        self.tempMydicItems = self.selectFilterRealm(column: "word", condition: self.combinAlphabets)
        self.wordTableView.reloadData()
    }
    
    /*---------------------------------------------------------
     *検索文字から一文字削除処理
     ---------------------------------------------------------*/
    @IBAction func clearAction(_ sender: Any)
    {
        if (self.combinAlphabets.count == 0)
        {
            return
        }
        self.combinAlphabets = String(self.combinAlphabets[..<self.combinAlphabets.index(before: self.combinAlphabets.endIndex)])
        self.combinedLabel.text = self.combinAlphabets
        if (self.combinAlphabets.count == 0)
        {
            self.tempMydicItems = self.mydicItems
            self.wordTableView.reloadData()
            return
        }
        self.tempMydicItems = self.selectFilterRealm(column: "word", condition: self.combinAlphabets)
        self.wordTableView.reloadData()
    }
}
