// Generates functions/src/content/stageSnippets.json from Dart source of truth.
// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:lifequest/data/content/stage_snippets_data.dart';
import 'package:lifequest/data/content/stage_teen_variants.dart';

Map<String, dynamic> _encodeCopy(StageCopy copy) => {
      'learn': copy.learn,
      'apply': copy.apply,
      'quiz': copy.quiz
          .map(
            (q) => {
              'prompt': q.prompt,
              'correct': q.correct,
              'wrong': q.wrong,
            },
          )
          .toList(),
    };

void main() {
  final standard = <String, dynamic>{};
  for (final entry in kStageCopyByTitle.entries) {
    standard[entry.key] = _encodeCopy(entry.value);
  }

  final teen = <String, dynamic>{};
  for (final entry in kTeenStageCopyByTitle.entries) {
    teen[entry.key] = _encodeCopy(entry.value);
  }

  final payload = {'standard': standard, 'teenL4L6': teen};
  final path = 'functions/src/content/stageSnippets.json';
  File(path).writeAsStringSync(const JsonEncoder.withIndent('  ').convert(payload));
  print(
    'Wrote ${standard.length} standard + ${teen.length} teen snippets to $path',
  );
}
