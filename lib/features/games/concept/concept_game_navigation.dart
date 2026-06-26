import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Leave a game — pop if stacked, else return to the hub (direct URL entry).
void leaveConceptGame(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go('/concept-games');
  }
}

/// Leave the hub — pop if stacked, else splash.
void leaveConceptGamesHub(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go('/');
  }
}
