import 'dart:math';

import 'package:curdle/app/app_colors.dart';
import 'package:curdle/curdle/data/word_list.dart';
import 'package:curdle/curdle/models/letter_model.dart';
import 'package:curdle/curdle/models/word_model.dart';
import 'package:curdle/curdle/widgets/board.dart';
import 'package:curdle/curdle/widgets/keyboard.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

enum GameStatus { playing, submitting, lost, won }

class CurdleScreen extends StatefulWidget {
  const CurdleScreen({Key? key}) : super(key: key);

  @override
  State<CurdleScreen> createState() => _CurdleScreenState();
}

class _CurdleScreenState extends State<CurdleScreen> {
  GameStatus _gameStatus = GameStatus.playing;

  final List<Word> _board = List.generate(
    6,
    (_) => Word(
      letters: List.generate(
        6,
        (_) => Letter.empty(),
      ),
    ),
  );

  final List<List<GlobalKey<FlipCardState>>> _flipCardKeys = List.generate(
    6,
    (_) => List.generate(
      6,
      (_) => GlobalKey<FlipCardState>(),
    ),
  );

  int _currentWordIndex = 0;

  Word? get _currentWord =>
      _currentWordIndex < _board.length ? _board[_currentWordIndex] : null;

  Word _solution = Word.fromString(
    sixLetterWords[Random().nextInt(sixLetterWords.length)].toUpperCase(),
  );

  final Set<Letter> _keyboardLetters = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'CURDLE',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Board(board: _board, flipCardKeys: _flipCardKeys),
          const SizedBox(
            height: 80,
          ),
          KeyBoard(
            onKeyTapped: _onKeyTapped,
            onDeleteTapped: _onDeleteTapped,
            onEnterTapped: _onEnterTapped,
            letters: _keyboardLetters,
          )
        ],
      ),
    );
  }

  void _onKeyTapped(String val) {
    if (_gameStatus == GameStatus.playing) {
      setState(() => _currentWord?.addLetter(val));
    }
  }

  void _onDeleteTapped() {
    if (_gameStatus == GameStatus.playing) {
      setState(() => _currentWord?.removeLetter());
    }
  }

  Future<void> _onEnterTapped() async {
    if (_gameStatus == GameStatus.playing &&
        _currentWord != null &&
        !_currentWord!.letters.contains(Letter.empty())) {
      _gameStatus = GameStatus.submitting;

      for (var i = 0; i < _currentWord!.letters.length; i++) {
        final currentWordLetter = _currentWord!.letters[i];
        final currentSolutionLetter = _solution.letters[i];

        setState(() {
          if (currentWordLetter == currentSolutionLetter) {
            _currentWord!.letters[i] =
                currentWordLetter.copyWith(status: LetterStatus.correct);
          } else if (_solution.letters.contains(currentWordLetter)) {
            _currentWord!.letters[i] =
                currentWordLetter.copyWith(status: LetterStatus.inWord);
          } else {
            _currentWord!.letters[i] =
                currentWordLetter.copyWith(status: LetterStatus.notInWord);
          }
        });
        final letter = _keyboardLetters.firstWhere(
          (e) => e.val == currentWordLetter,
          orElse: () => Letter.empty(),
        );
        if (letter.status != LetterStatus.correct) {
          _keyboardLetters.removeWhere((e) => e.val == currentWordLetter.val);
          _keyboardLetters.add(_currentWord!.letters[i]);
        }
        await Future.delayed(
          const Duration(milliseconds: 150),
          () => _flipCardKeys[_currentWordIndex][i].currentState?.toggleCard(),
        );
      }

      _checkIfWinOrLoss();
    }
  }

  void _checkIfWinOrLoss() {
    if (_currentWord!.wordString == _solution.wordString) {
      _gameStatus = GameStatus.won;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        dismissDirection: DismissDirection.none,
        duration: const Duration(days: 1),
        backgroundColor: correctColor,
        content: const Text(
          'You Won!!',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        action: SnackBarAction(
          onPressed: _restart,
          textColor: Colors.white,
          label: 'New Game',
        ),
      ));
    } else if (_currentWordIndex + 1 >= _board.length) {
      _gameStatus = GameStatus.lost;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          dismissDirection: DismissDirection.none,
          duration: const Duration(days: 1),
          backgroundColor: incorrectColor,
          content: Text(
            'You Lost :( Solution is: ${_solution.wordString}',
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          action: SnackBarAction(
            onPressed: _restart,
            textColor: Colors.white,
            label: 'New Game',
          ),
        ),
      );
    } else {
      _gameStatus = GameStatus.playing;
    }
    _currentWordIndex += 1;
  }

  void _restart() {
    setState(() {
      _gameStatus = GameStatus.playing;
      _currentWordIndex = 0;
      _board.clear();
      _board.addAll(
        List.generate(
          6,
          (_) => Word(
            letters: List.generate(
              6,
              (_) => Letter.empty(),
            ),
          ),
        ),
      );
      _solution = Word.fromString(
        sixLetterWords[Random().nextInt(sixLetterWords.length)].toUpperCase(),
      );

      _flipCardKeys.clear();
      _flipCardKeys.addAll(
        List.generate(
          6,
          (_) => List.generate(
            6,
            (_) => GlobalKey<FlipCardState>(),
          ),
        ),
      );

      _keyboardLetters.clear();
    });
  }
}
