import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' show pi;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../main.dart';
import 'result_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameModel>(
      builder: (context, game, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(
              'TAUREAU & CHEVAL',
              style: GoogleFonts.righteous(
                color: Theme.of(context).appBarTheme.titleTextStyle?.color,
                fontWeight: FontWeight.bold,
                fontSize: 24,
                letterSpacing: 1.2,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true, // Centrer le titre
            actions: [
              // Affichage du chronomètre
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Center(
                  child: Text(
                    _formatTime(game.elapsedTimeInSeconds),
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).appBarTheme.titleTextStyle?.color,
                    ),
                  ),
                ),
              ),
            ],
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
            child: game.gameMode == GameMode.duo
                ? _buildDuoModeLayout(game, context)
                : _buildSoloModeLayout(game, context),
          ),
        );
      },
    );
  }

  Widget _buildSoloModeLayout(GameModel game, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Informations du joueur
          Text(
            game.player1Name,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ).animate().fadeIn(duration: 0.5.seconds),

          const SizedBox(height: 10),

          // Niveau de difficulté
          Text(
            'Niveau: ${_getDifficultyText(game.difficultyLevel)}',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
            ),
          ),

          const SizedBox(height: 20),

          // Champ de saisie
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            style: GoogleFonts.poppins(
              fontSize: 20,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            decoration: InputDecoration(
              labelText: 'Entrez ${game.secretNumberLength} chiffres',
              labelStyle: Theme.of(context).inputDecorationTheme.labelStyle,
              enabledBorder: Theme.of(context).inputDecorationTheme.border as OutlineInputBorder?,
              focusedBorder: Theme.of(context).inputDecorationTheme.focusedBorder as OutlineInputBorder?,
              filled: true,
              fillColor: Theme.of(context).inputDecorationTheme.fillColor,
              suffixIcon: IconButton(
                icon: Icon(Icons.send, color: Theme.of(context).colorScheme.onSurface),
                onPressed: () => _submitGuess(game),
              ),
            ),
            keyboardType: TextInputType.number,
            maxLength: game.secretNumberLength,
            onSubmitted: (_) => _submitGuess(game),
          ).animate().fadeIn(duration: 0.8.seconds),

          const SizedBox(height: 10),

          // Clavier numérique personnalisé uniquement sur le web
          if (shouldUseCustomKeyboard(game))
            _buildNumericKeyboard(game),

          const SizedBox(height: 20),

          // Liste des tentatives
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListView.builder(
                itemCount: game.attempts.length,
                itemBuilder: (context, index) {
                  var attempt = game.attempts[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(
                        color: attempt['bulls'] > 0
                            ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          // Numéro de l'essai
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: GoogleFonts.righteous(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),

                          // Nombre deviné
                          Text(
                            attempt['guess'],
                            style: GoogleFonts.righteous(
                              fontSize: 22,
                              color: Theme.of(context).colorScheme.onBackground,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),

                          const Spacer(),

                          // Résultats avec animations
                          Row(
                            children: [
                              // Taureaux (bulls)
                              TweenAnimationBuilder(
                                tween: Tween<double>(begin: 0.5, end: 1.0),
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.elasticOut,
                                builder: (context, value, child) {
                                  return Transform.scale(
                                    scale: value,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primary,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          const Text(
                                            '🐂',
                                            style: TextStyle(
                                              fontSize: 24,
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            '${attempt['bulls']}',
                                            style: GoogleFonts.righteous(
                                              fontSize: 20,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(width: 10),

                              // Chevaux (cows)
                              TweenAnimationBuilder(
                                tween: Tween<double>(begin: 0.5, end: 1.0),
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.elasticOut,
                                builder: (context, value, child) {
                                  return Transform.scale(
                                    scale: value,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.secondary,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          const Text(
                                            '🐎',
                                            style: TextStyle(
                                              fontSize: 24,
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            '${attempt['cows']}',
                                            style: GoogleFonts.righteous(
                                              fontSize: 20,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(duration: 0.3.seconds).slideX();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDuoModeLayout(GameModel game, BuildContext context) {
    // Utiliser LayoutBuilder pour adapter la taille des éléments
    return LayoutBuilder(
      builder: (context, constraints) {
        // Déterminer l'orientation de l'écran
        final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

        // Forcer le mode paysage si la fenêtre est assez large
        final forceLandscape = constraints.maxWidth >= 480;

        if (isLandscape || forceLandscape) {
          // Disposition horizontale pour les écrans larges (ordinateurs, tablettes)
          return Row(
            children: [
              // Zone du joueur 1
              Expanded(
                child: Container(
                  // Définir une largeur fixe pour éviter les débordements
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth / 2,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color: const Color(0xFF533483).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Theme.of(context).colorScheme.primary.withOpacity(0.8),
                        Theme.of(context).colorScheme.primary.withOpacity(0.6),
                      ],
                    ),
                  ),
                  child: _buildPlayerArea(
                    game,
                    1,
                    game.player1Name,
                    game.currentPlayer == 1,
                  ),
                ),
              ),

              // Zone du joueur 2
              Expanded(
                child: Container(
                  // Définir une largeur fixe pour éviter les débordements
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth / 2,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Theme.of(context).colorScheme.secondary.withOpacity(0.8),
                        Theme.of(context).colorScheme.secondary.withOpacity(0.6),
                      ],
                    ),
                  ),
                  child: _buildPlayerArea(
                    game,
                    2,
                    game.player2Name,
                    game.currentPlayer == 2,
                  ),
                ),
              ),
            ],
          );
        } else {
          // Disposition verticale pour les écrans étroits (téléphones)
          // Les joueurs sont face à face, donc le joueur 2 est retourné
          return Column(
            children: [
              // Zone du joueur 1 (en haut)
              Expanded(
                child: Container(
                  // Définir une hauteur fixe pour éviter les débordements
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight / 2 - 18, // Moitié de l'écran moins la moitié du séparateur
                    maxHeight: constraints.maxHeight / 2 - 18,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: const Color(0xFF533483).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF2D3142).withOpacity(0.9), // Gris-bleu foncé de l'image
                        const Color(0xFF4F5D75).withOpacity(0.8), // Gris-bleu moyen de l'image
                      ],
                    ),
                  ),
                  child: _buildPlayerArea(
                    game,
                    1,
                    game.player1Name,
                    game.currentPlayer == 1,
                    isRotated: false,
                  ),
                ),
              ),

          // Séparateur avec indication du joueur actif (design amélioré)
          Container(
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  const Color(0xFFE94560), // Rouge vif
                  const Color(0xFFE94560).withOpacity(0.8), // Rouge vif plus transparent
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 5,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Avatar du joueur actif avec animation subtile
                  TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0.9, end: 1.0),
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeInOut,
                    builder: (context, scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 3,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              game.currentPlayer == 1 ? game.player1Avatar : game.player2Avatar,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  // Nom du joueur actif
                  Text(
                    'Tour de ${game.currentPlayer == 1 ? game.player1Name : game.player2Name}',
                    style: GoogleFonts.righteous(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onBackground,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          offset: const Offset(1, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Zone du joueur 2 (en bas)
          Expanded(
            child: Container(
              // Sur mobile, ne pas faire de rotation pour faciliter le passage du téléphone
              // Sur web, garder la rotation pour l'effet face à face
              child: isMobilePlatform()
                  ? Container(
                      // Définir une hauteur fixe pour éviter les débordements
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight / 2 - 18, // Moitié de l'écran moins la moitié du séparateur
                        maxHeight: constraints.maxHeight / 2 - 18,
                        // Limiter la largeur pour éviter les débordements horizontaux
                        maxWidth: constraints.maxWidth,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Theme.of(context).colorScheme.secondary.withOpacity(0.9),
                            Theme.of(context).colorScheme.secondary.withOpacity(0.7),
                          ],
                        ),
                      ),
                      child: _buildPlayerArea(
                        game,
                        2,
                        game.player2Name,
                        game.currentPlayer == 2,
                        isRotated: false,
                        isCompact: true, // Mode compact pour économiser de l'espace
                      ),
                    )
                  : RotatedBox(
                      quarterTurns: 2, // Rotation de 180 degrés (plus efficace que Transform.rotate)
                      child: Container(
                        // Définir une hauteur fixe pour éviter les débordements
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight / 2 - 18, // Moitié de l'écran moins la moitié du séparateur
                          maxHeight: constraints.maxHeight / 2 - 18,
                          // Limiter la largeur pour éviter les débordements horizontaux
                          maxWidth: constraints.maxWidth,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              const Color(0xFF2D3142).withOpacity(0.9), // Gris-bleu foncé de l'image
                              const Color(0xFF4F5D75).withOpacity(0.8), // Gris-bleu moyen de l'image
                            ],
                          ),
                        ),
                        child: _buildPlayerArea(
                          game,
                          2,
                          game.player2Name,
                          game.currentPlayer == 2,
                          isRotated: false, // Pas besoin de rotation ici car le conteneur parent est déjà retourné
                          isCompact: true, // Mode compact pour économiser de l'espace
                        ),
                      ),
                    ),
            ),
          ),
        ],
      );
    }
      });
  }

  Widget _buildPlayerArea(
    GameModel game,
    int playerNumber,
    String playerName,
    bool isActive, {
    bool isRotated = false,
    bool isCompact = false,
  }) {
    // Récupérer les tentatives du joueur
    final playerAttempts = game.playerAttempts[playerNumber] ?? [];
    final playerWon = game.playerWon[playerNumber] ?? false;

    // Créer le contenu du joueur avec une hauteur fixe
    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      // Réduire l'espacement en mode compact
      mainAxisAlignment: isCompact ? MainAxisAlignment.start : MainAxisAlignment.center,
      children: [
        // Nom du joueur avec badge indiquant le tour actif et avatar (design amélioré)
        Container(
          padding: EdgeInsets.symmetric(
            vertical: isCompact ? 4 : 6,
            horizontal: isCompact ? 8 : 12
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isActive
                  ? [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.tertiary] // Dégradé plus vif pour le joueur actif
                  : [Theme.of(context).colorScheme.primary.withOpacity(0.6), Theme.of(context).colorScheme.tertiary.withOpacity(0.6)], // Plus terne pour le joueur inactif
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: const Color(0xFF533483).withOpacity(0.3),
                      blurRadius: 5,
                      spreadRadius: 0,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Avatar du joueur avec effet de brillance
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: isActive ? Colors.white : Colors.white54,
                    width: isActive ? 2 : 1,
                  ),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.3),
                            blurRadius: 5,
                            spreadRadius: 0,
                          )
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    playerNumber == 1 ? game.player1Avatar : game.player2Avatar,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Nom du joueur avec ombre
              Text(
                playerName,
                style: GoogleFonts.righteous(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onBackground,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),

              // Badge "Tour actif" avec animation
              if (isActive)
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0.9, end: 1.0),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeInOut,
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE94560), // Rouge vif
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 2,
                              spreadRadius: 0,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Text(
                          'Tour actif',
                          style: GoogleFonts.montserrat(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),

        SizedBox(height: isCompact ? 3 : 6),

        // Liste des tentatives (maintenant en haut)
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListView.builder(
              itemCount: playerAttempts.length,
              itemBuilder: (context, index) {
                var attempt = playerAttempts[index];
                return LayoutBuilder(
                  builder: (context, constraints) {
                    // Adapter la taille en fonction de la largeur disponible
                    final bool isNarrow = constraints.maxWidth < 300;
                    final double fontSize = isNarrow ? 18 : 20;
                    final double iconSize = isNarrow ? 16 : 18;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                      color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
                      elevation: 2, // Réduire l'élévation pour de meilleures performances
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: attempt['bulls'] > 0
                              ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
                              : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                        child: Row(
                          children: [
                            // Numéro de l'essai
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: GoogleFonts.righteous(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),

                            // Nombre deviné
                            Text(
                              attempt['guess'],
                              style: GoogleFonts.righteous(
                                fontSize: fontSize,
                                color: Theme.of(context).colorScheme.onBackground,
                                fontWeight: FontWeight.bold,
                                letterSpacing: isNarrow ? 1 : 2,
                              ),
                            ),

                            const Spacer(),

                            // Résultats simplifiés
                            Row(
                              children: [
                                // Taureaux (bulls)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '🐂',
                                        style: TextStyle(
                                          fontSize: iconSize,
                                        ),
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        '${attempt['bulls']}',
                                        style: GoogleFonts.righteous(
                                          fontSize: 16,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 6),

                                // Chevaux (cows)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.secondary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '🐎',
                                        style: TextStyle(
                                          fontSize: iconSize,
                                        ),
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        '${attempt['cows']}',
                                        style: GoogleFonts.righteous(
                                          fontSize: 16,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                );
              },
            ),
          ),
        ),

        // Message de victoire (simplifié)
        if (playerWon)
          Container(
            margin: EdgeInsets.symmetric(vertical: isCompact ? 4 : 8),
            padding: EdgeInsets.symmetric(vertical: isCompact ? 4 : 8, horizontal: isCompact ? 8 : 12),
            decoration: BoxDecoration(
              color: Colors.green.shade600,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.emoji_events,
                  color: Colors.amber,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Victoire !',
                  style: GoogleFonts.righteous(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

        // Zone de saisie et clavier (maintenant en bas)
        if (isActive && !playerWon) ...[
          SizedBox(height: 2), // Espace minimal

          // Champ de saisie (adapté selon le mode de jeu)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Titre du champ avec indication du mode de saisie
                Text(
                  isMobilePlatform()
                      ? 'Utilisez le clavier du téléphone'
                      : (game.gameMode == GameMode.duo
                          ? 'Saisissez votre nombre'
                          : 'Votre nombre'),
                  style: GoogleFonts.righteous(
                    fontSize: 18, // Plus grand
                    color: Theme.of(context).colorScheme.onBackground, // Texte blanc pour tous les modes
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.6),
                        offset: const Offset(1, 1),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 2),

                // Champ de saisie adapté au mode de jeu
                LayoutBuilder(
                  builder: (context, constraints) {
                    // Calculer la taille du texte en fonction de la largeur disponible
                    final double fontSize = constraints.maxWidth < 300 ? 20 : 24;
                    final double letterSpacing = constraints.maxWidth < 300 ? 6 : 8;

                    return Container(
                      height: isMobilePlatform() ? 70 : 60, // Encore plus grand
                      // Limiter la largeur pour éviter les débordements
                      width: constraints.maxWidth,
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF333333) // Gris foncé (mode sombre)
                            : const Color(0xFFE0E0E0), // Gris clair (mode clair)
                        borderRadius: BorderRadius.circular(isMobilePlatform() ? 12 : 8),
                        border: Border.all(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF2C2C2C) // Bordure gris foncé (mode sombre)
                              : const Color(0xFFE5E7EB), // Bordure gris clair (mode clair)
                          width: isMobilePlatform() ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.black.withOpacity(0.3)
                                : Colors.black.withOpacity(0.1),
                            blurRadius: isMobilePlatform() ? 8 : 4,
                            spreadRadius: isMobilePlatform() ? 1 : 0,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Champ de texte
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              focusNode: _focusNode,
                              style: GoogleFonts.righteous(
                                fontSize: isMobilePlatform() ? fontSize * 1.5 : fontSize * 1.3, // Beaucoup plus grand
                                color: Theme.of(context).colorScheme.onBackground, // Texte blanc pour tous les modes
                                letterSpacing: letterSpacing,
                                fontWeight: FontWeight.w900, // Extra bold pour plus de visibilité
                                // Ajouter une ombre au texte pour le rendre plus lisible
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.8),
                                    offset: const Offset(2, 2),
                                    blurRadius: 4,
                                  ),
                                  Shadow(
                                    color: Colors.blue.withOpacity(0.5),
                                    offset: const Offset(-1, -1),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                hintText: isMobilePlatform()
                                    ? 'Tapez ${game.secretNumberLength} chiffres différents'
                                    : (game.gameMode == GameMode.duo
                                        ? '${game.secretNumberLength} chiffres différents'
                                        : List.filled(game.secretNumberLength, '?').join(' ')),
                                hintStyle: GoogleFonts.righteous(
                                  fontSize: isMobilePlatform()
                                      ? (game.gameMode == GameMode.duo ? fontSize * 0.7 : fontSize * 1.1)
                                      : (game.gameMode == GameMode.duo ? fontSize * 0.6 : fontSize),
                                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.8), // Texte blanc plus visible pour tous les modes
                                  letterSpacing: game.gameMode == GameMode.duo ? 1 : letterSpacing,
                                  fontWeight: FontWeight.w600,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.5),
                                      offset: const Offset(0.5, 0.5),
                                      blurRadius: 1,
                                    ),
                                  ],
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: isMobilePlatform() ? 12 : 8),
                                isDense: true,
                              ),
                              keyboardType: isMobilePlatform()
                                  ? TextInputType.number // Utiliser le clavier numérique du téléphone sur mobile
                                  : TextInputType.none,
                              maxLength: game.secretNumberLength,
                              showCursor: true,
                              readOnly: !isMobilePlatform(), // Permettre la saisie directe uniquement sur mobile
                              autofocus: isMobilePlatform(), // Ouvrir automatiquement le clavier sur mobile
                              // Forcer l'utilisation du clavier du téléphone sur mobile
                              enableInteractiveSelection: isMobilePlatform(),
                              onSubmitted: (_) => _submitGuess(game),
                              buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                            ),
                          ),

                          // Bouton de validation avec design amélioré
                          Material(
                            color: Colors.transparent,
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(9),
                              bottomRight: Radius.circular(9),
                            ),
                            child: Container(
                              width: isMobilePlatform() ? 60 : 50, // Plus large
                              height: isMobilePlatform() ? 70 : 60, // Plus haut
                              decoration: BoxDecoration(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? const Color(0xFF60A5FA) // Bleu clair (mode sombre)
                                    : const Color(0xFF3B82F6), // Bleu (mode clair)
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? const Color(0xFF60A5FA).withOpacity(0.4) // Bleu clair (mode sombre)
                                        : const Color(0xFF3B82F6).withOpacity(0.4), // Bleu (mode clair)
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                                border: Border.all(
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? const Color(0xFF2C2C2C) // Bordure gris foncé (mode sombre)
                                      : const Color(0xFFE5E7EB), // Bordure gris clair (mode clair)
                                  width: 1,
                                ),
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(9),
                                  bottomRight: Radius.circular(9),
                                ),
                              ),
                              child: InkWell(
                                onTap: () => _submitGuess(game),
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(9),
                                  bottomRight: Radius.circular(9),
                                ),
                                child: Center(
                                  child: Icon(
                                    game.gameMode == GameMode.duo && isMobilePlatform() ? Icons.send : Icons.check,
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.black // Icône noire en mode sombre
                                        : Colors.white, // Icône blanche en mode clair
                                    size: isMobilePlatform() ? 32 : 26, // Encore plus grande
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.6),
                                        offset: const Offset(1, 1),
                                        blurRadius: 3,
                                      ),
                                      Shadow(
                                        color: Theme.of(context).brightness == Brightness.dark
                                            ? Colors.white.withOpacity(0.3)
                                            : Colors.black.withOpacity(0.3),
                                        offset: const Offset(-1, -1),
                                        blurRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                ),
              ],
            ),
          ),

          // Afficher le clavier numérique selon les conditions
          if (shouldUseCustomKeyboard(game)) ...[
            SizedBox(height: 2), // Espace minimal
            _buildNumericKeyboard(game),
          ],
        ],
      ],
    );

    // Appliquer le padding et retourner le contenu
    return Padding(
      padding: const EdgeInsets.all(2.0), // Marge minimale
      child: content,
    );

  }

  Widget _buildNumericKeyboard(GameModel game) {
    // Clavier adapté à la taille de l'écran
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculer la taille des boutons en fonction de la largeur disponible
        // Sur Chrome, utiliser des boutons plus grands
        final double buttonSize = kIsWeb
            ? (constraints.maxWidth < 300 ? 50 : 55) // Boutons plus grands
            : (constraints.maxWidth < 300 ? 35 : 40); // Plus grands sur mobile aussi
        final double spacing = kIsWeb
            ? (constraints.maxWidth < 300 ? 6 : 8) // Espacement
            : (constraints.maxWidth < 300 ? 2 : 3); // Espacement sur mobile aussi

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Première ligne: 1, 2, 3, 4, 5
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildKeyboardButton('1', game, size: buttonSize),
                  SizedBox(width: spacing),
                  _buildKeyboardButton('2', game, size: buttonSize),
                  SizedBox(width: spacing),
                  _buildKeyboardButton('3', game, size: buttonSize),
                  SizedBox(width: spacing),
                  _buildKeyboardButton('4', game, size: buttonSize),
                  SizedBox(width: spacing),
                  _buildKeyboardButton('5', game, size: buttonSize),
                ],
              ),
              SizedBox(height: spacing),

              // Deuxième ligne: 6, 7, 8, 9, 0, ⌫
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildKeyboardButton('6', game, size: buttonSize),
                  SizedBox(width: spacing),
                  _buildKeyboardButton('7', game, size: buttonSize),
                  SizedBox(width: spacing),
                  _buildKeyboardButton('8', game, size: buttonSize),
                  SizedBox(width: spacing),
                  _buildKeyboardButton('9', game, size: buttonSize),
                  SizedBox(width: spacing),
                  _buildKeyboardButton('0', game, size: buttonSize),
                  SizedBox(width: spacing),
                  _buildKeyboardButton('⌫', game, isDelete: true, size: buttonSize),
                ],
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildKeyboardButton(String value, GameModel game, {bool isDelete = false, required double size}) {
    // Vérifier si le chiffre est déjà utilisé
    final bool isUsed = !isDelete && _controller.text.contains(value);

    // Obtenir le thème actuel
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Fonction pour gérer l'appui sur un bouton
    void handleTap() {
      if (isDelete) {
        if (_controller.text.isNotEmpty) {
          _controller.text = _controller.text.substring(0, _controller.text.length - 1);
        }
      } else if (!isUsed) {
        if (_controller.text.length < game.secretNumberLength) {
          _controller.text += value;
        }
      }
      _focusNode.requestFocus();
    }

    // Utiliser un bouton avec design amélioré
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDelete
                  ? Theme.of(context).brightness == Brightness.dark
                      ? [
                          const Color(0xFFF87171), // Rouge clair (mode sombre)
                          const Color(0xFFEF4444), // Rouge (mode sombre)
                        ]
                      : [
                          const Color(0xFFEF4444), // Rouge (mode clair)
                          const Color(0xFFDC2626), // Rouge foncé (mode clair)
                        ]
                  : isUsed
                      ? Theme.of(context).brightness == Brightness.dark
                          ? [
                              const Color(0xFF2C2C2C), // Gris foncé (mode sombre)
                              const Color(0xFF1E1E1E), // Gris très foncé (mode sombre)
                            ]
                          : [
                              const Color(0xFFE5E7EB), // Gris clair (mode clair)
                              const Color(0xFFD1D5DB), // Gris plus clair (mode clair)
                            ]
                      : Theme.of(context).brightness == Brightness.dark
                          ? [
                              const Color(0xFF60A5FA), // Bleu clair (mode sombre)
                              const Color(0xFF3B82F6), // Bleu (mode sombre)
                            ]
                          : [
                              const Color(0xFF3B82F6), // Bleu (mode clair)
                              const Color(0xFF2563EB), // Bleu foncé (mode clair)
                            ],
            ),
            borderRadius: BorderRadius.circular(kIsWeb ? size / 4 : size / 2), // Coins moins arrondis sur le web
            boxShadow: isUsed
                ? []
                : kIsWeb
                    ? [
                        // Ombre plus prononcée sur le web
                        BoxShadow(
                          color: isDelete
                              ? Theme.of(context).brightness == Brightness.dark
                                  ? const Color(0xFFF87171).withOpacity(0.5) // Rouge clair (mode sombre)
                                  : const Color(0xFFEF4444).withOpacity(0.5) // Rouge (mode clair)
                              : Theme.of(context).brightness == Brightness.dark
                                  ? const Color(0xFF60A5FA).withOpacity(0.5) // Bleu clair (mode sombre)
                                  : const Color(0xFF3B82F6).withOpacity(0.5), // Bleu (mode clair)
                          blurRadius: 8,
                          spreadRadius: 1,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4,
                          spreadRadius: 0,
                          offset: const Offset(0, 2),
                        ),
                      ],
          ),
          child: InkWell(
            onTap: isUsed && !isDelete ? null : handleTap,
            borderRadius: BorderRadius.circular(size / 2),
            child: Center(
              child: isDelete
                  ? Icon(
                      Icons.backspace_rounded,
                      color: Colors.white, // Icône blanche pour tous les modes
                      size: size * 0.5, // Plus petite
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.7),
                          offset: const Offset(2, 2),
                          blurRadius: 3,
                        ),
                        Shadow(
                          color: Colors.blue.withOpacity(0.5),
                          offset: const Offset(-1, -1),
                          blurRadius: 2,
                        ),
                      ],
                    )
                  : Text(
                      value,
                      style: GoogleFonts.righteous(
                        fontSize: kIsWeb ? size * 0.55 : size * 0.45, // Texte encore plus petit
                        fontWeight: FontWeight.bold,
                        color: isUsed ? Colors.white.withOpacity(0.5) : Colors.white, // Texte blanc pour tous les modes
                        letterSpacing: 0.5, // Meilleure lisibilité
                        shadows: isUsed
                            ? []
                            : kIsWeb
                                ? [
                                    // Ombre plus prononcée sur le web
                                    Shadow(
                                      color: Colors.black.withOpacity(0.7),
                                      offset: const Offset(2, 2),
                                      blurRadius: 4,
                                    ),
                                    Shadow(
                                      color: Colors.blue.withOpacity(0.5),
                                      offset: const Offset(-1, -1),
                                      blurRadius: 2,
                                    ),
                                  ]
                                : [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.6),
                                      offset: const Offset(1, 1),
                                      blurRadius: 3,
                                    ),
                                    Shadow(
                                      color: Colors.blue.withOpacity(0.4),
                                      offset: const Offset(-0.5, -0.5),
                                      blurRadius: 1,
                                    ),
                                  ],
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  void _submitGuess(GameModel game) {
    String guess = _controller.text;

    // Vérifier que la saisie est valide
    if (guess.length == game.secretNumberLength &&
        RegExp(r'^\d+$').hasMatch(guess)) {

      // Vérifier que tous les chiffres sont différents
      final digits = guess.split('');
      final uniqueDigits = digits.toSet();

      if (uniqueDigits.length == digits.length) {
        game.submitGuess(guess);
        _controller.clear();

        // Vérifier si le jeu est terminé
        if (game.isGameOver()) {
          // Naviguer vers l'écran de résultat
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const ResultScreen(),
              transitionsBuilder: (_, animation, __, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                );
              },
            ),
          );
        } else if (game.gameMode == GameMode.duo && !game.gameWon) {
          // Changer de joueur en mode duo
          game.switchPlayer();

          // En mode duo, masquer le clavier du téléphone après la soumission
          if (game.gameMode == GameMode.duo) {
            FocusScope.of(context).unfocus();

            // Sur mobile, afficher une alerte centrale animée pour indiquer de passer le téléphone
            if (isMobilePlatform()) {
              // Utiliser un overlay pour afficher l'alerte au centre de l'écran
              showDialog(
                context: context,
                barrierDismissible: false, // L'utilisateur doit attendre que l'alerte disparaisse
                builder: (BuildContext context) {
                  // Fermer automatiquement après 2 secondes
                  Future.delayed(const Duration(seconds: 2), () {
                    Navigator.of(context).pop();
                  });

                  // Créer une alerte animée
                  return TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          backgroundColor: Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF7986CB) // Bleu indigo moyen en mode sombre
                              : const Color(0xFF2D3142), // Gris-bleu foncé en mode clair
                          contentPadding: const EdgeInsets.all(20),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Icône animée
                              TweenAnimationBuilder(
                                tween: Tween<double>(begin: 0.0, end: 1.0),
                                duration: const Duration(milliseconds: 800),
                                curve: Curves.elasticOut,
                                builder: (context, value, child) {
                                  return Transform.scale(
                                    scale: value,
                                    child: Icon(
                                      Icons.swap_horiz_rounded,
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? const Color(0xFF9FA8DA) // Bleu indigo clair en mode sombre
                                          : const Color(0xFFEAE8DC), // Blanc cassé du cheval en mode clair
                                      size: 50,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 15),
                              // Message avec animation de fondu
                              TweenAnimationBuilder(
                                tween: Tween<double>(begin: 0.0, end: 1.0),
                                duration: const Duration(milliseconds: 800),
                                curve: Curves.easeInOut,
                                builder: (context, value, child) {
                                  return Opacity(
                                    opacity: value,
                                    child: Text(
                                      'Passez le téléphone à\n${game.currentPlayer == 1 ? game.player1Name : game.player2Name}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).brightness == Brightness.dark
                                            ? Colors.black // Texte noir en mode sombre
                                            : Colors.white, // Texte blanc en mode clair
                                        letterSpacing: 0.5,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            }
          }
        }
      } else {
        // Afficher un message d'erreur si les chiffres ne sont pas tous différents
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Les chiffres doivent être tous différents',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } else if (game.gameMode == GameMode.duo && guess.isNotEmpty && guess.length != game.secretNumberLength) {
      // En mode duo, afficher un message si le nombre n'a pas la bonne longueur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Entrez un nombre à ${game.secretNumberLength} chiffres',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.orange,
        ),
      );
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

  // Fonction pour détecter si nous sommes sur mobile
  bool isMobilePlatform() {
    if (kIsWeb) {
      return false; // Sur le web, on considère qu'on n'est pas sur mobile
    }
    try {
      // Vérifier si nous sommes sur Android ou iOS
      return Platform.isAndroid || Platform.isIOS;
    } catch (e) {
      // Si nous ne pouvons pas détecter la plateforme, nous supposons que ce n'est pas le web
      // donc c'est probablement un appareil mobile
      return true;
    }
  }

  // Fonction pour déterminer si on doit utiliser le clavier personnalisé
  bool shouldUseCustomKeyboard(GameModel game) {
    // Sur le web (Chrome), toujours utiliser le clavier personnalisé, quel que soit le mode
    if (kIsWeb) {
      return true;
    }

    // Sur mobile ou toute autre plateforme, ne JAMAIS utiliser le clavier personnalisé
    return false;
  }
}
