//
//  ViewControllerHelper.swift
//  ReversiTests
//
//  Created by yoshimasa36g on 2020/05/11.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

@testable import Reversi
import UIKit

final class ViewControllerHelper {
    var viewController: ViewController {
        guard let vc = UIApplication.shared.windows.first?.rootViewController as? ViewController else {
            fatalError("Could not get ViewController")
        }
        return vc
    }

    /// 少しゲームを進める advantageに指定したほうが７枚、そうでない方は５枚になる
    func runGame(advantage: Disk) {
        let disadvantage: Disk = advantage == .dark ? .light : .dark
        let vc = viewController
        vc.newGame()
        vc.set(disk: advantage, atX: 2, y: 2)
        vc.set(disk: disadvantage, atX: 5, y: 2)
        vc.set(disk: advantage, atX: 2, y: 3)
        vc.set(disk: advantage, atX: 3, y: 3)
        vc.set(disk: disadvantage, atX: 4, y: 3)
        vc.set(disk: advantage, atX: 5, y: 3)
        vc.set(disk: advantage, atX: 2, y: 4)
        vc.set(disk: disadvantage, atX: 3, y: 4)
        vc.set(disk: advantage, atX: 4, y: 4)
        vc.set(disk: disadvantage, atX: 3, y: 5)
        vc.set(disk: disadvantage, atX: 4, y: 5)
        vc.set(disk: advantage, atX: 5, y: 5)
    }
}
