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

    private var playerCancellers: [Disk: Canceller] = [:]

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
        let darkPlayer = Player(rawValue: playerControls.first?.selectedSegmentIndex ?? 0) ?? .manual
        let lightPlayer = Player(rawValue: playerControls.last?.selectedSegmentIndex ?? 0) ?? .manual
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

    // GameStateをViewに反映する（GameStateで管理するようになったら削除する）
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
        guard let turn = self.turn,
            let player = Player(rawValue: playerControls[turn.index].selectedSegmentIndex) else { return }
        switch player {
        case .manual:
            break
        case .computer:
            playTurnOfComputer()
        }
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
        guard let turn = self.turn,
            let (x, y) = gameState.board.settablePositions(disk: turn)
                .map({ ($0.x, $0.y) }).randomElement() else { preconditionFailure() }

        playerActivityIndicators[turn.index].startAnimating()

        let cleanUp: () -> Void = { [weak self] in
            guard let self = self else { return }
            self.playerActivityIndicators[turn.index].stopAnimating()
            self.playerCancellers[turn] = nil
        }
        let canceller = Canceller(cleanUp)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let self = self else { return }
            if canceller.isCancelled { return }
            cleanUp()

            try? self.placeDisk(turn, atX: x, y: y, animated: true) { [weak self] _ in
                self?.nextTurn()
            }
        }

        playerCancellers[turn] = canceller
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

            for side in Disk.sides {
                self.playerCancellers[side]?.cancel()
                self.playerCancellers.removeValue(forKey: side)
            }

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
        let side: Disk = Disk(index: index)

        try? saveGame()

        if let canceller = playerCancellers[side] {
            canceller.cancel()
        }

        guard let player = Player(rawValue: sender.selectedSegmentIndex) else {
            return
        }
        if !isAnimating, side == turn, case .computer = player {
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
        guard let turn = turn,
            let player = Player(rawValue: playerControls[turn.index].selectedSegmentIndex) else { return }
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

enum Player: Int, Codable {
    case manual = 0
    case computer = 1
}

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
    init(index: Int) {
        for side in Disk.sides {
            if index == side.index {
                self = side
                return
            }
        }
        preconditionFailure("Illegal index: \(index)")
    }

    var index: Int {
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

    func getCountLabels() -> [UILabel] {
        return countLabels
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
