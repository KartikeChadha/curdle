import 'dart:math';

import 'package:curdle/curdle/data/word_list.dart';
import 'package:curdle/curdle/models/letter_model.dart';
import 'package:curdle/curdle/models/word_model.dart';
import 'package:curdle/curdle/widgets/board.dart';
import 'package:curdle/curdle/widgets/keyboard.dart';
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

  int _currentWordIndex = 0;

  Word? get _currentWord =>
      _currentWordIndex < _board.length ? _board[_currentWordIndex] : null;

  Word? _solution = Word.fromString(
    sixLetterWords[Random().nextInt(sixLetterWords.length)].toUpperCase(),
  );
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
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Board(board: _board),
        const SizedBox(
          height: 80,
        ),
        KeyBoard(
          onKeyTapped: _onKeyTapped,
          onDeleteTapped: _onDeleteTapped,
          onEnterTapped: _onEnterTapped,
        )
      ]),
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

  void _onEnterTapped() {
    if (_gameStatus == GameStatus.playing &&
        _currentWord != null &&
        !_currentWord!.letters.contains(Letter.empty())) {
      _gameStatus = GameStatus.submitting;

      for (var i = 0; i < _currentWord!.letters.length; i++) {
        final currentWordLetter = _currentWord!.letters[i];
        final currentSolutionLetter = _solution!.letters[i];

        setState(() {
          if (currentWordLetter == currentSolutionLetter) {
            _currentWord!.letters[i] =
                currentWordLetter.copyWith(status: LetterStatus.correct);
          } else if (_solution!.letters.contains(currentWordLetter)) {
            _currentWord!.letters[i] =
                currentWordLetter.copyWith(status: LetterStatus.inWord);
          } else {
            _currentWord!.letters[i] =
                currentWordLetter.copyWith(status: LetterStatus.notInWord);
          }
        });
      }
    }
  }
}
