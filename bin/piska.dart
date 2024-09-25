import 'dart:io';
import 'dart:math';

enum CellValue { nothing, X, O }
enum GameMode { playerVsPlayer, playerVsAI }

class Cell {
  CellValue? value;
  int? x;
  int? y;

  Cell(CellValue cellValue, int coordX, int coordY) {
    value = cellValue;
    x = coordX;
    y = coordX;
  }

  Cell.empty(int coordX, int coordY) {
    value = CellValue.nothing;
    x = coordX;
    y = coordY;
  }

  @override
  String toString() {
    switch (value) {
      case CellValue.X:
        return 'X';
      case CellValue.O:
        return 'O';
      default:
        return '.';
    }
  }
}

final class GameManager {
  static int boardSize = 0;
  CellValue currentPlayer = CellValue.X;
  GameMode? gameMode;
  Random random = Random();

  void displayBoard(List<Cell> cells) {
    AlertManager.consoleOutput("  ${List.generate(boardSize, (index) => index + 1).join(' ')}");
    for (int i = 0; i < boardSize; i++) {
      String row = "${i + 1} ";
      for (int j = 0; j < boardSize; j++) {
        Cell cell = cells.firstWhere((cell) => cell.x == i && cell.y == j);
        row += "${cell.toString()} ";
      }
      AlertManager.consoleOutput(row);
    }
  }

  void startNewGame() {
    currentPlayer = random.nextBool() ? CellValue.X : CellValue.O;
    AlertManager.startGameAnnouncement(currentPlayer);
  }

  bool checkWinner(List<Cell> cells) {
    for (int i = 0; i < boardSize; i++) {
      if (_checkLine(cells, i, true) || _checkLine(cells, i, false)) {
        return true;
      }
    }

    if (_checkDiagonal(cells, true) || _checkDiagonal(cells, false)) {
      return true;
    }

    return false;
  }

  bool _checkLine(List<Cell> cells, int index, bool isRow) {
    CellValue firstCellValue = cells.firstWhere((cell) => (isRow ? cell.x : cell.y) == index).value!;
    if (firstCellValue == CellValue.nothing) return false;

    for (int i = 1; i < boardSize; i++) {
      Cell cell = cells.firstWhere((cell) => isRow ? (cell.x == index && cell.y == i) : (cell.x == i && cell.y == index));
      if (cell.value != firstCellValue) return false;
    }
    return true;
  }

  bool _checkDiagonal(List<Cell> cells, bool isMain) {
    CellValue firstCellValue = cells.firstWhere((cell) => cell.x == 0 && cell.y == (isMain ? 0 : boardSize - 1)).value!;
    if (firstCellValue == CellValue.nothing) return false;

    for (int i = 1; i < boardSize; i++) {
      Cell cell = cells.firstWhere((cell) => isMain ? (cell.x == i && cell.y == i) : (cell.x == i && cell.y == boardSize - i - 1));
      if (cell.value != firstCellValue) return false;
    }
    return true;
  }

  void togglePlayer() {
    currentPlayer = currentPlayer == CellValue.X ? CellValue.O : CellValue.X;
  }

  // логика хода робота
  void makeAIMove(List<Cell> cells) {
    List<Cell> availableCells = cells.where((cell) => cell.value == CellValue.nothing).toList();
    if (availableCells.isNotEmpty) {
      Cell randomCell = availableCells[random.nextInt(availableCells.length)];
      randomCell.value = currentPlayer;
      AlertManager.consoleOutput("AI moved to (${randomCell.x! + 1}, ${randomCell.y! + 1})");
    }
  }

  // проверка на все поля
  bool isBoardFull(List<Cell> cells) {
    return cells.every((cell) => cell.value != CellValue.nothing);
  }
}

final class AlertManager {
  static void inputError(String message) {
    print("INPUT ERROR: $message");
  }

  static void consoleOutput(String message) {
    print(message);
  }

  static void startGameAnnouncement(CellValue currentPlayer) {
    print("FIRST PLAYER: ${currentPlayer == CellValue.X ? 'X' : 'O'}");
  }

  static void playerTurnAnnouncement(CellValue currentPlayer) {
    print("${currentPlayer == CellValue.X ? 'X' : 'O'}'s turn. Enter row and column (e.g. 1 2): ");
  }

  static void announceWinner(CellValue winner) {
    print("WINNER: ${winner == CellValue.X ? 'X' : 'O'}");
  }

  static void announceDraw() {
    print("DRAW!");
  }

  static void gameOver() {
    print("GAME OVER.");
  }
}

final class Helper {
  bool checkValidBoardSize(String? inputBoardSize) {
    int? parsableSize = int.tryParse(inputBoardSize ?? '');

    if (parsableSize != null) {
      if (parsableSize >= 3 && parsableSize <= 9) {
        GameManager.boardSize = parsableSize;
        return true;
      } else {
        AlertManager.inputError("Value is not in range of 3-9");
      }
    } else {
      AlertManager.inputError("Entered string is not an Int value");
    }
    return false;
  }

  bool checkValidMove(List<Cell> cells, int row, int col) {
    if (row >= 1 && row <= GameManager.boardSize && col >= 1 && col <= GameManager.boardSize) {
      Cell cell = cells.firstWhere((cell) => cell.x == row - 1 && cell.y == col - 1);
      if (cell.value == CellValue.nothing) {
        return true;
      } else {
        AlertManager.inputError("Cell already occupied");
      }
    } else {
      AlertManager.inputError("Invalid coordinates");
    }
    return false;
  }
}

void main() {
  List<Cell> cells = [];
  bool isValidBoardSize = false;
  GameManager gameManager = GameManager();
  Helper helper = Helper();

  AlertManager.consoleOutput("Choose game mode: 1 - Player vs Player, 2 - Player vs AI");
  String? modeInput = stdin.readLineSync();
  if (modeInput == '1') {
    gameManager.gameMode = GameMode.playerVsPlayer;
  } else if (modeInput == '2') {
    gameManager.gameMode = GameMode.playerVsAI;
  } else {
    AlertManager.consoleOutput("Invalid mode selection");
    return;
  }

  AlertManager.consoleOutput("Enter board size (3-9): ");

  while (!isValidBoardSize) {
    String? inputBoardSize = stdin.readLineSync();
    isValidBoardSize = helper.checkValidBoardSize(inputBoardSize);
  }

  // Заполнение листа пустыми параметрами
  for (int i = 0; i < GameManager.boardSize; i++) {
    for (int j = 0; j < GameManager.boardSize; j++) {
      cells.add(Cell.empty(i, j));
    }
  }

  bool gameWon = false;
  bool isDraw = false;
  gameManager.startNewGame();

  while (!gameWon && !isDraw) {
    gameManager.displayBoard(cells);

    if (gameManager.gameMode == GameMode.playerVsPlayer || gameManager.currentPlayer == CellValue.X) {
      // ход игрока (любого, либо игрока в режиме против робота)
      AlertManager.playerTurnAnnouncement(gameManager.currentPlayer);
      String? inputMove = stdin.readLineSync();
      List<String> inputs = inputMove?.split(' ') ?? [];
      if (inputs.length != 2) continue;

      int? row = int.tryParse(inputs[0]);
      int? col = int.tryParse(inputs[1]);

      if (row != null && col != null && helper.checkValidMove(cells, row, col)) {
        Cell cell = cells.firstWhere((cell) => cell.x == row - 1 && cell.y == col - 1);
        cell.value = gameManager.currentPlayer;

        if (gameManager.checkWinner(cells)) {
          gameManager.displayBoard(cells);
          AlertManager.announceWinner(gameManager.currentPlayer);
          gameWon = true;
        } else if (gameManager.isBoardFull(cells)) {
          gameManager.displayBoard(cells);
          AlertManager.announceDraw();
          isDraw = true;
        } else {
          gameManager.togglePlayer();
        }
      }
    } else {
      // ход робота
      gameManager.makeAIMove(cells);
      if (gameManager.checkWinner(cells)) {
        gameManager.displayBoard(cells);
        AlertManager.announceWinner(gameManager.currentPlayer);
        gameWon = true;
      } else if (gameManager.isBoardFull(cells)) {
        gameManager.displayBoard(cells);
        AlertManager.announceDraw();
        isDraw = true;
      } else {
        gameManager.togglePlayer();
      }
    }

    if (gameWon || isDraw) {
      AlertManager.gameOver();
    }
  }
}
