import ReversiEntity // TODO: 後で外す
import ReversiInterfaceAdapter
import UIKit

class ViewController: UIViewController {
    @IBOutlet private var boardView: BoardView!

    @IBOutlet private var messageDiskView: DiskView!
    @IBOutlet private var messageLabel: UILabel!
    @IBOutlet private var messageDiskSizeConstraint: NSLayoutConstraint!
    /// Storyboard 上で設定されたサイズを保管します。
    /// 引き分けの際は `messageDiskView` の表示が必要ないため、
    /// `messageDiskSizeConstraint.constant` を `0` に設定します。
    /// その後、新しいゲームが開始されたときに `messageDiskSize` を
    /// 元のサイズで表示する必要があり、
    /// その際に `messageDiskSize` に保管された値を使います。
    private var messageDiskSize: CGFloat = 0

    @IBOutlet private var playerControls: [UISegmentedControl]!
    @IBOutlet private var countLabels: [UILabel]!
    @IBOutlet private var playerActivityIndicators: [UIActivityIndicatorView]!

    private var animationCanceller: Canceller?
    private var isAnimating: Bool { animationCanceller != nil }

    // 画面のコントローラ
    private var controller: GameScreenControllable?

    private var game = Game()

    override func viewDidLoad() {
        super.viewDidLoad()

        boardView.delegate = self
        messageDiskSize = messageDiskSizeConstraint.constant

        controller = GameDependencyFactory.createGameScreenController(for: self)
        controller?.start()
    }
}

// MARK: - GameScreenPresentable

extension ViewController: GameScreenPresentable {
    func redrawEntireGame(state: PresentableGameState) {
        animationCanceller?.cancel()
        animationCanceller = nil

        playerControls.first?.selectedSegmentIndex = state.players.dark
        playerControls.last?.selectedSegmentIndex = state.players.light
        boardView.reset()
        state.discs.forEach { disc in
            boardView.setDisk(Disk.from(index: disc.color), atX: disc.x, y: disc.y, animated: false)
        }

        // TODO: リファクタリング中の動作確認用。後で必ず消すこと
        var disc: Disc?
        if let turn = state.turn {
            disc = Disc(color: DiscColor(rawValue: turn) ?? .dark)
        }
        game = Game(
            turn: disc,
            players: Players(darkPlayer: PlayerType(rawValue: state.players.dark)?.toPlayer() ?? Human(),
                             lightPlayer: PlayerType(rawValue: state.players.dark)?.toPlayer() ?? Human()),
            board: GameBoard(cells: Set(state.discs.map { disc in
                BoardCell(
                    coordinate: Coordinate(x: disc.x, y: disc.y),
                    disc: Disc(color: DiscColor(rawValue: disc.color) ?? .dark))
            })))
    }

    func redrawMessage(color: Int?, label: String) {
        messageLabel.text = label
        guard let color = color else {
            messageDiskSizeConstraint.constant = 0
            return
        }

        messageDiskView.disk = Disk.from(index: color)
        messageDiskSizeConstraint.constant = messageDiskSize
    }

    func redrawDiscCount(dark: Int, light: Int) {
        countLabels.first?.text = dark.description
        countLabels.last?.text = light.description
    }

    func changeDiscs(to color: Int, at coordinates: [(x: Int, y: Int)]) {
        place(Disk.from(index: color), at: coordinates)
    }

    func showPassedMessage() {
        let alertController = UIAlertController(
            title: "Pass",
            message: "Cannot place a disk.",
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default) { [weak self] _ in
            self?.controller?.acceptPass()
        })
        present(alertController, animated: true)
    }

    func showIndicator(for color: Int) {
        showIndicator(of: Disk.from(index: color))
    }

    func hideIndicator(for color: Int) {
        hideIndicator(of: Disk.from(index: color))
    }
}

// MARK: flip animation

extension ViewController {
    /// `coordinates` で指定されたセルにアニメーションありで `disk` を置く
    /// - Parameters:
    ///   - disk: 置くディスク
    ///   - coordinates: ディスクを置く位置の一覧
    func place(_ disk: Disk, at coordinates: [(x: Int, y: Int)]) {
        if coordinates.isEmpty { return }

        let cleanUp: () -> Void = { [weak self] in
            self?.animationCanceller = nil
        }
        animationCanceller = Canceller(cleanUp)
        animateSettingDisks(at: coordinates, to: disk) { [weak self] _ in
            guard let self = self else { return }
            guard let canceller = self.animationCanceller else { return }
            if canceller.isCancelled { return }
            cleanUp()

            self.controller?.changeDiscsCompleted(color: disk.index, at: coordinates)
        }
    }

    /// `coordinates` で指定されたセルに、アニメーションしながら順番に `disk` を置く。
    /// `coordinates` から先頭の座標を取得してそのセルに `disk` を置き、
    /// 残りの座標についてこのメソッドを再帰呼び出しすることで処理が行われる。
    /// すべてのセルに `disk` が置けたら `completion` ハンドラーが呼び出される。
    private func animateSettingDisks<C: Collection>(
        at coordinates: C,
        to disk: Disk,
        completion: @escaping (Bool) -> Void
    ) where C.Element == (x: Int, y: Int) {
        guard let coordinate = coordinates.first else {
            completion(true)
            return
        }

        guard let animationCanceller = self.animationCanceller else {
            return
        }
        boardView.setDisk(disk, atX: coordinate.x, y: coordinate.y, animated: true) { [weak self] isFinished in
            guard let self = self else { return }
            if animationCanceller.isCancelled { return }
            if isFinished {
                self.animateSettingDisks(at: coordinates.dropFirst(), to: disk, completion: completion)
            } else {
                for coordinate in coordinates {
                    self.boardView.setDisk(disk, atX: coordinate.x, y: coordinate.y, animated: false)
                }
                completion(false)
            }
        }
    }
}

// MARK: Game management

extension ViewController {

    /// インジケータを表示する
    /// - Parameter side: 対象のプレイヤー
    private func showIndicator(of side: Disk) {
        DispatchQueue.main.async { [weak self] in
            self?.playerActivityIndicators[side.index].startAnimating()
        }
    }

    /// インジケータを隠す
    /// - Parameter side: 対象のプレイヤー
    private func hideIndicator(of side: Disk) {
        DispatchQueue.main.async { [weak self] in
            self?.playerActivityIndicators[side.index].stopAnimating()
        }
    }
}

// MARK: Inputs

extension ViewController {
    /// リセットボタンが押された場合に呼ばれるハンドラーです。
    /// アラートを表示して、ゲームを初期化して良いか確認し、
    /// "OK" が選択された場合ゲームを初期化します。
    @IBAction func pressResetButton(_ sender: UIButton) {
        let alertController = UIAlertController(
            title: "Confirmation",
            message: "Do you really want to reset the game?",
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in })
        alertController.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.controller?.reset()
        })
        present(alertController, animated: true)
    }

    /// プレイヤーのモードが変更された場合に呼ばれるハンドラーです。
    @IBAction func changePlayerControlSegment(_ sender: UISegmentedControl) {
        guard let color = playerControls.firstIndex(of: sender) else {
            return
        }

        controller?.changePlayerType(of: color, to: sender.selectedSegmentIndex)
    }
}

extension ViewController: BoardViewDelegate {
    /// `boardView` の `x`, `y` で指定されるセルがタップされたときに呼ばれます。
    /// - Parameter boardView: セルをタップされた `BoardView` インスタンスです。
    /// - Parameter x: セルの列です。
    /// - Parameter y: セルの行です。
    func boardView(_ boardView: BoardView, didSelectCellAtX x: Int, y: Int) {
        if isAnimating { return }
        controller?.specifyPlacingDiscCoordinate(x: x, y: y)
    }
}

// MARK: Additional types

final class Canceller {
    private(set) var isCancelled: Bool = false
    private let body: (() -> Void)?

    init(_ body: (() -> Void)?) {
        self.body = body
    }

    func cancel() {
        if isCancelled { return }
        isCancelled = true
        body?()
    }
}

struct DiskPlacementError: Error {
    let disk: Disk
    let coordinate: Coordinate
}

// MARK: File-private extensions

extension Disk {
    fileprivate static func from(index: Int) -> Disk {
        switch index {
        case 0: return .dark
        case 1: return .light
        default: preconditionFailure("Illegal index: \(index)")
        }
    }

    fileprivate var index: Int {
        switch self {
        case .dark: return 0
        case .light: return 1
        }
    }
}
