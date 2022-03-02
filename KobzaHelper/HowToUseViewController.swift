//
//  HowToUseViewController.swift
//  KobzaHelper
//
//  Created by User on 02.03.2022.
//

import UIKit

class HowToUseViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        textView.isScrollEnabled = true
        textView.isEditable = false
        textView.isSelectable = false
    }
}
