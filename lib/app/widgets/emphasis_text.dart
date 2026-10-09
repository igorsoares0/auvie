import 'package:flutter/material.dart';

/// Text where `*words*` are set in italic: the handoff's headline style
/// ("What are we *developing* today?").
class EmphasisText extends StatelessWidget {
  const new(this.text, {required this.style, super.key});

  final String text;
  final TextStyle style;

  static List<TextSpan> spans(String text) {
    final parts = text.split('*');
    return [
      for (final (i, part) in parts.indexed)
        if (part.isNotEmpty)
          TextSpan(
            text: part,
            style: i.isOdd
                ? const TextStyle(fontStyle: FontStyle.italic)
                : null,
          ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(style: style, children: spans(text)),
      semanticsLabel: text.replaceAll('*', ''),
    );
  }
}
