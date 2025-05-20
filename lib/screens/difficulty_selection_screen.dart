import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'dart:math' show pi, sin;
import '../main.dart';
import 'player_name_screen.dart';
import '../widgets/animated_mascots.dart';

class DifficultySelectionScreen extends StatefulWidget {
  const DifficultySelectionScreen({super.key});

  @override
  State<DifficultySelectionScreen> createState() => _DifficultySelectionScreenState();
}

class _DifficultySelectionScreenState extends State<DifficultySelectionScreen> {
  DifficultyLevel _selectedDifficulty = DifficultyLevel.medium;
  GameMode _selectedMode = GameMode.solo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Paramètres du jeu',
          style: Theme.of(context).textTheme.displayMedium,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Theme.of(context).appBarTheme.iconTheme?.color,
          onPressed: () => Navigator.pop(context),
        ),
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                // Astuce/explication du jeu
                Container(
                  margin: const EdgeInsets.only(bottom: 18),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Comment jouer ?',
                              style: GoogleFonts.righteous(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Devinez le nombre secret composé de chiffres tous différents.\n'
                              '• Un "Taureau" (🐂) : un chiffre bien placé.\n'
                              '• Un "Cheval" (🐎) : un chiffre présent mais mal placé.\n'
                              'Essayez de trouver le nombre en un minimum d\'essais !',
                              style: GoogleFonts.montserrat(
                                fontSize: 15,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Titre de la section difficulté avec animation
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: Text(
                    'Niveau de difficulté',
                    style: GoogleFonts.righteous(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ).animate().fadeIn(duration: 0.5.seconds).slideX(),

                const SizedBox(height: 30),

                // Options de difficulté avec animation améliorée - Centré
                Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    height: 180,
                    // Utiliser SingleChildScrollView pour permettre le défilement si nécessaire
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildDifficultyOption(
                            context,
                            DifficultyLevel.easy,
                            'Facile',
                            '3 chiffres',
                            Icons.sentiment_satisfied_alt,
                          ),
                          const SizedBox(width: 15),
                          _buildDifficultyOption(
                            context,
                            DifficultyLevel.medium,
                            'Moyen',
                            '4 chiffres',
                            Icons.sentiment_neutral,
                          ),
                          const SizedBox(width: 15),
                          _buildDifficultyOption(
                            context,
                            DifficultyLevel.hard,
                            'Difficile',
                            '5 chiffres',
                            Icons.sentiment_very_dissatisfied,
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 0.8.seconds).slideY(),

                const SizedBox(height: 40),

                // Titre de la section mode de jeu avec animation
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.secondary,
                      Theme.of(context).colorScheme.primary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: Text(
                    'Mode de jeu',
                    style: GoogleFonts.righteous(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ).animate().fadeIn(duration: 1.seconds).slideX(),

                const SizedBox(height: 30),

                // Options de mode de jeu avec animation améliorée
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildGameModeOption(
                      context,
                      GameMode.solo,
                      'Solo',
                      'Jouez seul',
                      Icons.person,
                    ),
                    _buildGameModeOption(
                      context,
                      GameMode.duo,
                      'Duo',
                      'Jouez à deux',
                      Icons.people,
                    ),
                  ],
                ).animate().fadeIn(duration: 1.3.seconds).slideY(),

                const SizedBox(height: 30),

                const SizedBox(height: 10),

                // Bouton pour continuer avec animation améliorée
                Center(
                  child: TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    duration: const Duration(seconds: 1),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Animation de pulsation avant navigation
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (_, __, ___) => PlayerNameScreen(
                                  difficulty: _selectedDifficulty,
                                  gameMode: _selectedMode,
                                ),
                                transitionsBuilder: (_, animation, __, child) {
                                  return SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(1, 0),
                                      end: Offset.zero,
                                    ).animate(CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeOutQuart,
                                    )),
                                    child: FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                          icon: const Icon(Icons.arrow_forward, size: 24),
                          label: Text(
                            'CONTINUER',
                            style: GoogleFonts.righteous(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }

  Widget _buildDifficultyOption(
    BuildContext context,
    DifficultyLevel difficulty,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final isSelected = _selectedDifficulty == difficulty;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDifficulty = difficulty;
        });
      },
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0, end: isSelected ? 1.0 : 0.0),
        duration: const Duration(milliseconds: 300),
        builder: (context, value, child) {
          return Transform.rotate(
            angle: isSelected ? value * 0.05 * sin(value * pi) : 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              // Taille adaptée selon la plateforme
              width: MediaQuery.of(context).size.width < 400 ? 100 : 120,
              height: MediaQuery.of(context).size.width < 400 ? 140 : 160,
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.8)
                    : Theme.of(context).colorScheme.surface.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.white.withOpacity(0.2),
                  width: isSelected ? 3 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
                          blurRadius: 15,
                          spreadRadius: 2,
                        )
                      ]
                    : [],
              ),
              child: Stack(
                children: [
                  if (isSelected)
                    Positioned(
                      right: 10,
                      top: 10,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          size: 15,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icône avec animation
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white
                                : Theme.of(context).colorScheme.surface,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            icon,
                            size: 40,
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 15),
                        // Titre
                        Text(
                          title,
                          style: GoogleFonts.righteous(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.5),
                                offset: const Offset(1, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        // Sous-titre
                        Text(
                          subtitle,
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                offset: const Offset(1, 1),
                                blurRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGameModeOption(
    BuildContext context,
    GameMode mode,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final isSelected = _selectedMode == mode;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMode = mode;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.secondary.withOpacity(0.8)
              : Theme.of(context).colorScheme.surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.secondary
                : Colors.white.withOpacity(0.2),
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.6),
                    blurRadius: 15,
                    spreadRadius: 2,
                  )
                ]
              : [],
        ),
        child: Stack(
          children: [
            // Effet de particules animées pour l'option sélectionnée
            if (isSelected)
              ...List.generate(5, (index) {
                return Positioned(
                  left: 20.0 * index,
                  top: 20.0 * (index % 3),
                  child: TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: Duration(milliseconds: 1000 + (index * 200)),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: (1 - value) * 0.7,
                        child: Transform.translate(
                          offset: Offset(0, -20 * value),
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),

            // Contenu principal
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icône avec animation
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white
                          : Theme.of(context).colorScheme.surface,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 45,
                      color: isSelected
                          ? Theme.of(context).colorScheme.secondary
                          : Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Titre
                  Text(
                    title,
                    style: GoogleFonts.righteous(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          offset: const Offset(1, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  // Sous-titre
                  Text(
                    subtitle,
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          offset: const Offset(1, 1),
                          blurRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Indicateur de sélection
            if (isSelected)
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    size: 15,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
