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

    /// どちらの色のプレイヤーのターンかを表します。ゲーム終了時は `nil` です。
    private var turn: Disk? = .dark

    private var animationCanceller: Canceller?
    private var isAnimating: Bool { animationCanceller != nil }

    /// Computerのインスタンスを保存している。マニュアルに切り替えてキャンセルする場合などに使う
    private var computers = [Disk: Computer]()

    /// ゲームの状態を保存するリポジトリ
    private let repository: GameStateRepository = GameStateFileStore()

    private var gameState: GameState {
        get {
            createGameState()
        }
        set {
            updateView(with: newValue)
        }
    }

    // Viewの情報からGameStateを作る（GameStateで管理するようになったら消す）
    private func createGameState() -> GameState {
        let darkPlayer = Player.from(index: playerControls.first?.selectedSegmentIndex ?? 0)
        let lightPlayer = Player.from(index: playerControls.last?.selectedSegmentIndex ?? 0)
        let positions = boardView.xRange.flatMap { x in
            boardView.yRange.map({ y in Position(x: x, y: y) })
        }
        let cells: [BoardCell] = positions.compactMap { p in
            guard let disk = boardView.diskAt(x: p.x, y: p.y) else {
                return nil
            }
            return BoardCell(position: p, disk: disk)
        }
        return GameState(turn: turn,
                         darkPlayer: darkPlayer,
                         lightPlayer: lightPlayer,
                         board: GameBoard(cells: cells))
    }

    // GameStateをViewに反映する
    private func updateView(with state: GameState) {
        self.turn = state.turn
        playerControls.first?.selectedSegmentIndex = state.darkPlayer.rawValue
        playerControls.last?.selectedSegmentIndex = state.lightPlayer.rawValue
        boardView.reset()
        state.board.forEach { cell in
            boardView.setDisk(cell.disk,
                              atX: cell.position.x,
                              y: cell.position.y,
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
            try loadGame()
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
    /// `x`, `y` で指定されたセルに `disk` を置きます。
    /// - Parameter x: セルの列です。
    /// - Parameter y: セルの行です。
    /// - Parameter isAnimated: ディスクを置いたりひっくり返したりするアニメーションを表示するかどうかを指定します。
    /// - Parameter completion: アニメーション完了時に実行されるクロージャです。
    ///     このクロージャは値を返さず、アニメーションが完了したかを示す真偽値を受け取ります。
    ///     もし `animated` が `false` の場合、このクロージャは次の run loop サイクルの初めに実行されます。
    /// - Throws: もし `disk` を `x`, `y` で指定されるセルに置けない場合、 `DiskPlacementError` を `throw` します。
    func placeDisk(_ disk: Disk, atX x: Int, y: Int, animated isAnimated: Bool, completion: ((Bool) -> Void)? = nil) throws {
        let diskCoordinates = gameState.board
            .positionsOfDisksToBeAcquired(by: disk, at: Position(x: x, y: y))
            .map { ($0.x, $0.y) }
        if diskCoordinates.isEmpty {
            throw DiskPlacementError(disk: disk, x: x, y: y)
        }

        if isAnimated {
            let cleanUp: () -> Void = { [weak self] in
                self?.animationCanceller = nil
            }
            animationCanceller = Canceller(cleanUp)
            animateSettingDisks(at: [(x, y)] + diskCoordinates, to: disk) { [weak self] isFinished in
                guard let self = self else { return }
                guard let canceller = self.animationCanceller else { return }
                if canceller.isCancelled { return }
                cleanUp()

                completion?(isFinished)
                try? self.saveGame()
                self.updateCountLabels()
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.boardView.setDisk(disk, atX: x, y: y, animated: false)
                for (x, y) in diskCoordinates {
                    self.boardView.setDisk(disk, atX: x, y: y, animated: false)
                }
                completion?(true)
                try? self.saveGame()
                self.updateCountLabels()
            }
        }
    }

    /// `coordinates` で指定されたセルに、アニメーションしながら順番に `disk` を置く。
    /// `coordinates` から先頭の座標を取得してそのセルに `disk` を置き、
    /// 残りの座標についてこのメソッドを再帰呼び出しすることで処理が行われる。
    /// すべてのセルに `disk` が置けたら `completion` ハンドラーが呼び出される。
    private func animateSettingDisks<C: Collection>(at coordinates: C, to disk: Disk, completion: @escaping (Bool) -> Void)
        where C.Element == (Int, Int) {
        guard let (x, y) = coordinates.first else {
            completion(true)
            return
        }

        guard let animationCanceller = self.animationCanceller else {
            return
        }
        boardView.setDisk(disk, atX: x, y: y, animated: true) { [weak self] isFinished in
            guard let self = self else { return }
            if animationCanceller.isCancelled { return }
            if isFinished {
                self.animateSettingDisks(at: coordinates.dropFirst(), to: disk, completion: completion)
            } else {
                for (x, y) in coordinates {
                    self.boardView.setDisk(disk, atX: x, y: y, animated: false)
                }
                completion(false)
            }
        }
    }
}

// MARK: Game management

extension ViewController {
    /// ゲームの状態を初期化し、新しいゲームを開始します。
    func newGame() {
        boardView.reset()
        turn = .dark

        for playerControl in playerControls {
            playerControl.selectedSegmentIndex = Player.manual.rawValue
        }

        updateMessageViews()
        updateCountLabels()

        try? saveGame()
    }

    /// プレイヤーの行動を待ちます。
    func waitForPlayer() {
        guard let turn = self.turn else { return }
        let player = Player.from(index: playerControls[turn.index].selectedSegmentIndex)
        computers[turn] = player.computer(with: gameState)

        playTurnOfComputer()
    }

    /// プレイヤーの行動後、そのプレイヤーのターンを終了して次のターンを開始します。
    /// もし、次のプレイヤーに有効な手が存在しない場合、パスとなります。
    /// 両プレイヤーに有効な手がない場合、ゲームの勝敗を表示します。
    func nextTurn() {
        guard var turn = self.turn else { return }

        turn.flip()

        let state = gameState
        if state.board.settablePositions(disk: turn).isEmpty {
            if state.board.settablePositions(disk: turn.flipped).isEmpty {
                self.turn = nil
                updateMessageViews()
            } else {
                self.turn = turn
                updateMessageViews()

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
        } else {
            self.turn = turn
            updateMessageViews()
            waitForPlayer()
        }
    }

    /// "Computer" が選択されている場合のプレイヤーの行動を決定します。
    func playTurnOfComputer() {
        guard let turn = self.turn else {
            preconditionFailure()
        }

        computers[turn]?.startOperation(
            onStart: { [weak self] in self?.showIndicator(of: turn) },
            onComplete: { [weak self] result in
                DispatchQueue.main.async { [weak self] in
                    self?.hideIndicator(of: turn)
                    self?.apply(result, for: turn)
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
        case .position(let position):
            try? placeDisk(side, atX: position.x, y: position.y, animated: true) { [weak self] _ in
                self?.nextTurn()
            }
        case .noPosition:
            nextTurn()
        case .cancel:
            computers.removeValue(forKey: side)
        }
    }
}

// MARK: Views

extension ViewController {
    /// 各プレイヤーの獲得したディスクの枚数を表示します。
    func updateCountLabels() {
        let state = gameState
        Disk.sides.forEach {
            countLabels[$0.index].text = state.board.count(of: $0).description
        }
    }

    /// 現在の状況に応じてメッセージを表示します。
    func updateMessageViews() {
        let message = gameState.message
        messageLabel.text = message.label
        guard let side = message.disk else {
            messageDiskSizeConstraint.constant = 0
            return
        }

        messageDiskView.disk = side
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

            self.computers.values.forEach { $0.cancelOperation() }
            self.computers.removeAll()

            self.newGame()
            self.waitForPlayer()
        })
        present(alertController, animated: true)
    }

    /// プレイヤーのモードが変更された場合に呼ばれるハンドラーです。
    @IBAction func changePlayerControlSegment(_ sender: UISegmentedControl) {
        guard let index = playerControls.firstIndex(of: sender) else {
            return
        }
        let side = Disk.from(index: index)

        try? saveGame()

        computers[side]?.cancelOperation()
        computers.removeValue(forKey: side)

        let player = Player.from(index: sender.selectedSegmentIndex)
        computers[side] = player.computer(with: gameState)
        if !isAnimating, side == turn {
            playTurnOfComputer()
        }
    }
}

extension ViewController: BoardViewDelegate {
    /// `boardView` の `x`, `y` で指定されるセルがタップされたときに呼ばれます。
    /// - Parameter boardView: セルをタップされた `BoardView` インスタンスです。
    /// - Parameter x: セルの列です。
    /// - Parameter y: セルの行です。
    func boardView(_ boardView: BoardView, didSelectCellAtX x: Int, y: Int) {
        guard let turn = turn else { return }
        let player = Player.from(index: playerControls[turn.index].selectedSegmentIndex)
        if isAnimating { return }
        guard case .manual = player else { return }
        // try? because doing nothing when an error occurs
        try? placeDisk(turn, atX: x, y: y, animated: true) { [weak self] _ in
            self?.nextTurn()
        }
    }
}

// MARK: Save and Load

extension ViewController {
    private func saveGame() throws {
        try repository.save(gameState)
    }

    private func loadGame() throws {
        gameState = try repository.load()
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
    let x: Int
    let y: Int
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

// - MARK: テスト用 privateな要素へのアクセス 不要になったら削除

extension ViewController {
    func changeTurn(to disk: Disk?) {
        turn = disk
    }

    func getTurn() -> Disk? {
        return turn
    }

    func segmentControlForDark() -> UISegmentedControl? {
        return playerControls.first
    }

    func segmentControlForLight() -> UISegmentedControl? {
        return playerControls.last
    }

    func set(disk: Disk?, atX x: Int, y: Int) {
        boardView.setDisk(disk, atX: x, y: y, animated: false)
    }

    func diskAt(x: Int, y: Int) -> Disk? {
        boardView.diskAt(x: x, y: y)
    }

    func getGameState() -> GameState {
        return gameState
    }

    func countLabelForDark() -> UILabel? {
        return countLabels.first
    }

    func countLabelForLight() -> UILabel? {
        return countLabels.last
    }

    func getMessageDiskView() -> DiskView {
        return messageDiskView
    }

    func getMessageLabel() -> UILabel {
        return messageLabel
    }

    func getMessageDiskSizeConstraint() -> NSLayoutConstraint {
        return messageDiskSizeConstraint
    }
}
