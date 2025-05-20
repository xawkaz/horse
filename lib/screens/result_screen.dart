import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../main.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameModel>(
      builder: (context, game, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(
              'Résultats',
              style: GoogleFonts.poppins(
                color: Theme.of(context).appBarTheme.titleTextStyle?.color,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.background,
                  Theme.of(context).colorScheme.surface,
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Animation de victoire
                  Lottie.asset(
                    'assets/animations/loading.json',
                    width: 200,
                    height: 200,
                  ),

                  const SizedBox(height: 20),

                  // Titre du résultat
                  Text(
                    _getResultTitle(game),
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 10),

                  // Sous-titre avec le temps écoulé
                  Text(
                    'Temps: ${_formatTime(game.elapsedTimeInSeconds)}',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Détails du jeu
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Theme.of(context).colorScheme.outline),
                    ),
                    child: Column(
                      children: [
                        // Nombre secret
                        Text(
                          'Le nombre secret était:',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          game.secretNumber.join(''),
                          style: GoogleFonts.poppins(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                            letterSpacing: 5,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Statistiques du jeu
                        if (game.gameMode == GameMode.solo)
                          _buildSoloStats(game)
                        else
                          _buildDuoStats(game),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Boutons d'action
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Bouton pour rejouer
                      ElevatedButton.icon(
                        onPressed: () {
                          game.resetGame();
                          game.startTimer();
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.replay, color: Theme.of(context).colorScheme.onPrimary),
                        label: Text(
                          'Rejouer',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          elevation: 5,
                          shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),

                      // Bouton pour revenir à l'accueil
                      ElevatedButton.icon(
                        onPressed: () {
                          // Réinitialiser le jeu et revenir à l'écran d'accueil
                          game.resetGame();
                          Navigator.popUntil(context, (route) => route.isFirst);
                        },
                        icon: Icon(Icons.home, color: Theme.of(context).colorScheme.onSecondary),
                        label: Text(
                          'Accueil',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          backgroundColor: Theme.of(context).colorScheme.secondary,
                          foregroundColor: Theme.of(context).colorScheme.onSecondary,
                          elevation: 5,
                          shadowColor: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSoloStats(GameModel game) {
    return Builder(
      builder: (context) => Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Niveau:',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              Text(
                _getDifficultyText(game.difficultyLevel),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tentatives:',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              Text(
                '${game.playerAttempts[1]?.length ?? 0} / ${game.maxAttempts}',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDuoStats(GameModel game) {
    final winner = game.getWinner();

    return Builder(
      builder: (context) => Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Niveau:',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              Text(
                _getDifficultyText(game.difficultyLevel),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${game.player1Name}:',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              Text(
                '${game.playerAttempts[1]?.length ?? 0} tentatives${(game.playerWon[1] ?? false) ? ' ✓' : ''}',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: winner == 1 ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${game.player2Name}:',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              Text(
                '${game.playerAttempts[2]?.length ?? 0} tentatives${(game.playerWon[2] ?? false) ? ' ✓' : ''}',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: winner == 2 ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getResultTitle(GameModel game) {
    if (game.gameMode == GameMode.solo) {
      if (game.playerWon[1] ?? false) {
        return 'Félicitations ${game.player1Name} !';
      } else {
        return 'Partie terminée !';
      }
    } else {
      final winner = game.getWinner();
      if (winner == null) {
        return 'Partie terminée !';
      } else if (winner == 0) {
        return 'Match nul !';
      } else if (winner == 1) {
        return '${game.player1Name} a gagné !';
      } else {
        return '${game.player2Name} a gagné !';
      }
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _getDifficultyText(DifficultyLevel level) {
    switch (level) {
      case DifficultyLevel.easy:
        return 'Facile';
      case DifficultyLevel.medium:
        return 'Moyen';
      case DifficultyLevel.hard:
        return 'Difficile';
    }
  }
}
