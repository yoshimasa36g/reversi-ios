import ReversiEntity // TODO: 後で外す
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

    /// ゲームの状態を保存するリポジトリ
    private let repository: GameStateRepository = GameStateFileStore()

    private var game = Game() {
        didSet {
            updateView()
        }
    }

    // GameStateをViewに反映する
    private func updateView() {
        if isAnimating { return }
        playerControls.first?.selectedSegmentIndex = game.players.type(of: .dark()).rawValue
        playerControls.last?.selectedSegmentIndex = game.players.type(of: .light()).rawValue
        boardView.reset()
        game.board.eachCells { cell in
            boardView.setDisk(cell.disc == .dark() ? .dark : .light,
                              atX: cell.coordinate.x,
                              y: cell.coordinate.y,
                              animated: false)
        }
        updateMessageViews()
        updateCountLabels()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        boardView.delegate = self
        messageDiskSize = messageDiskSizeConstraint.constant

        do {
            game = try repository.load()
        } catch _ {
            newGame()
        }
    }

    private var viewHasAppeared: Bool = false
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if viewHasAppeared { return }
        viewHasAppeared = true
        waitForPlayer()
    }
}

// MARK: Reversi logics

extension ViewController {
    /// `coordinate` で指定されたセルにアニメーションありで `disk` を置く
    /// - Parameters:
    ///   - disk: 置くディスク
    ///   - coordinate: セルの座標
    ///   - completion: アニメーション完了時に実行される処理
    ///     このクロージャは値を返さず、アニメーションが完了したかを示す真偽値を受け取ります。
    /// - Throws: もし `disk` を `coordinate` で指定されるセルに置けない場合、 `DiskPlacementError` を `throw` します。
    func placeDisk(_ disk: Disk, at coordinate: Coordinate, completion: ((Bool) -> Void)? = nil) throws {
        let diskCoordinates = game.coordinatesOfGettableDiscs(by: disk == .dark ? .dark() : .light(), at: coordinate)
        if diskCoordinates.isEmpty {
            throw DiskPlacementError(disk: disk, coordinate: coordinate)
        }

        let cleanUp: () -> Void = { [weak self] in
            self?.animationCanceller = nil
        }
        animationCanceller = Canceller(cleanUp)
        animateSettingDisks(at: [coordinate] + diskCoordinates, to: disk) { [weak self] isFinished in
            guard let self = self else { return }
            guard let canceller = self.animationCanceller else { return }
            if canceller.isCancelled { return }
            cleanUp()

            completion?(isFinished)
            try? self.repository.save(self.game)
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
    ) where C.Element == Coordinate {
        guard let coordinate = coordinates.first else {
            completion(true)
            return
        }

        guard let animationCanceller = self.animationCanceller else {
            return
        }
        place(disk: disk, at: coordinate, animated: true) { [weak self] isFinished in
            guard let self = self else { return }
            if animationCanceller.isCancelled { return }
            if isFinished {
                self.animateSettingDisks(at: coordinates.dropFirst(), to: disk, completion: completion)
            } else {
                for coordinate in coordinates {
                    self.place(disk: disk, at: coordinate, animated: false)
                }
                completion(false)
            }
        }
    }

    private func place(disk: Disk?, at coordinate: Coordinate, animated: Bool, completion: ((Bool) -> Void)? = nil) {
        boardView.setDisk(disk, atX: coordinate.x, y: coordinate.y, animated: animated, completion: completion)
        if let disk = disk {
            game = game.place(disc: disk == .dark ? .dark() : .light(), at: coordinate)
            return
        }
        game = game.removeDisc(at: coordinate)
    }
}

// MARK: Game management

extension ViewController {
    /// ゲームの状態を初期化し、新しいゲームを開始します。
    func newGame() {
        game = game.reset()
        try? repository.save(game)
    }

    /// プレイヤーの行動を待ちます。
    func waitForPlayer() {
        guard let turn = game.turn else { return }
        let side = turn == .dark() ? Disk.dark : Disk.light
        let player = (PlayerType(rawValue: playerControls[side.index].selectedSegmentIndex) ?? .manual).toPlayer()
        game = game.changePlayer(of: turn, to: player)

        playTurn()
    }

    /// プレイヤーの行動後、そのプレイヤーのターンを終了して次のターンを開始します。
    /// もし、次のプレイヤーに有効な手が存在しない場合、パスとなります。
    /// 両プレイヤーに有効な手がない場合、ゲームの勝敗を表示します。
    func nextTurn() {
        guard var turn = game.turn else { return }

        turn = turn.flipped

        if game.isGameOver {
            game = game.changeTurn(to: nil)
            return
        }

        if game.isPlaceable(disc: turn) {
            game = game.changeTurn(to: turn)
            waitForPlayer()
            return
        }

        game = game.changeTurn(to: turn)

        let alertController = UIAlertController(
            title: "Pass",
            message: "Cannot place a disk.",
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default) { [weak self] _ in
            self?.nextTurn()
        })
        present(alertController, animated: true)
    }

    /// プレイヤーの行動を決定します。
    func playTurn() {
        guard let turn = game.turn else {
            preconditionFailure()
        }

        let side = turn == .dark() ? Disk.dark : Disk.light
        game.players.startOperation(
            gameState: game,
            onStart: { [weak self] in self?.showIndicator(of: side) },
            onComplete: { [weak self] result in
                DispatchQueue.main.async { [weak self] in
                    self?.hideIndicator(of: side)
                    self?.apply(result, for: side)
                }
            })
    }

    /// インジケータを表示する
    /// - Parameter side: 対象のプレイヤー
    private func showIndicator(of side: Disk) {
        playerActivityIndicators[side.index].startAnimating()
    }

    /// インジケータを隠す
    /// - Parameter side: 対象のプレイヤー
    private func hideIndicator(of side: Disk) {
        playerActivityIndicators[side.index].stopAnimating()
    }

    /// Computerの思考結果を適用する
    /// - Parameters:
    ///   - operationResult: Computerの思考結果
    ///   - side: 適用するプレイヤー
    private func apply(_ operationResult: OperationResult, for side: Disk) {
        switch operationResult {
        case .coordinate(let coordinate):
            try? placeDisk(side, at: coordinate) { [weak self] _ in
                self?.nextTurn()
            }
        case .pass:
            nextTurn()
        case .cancel:
            break
        }
    }
}

// MARK: Views

extension ViewController {
    /// 各プレイヤーの獲得したディスクの枚数を表示します。
    func updateCountLabels() {
        Disk.sides.forEach {
            let disc: Disc = $0 == .dark ? .dark() : .light()
            countLabels[$0.index].text = game.count(of: disc).description
        }
    }

    /// 現在の状況に応じてメッセージを表示します。
    func updateMessageViews() {
        let message = game.message
        messageLabel.text = message.label
        guard let disc = message.disc else {
            messageDiskSizeConstraint.constant = 0
            return
        }

        messageDiskView.disk = disc == .dark() ? .dark : .light
        messageDiskSizeConstraint.constant = messageDiskSize
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
            guard let self = self else { return }

            self.animationCanceller?.cancel()
            self.animationCanceller = nil

            self.game.players.cancelAll()

            self.newGame()
            self.waitForPlayer()
        })
        present(alertController, animated: true)
    }

    /// プレイヤーのモードが変更された場合に呼ばれるハンドラーです。
    @IBAction func changePlayerControlSegment(_ sender: UISegmentedControl) {
        guard let index = playerControls.firstIndex(of: sender),
            let color = DiscColor(rawValue: index) else {
            return
        }

        let side = Disc(color: color)

        game.players.cancelOperation(of: side)

        let player = (PlayerType(rawValue: sender.selectedSegmentIndex) ?? .manual).toPlayer()
        game = game.changePlayer(of: side, to: player)

        try? repository.save(game)

        if !isAnimating, side == game.turn {
            playTurn()
        }
    }
}

extension ViewController: BoardViewDelegate {
    /// `boardView` の `x`, `y` で指定されるセルがタップされたときに呼ばれます。
    /// - Parameter boardView: セルをタップされた `BoardView` インスタンスです。
    /// - Parameter x: セルの列です。
    /// - Parameter y: セルの行です。
    func boardView(_ boardView: BoardView, didSelectCellAtX x: Int, y: Int) {
        guard let turn = game.turn else { return }
        let side = turn == .dark() ? Disk.dark : Disk.light
        let player = (PlayerType(rawValue: playerControls[side.index].selectedSegmentIndex) ?? .manual).toPlayer()
        if isAnimating { return }
        guard player is Human else { return }
        // try? because doing nothing when an error occurs
        try? placeDisk(side, at: Coordinate(x: x, y: y)) { [weak self] _ in
            self?.nextTurn()
        }
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
