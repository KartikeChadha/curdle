import 'package:curdle/curdle/models/letter_model.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

const _qwerty = [
  ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
  ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
  ['ENTER', 'Z', 'X', 'C', 'V', 'B', 'N', 'M', 'DEL'],
];

class KeyBoard extends StatelessWidget {
  final void Function(String) onKeyTapped;
  final ui.VoidCallback onDeleteTapped;
  final ui.VoidCallback onEnterTapped;
  final Set<Letter> letters;
  const KeyBoard({
    Key? key,
    required this.onKeyTapped,
    required this.onDeleteTapped,
    required this.onEnterTapped,
    required this.letters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _qwerty
          .map(
            (keyRow) => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: keyRow.map(
                (letter) {
                  if (letter == 'DEL') {
                    return _KeyboardButton.delete(onTap: onDeleteTapped);
                  } else if (letter == 'ENTER') {
                    return _KeyboardButton.enter(onTap: onEnterTapped);
                  }

                  final letterKey = letters.firstWhere(
                    (e) => e.val == letter,
                    orElse: () => Letter.empty(),
                  );

                  return _KeyboardButton(
                      onTap: () => onKeyTapped(letter),
                      letter: letter,
                      backgroundColor: letterKey != Letter.empty()
                          ? letterKey.backgroundColor
                          : Colors.grey);
                },
              ).toList(),
            ),
          )
          .toList(),
    );
  }
}

class _KeyboardButton extends StatelessWidget {
  final double height;
  final double width;
  final ui.VoidCallback onTap;
  final Color backgroundColor;
  final String letter;

  const _KeyboardButton({
    Key? key,
    this.height = 48,
    this.width = 30,
    required this.onTap,
    required this.backgroundColor,
    required this.letter,
  }) : super(key: key);

  factory _KeyboardButton.delete({
    required ui.VoidCallback onTap,
  }) =>
      _KeyboardButton(
        width: 56,
        onTap: onTap,
        backgroundColor: Colors.grey,
        letter: 'DEL',
      );
  factory _KeyboardButton.enter({
    required ui.VoidCallback onTap,
  }) =>
      _KeyboardButton(
        width: 56,
        onTap: onTap,
        backgroundColor: Colors.grey,
        letter: 'ENTER',
      );
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 3.0,
        horizontal: 2.0,
      ),
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: height,
            width: width,
            alignment: Alignment.center,
            child: Text(
              letter,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
