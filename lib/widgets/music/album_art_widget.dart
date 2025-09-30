import 'package:flutter/material.dart';

class AlbumArtWidget extends StatelessWidget {
  const AlbumArtWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 12,
      child: Center(
        child: LayoutBuilder(
          builder: (context, boxConstraints) {
            final size =
                boxConstraints.maxHeight < boxConstraints.maxWidth * 0.8
                    ? boxConstraints.maxHeight * 0.9
                    : boxConstraints.maxWidth * 0.7;
            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xFF2C4A6E),
              ),
              child: Center(
                child: Icon(
                  Icons.music_note_rounded,
                  color: const Color(0xFF5A7BA8),
                  size: size * 0.35,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
