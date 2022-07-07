import 'package:curdle/curdle/models/word_model.dart';
import 'package:curdle/curdle/widgets/board_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class Board extends StatelessWidget {
  const Board({
    Key? key,
    required this.board,
  }) : super(key: key);

  final List<Word> board;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: board
          .map(
            (word) => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: word.letters
                  .map((letter) => BoardTile(letter: letter))
                  .toList(),
            ),
          )
          .toList(),
    );
  }
}
