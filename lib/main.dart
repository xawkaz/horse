import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'providers/theme_provider.dart';

// Import conditionnel pour la gestion de la fenêtre sur le web
// Nous utiliserons une approche différente pour éviter les erreurs sur mobile

// Utilisation de sin pour les animations
import 'dart:math' show sin;

// Import des écrans
import 'screens/difficulty_selection_screen.dart';
import 'screens/player_name_screen.dart';
import 'screens/game_screen.dart';
import 'screens/result_screen.dart';

// Enum pour les niveaux de difficulté
enum DifficultyLevel {
  easy,    // 3 chiffres
  medium,  // 4 chiffres
  hard     // 5 chiffres
}

// Enum pour les modes de jeu
enum GameMode {
  solo,
  duo
}

// Modèle pour la logique du jeu
class GameModel extends ChangeNotifier {
  // Paramètres du jeu
  DifficultyLevel difficultyLevel = DifficultyLevel.medium;
  GameMode gameMode = GameMode.solo;
  String player1Name = "Joueur 1";
  String player2Name = "Joueur 2";
  String player1Avatar = "🐂";
  String player2Avatar = "🐎";
  int currentPlayer = 1; // 1 ou 2

  // Données du jeu
  List<int> secretNumber = [];
  Map<int, List<Map<String, dynamic>>> playerAttempts = {
    1: [],
    2: []
  };
  int maxAttempts = 10;
  Map<int, bool> playerWon = {1: false, 2: false};

  // Timer
  final StopWatchTimer _stopWatchTimer = StopWatchTimer();
  int elapsedTimeInSeconds = 0;

  // Getters
  List<Map<String, dynamic>> get attempts => playerAttempts[currentPlayer] ?? [];
  bool get gameWon => playerWon[currentPlayer] ?? false;

  GameModel() {
    _stopWatchTimer.rawTime.listen((value) {
      elapsedTimeInSeconds = value ~/ 1000;
      notifyListeners();
    });
    generateSecretNumber();
  }

  @override
  void dispose() {
    _stopWatchTimer.dispose();
    super.dispose();
  }

  // Définir les paramètres du jeu
  void setGameParameters({
    required DifficultyLevel difficulty,
    required GameMode mode,
    String? player1,
    String? player2,
    String? player1Avatar,
    String? player2Avatar,
  }) {
    difficultyLevel = difficulty;
    gameMode = mode;
    if (player1 != null) player1Name = player1;
    if (player2 != null) player2Name = player2;
    if (player1Avatar != null) this.player1Avatar = player1Avatar;
    if (player2Avatar != null) this.player2Avatar = player2Avatar;
    resetGame();
  }

  // Obtenir la longueur du nombre secret en fonction de la difficulté
  int get secretNumberLength {
    switch (difficultyLevel) {
      case DifficultyLevel.easy:
        return 3;
      case DifficultyLevel.medium:
        return 4;
      case DifficultyLevel.hard:
        return 5;
    }
  }

  // Générer un nouveau nombre secret
  void generateSecretNumber() {
    secretNumber.clear();
    var rng = Random();
    while (secretNumber.length < secretNumberLength) {
      int digit = rng.nextInt(10);
      if (!secretNumber.contains(digit)) {
        secretNumber.add(digit);
      }
    }
  }

  // Démarrer le timer
  void startTimer() {
    _stopWatchTimer.onStartTimer();
  }

  // Arrêter le timer
  void stopTimer() {
    _stopWatchTimer.onStopTimer();
  }

  // Réinitialiser le timer
  void resetTimer() {
    _stopWatchTimer.onResetTimer();
  }

  // Changer de joueur (mode duo)
  void switchPlayer() {
    if (gameMode == GameMode.duo) {
      currentPlayer = currentPlayer == 1 ? 2 : 1;
      notifyListeners();
    }
  }

  // Soumettre une proposition
  void submitGuess(String guess) {
    if (guess.length != secretNumberLength ||
        playerAttempts[currentPlayer]!.length >= maxAttempts ||
        playerWon[currentPlayer]!) return;

    List<int> guessDigits = guess.split('').map((e) => int.parse(e)).toList();
    int bulls = 0;
    int cows = 0;

    for (int i = 0; i < secretNumberLength; i++) {
      if (guessDigits[i] == secretNumber[i]) {
        bulls++;
      } else if (secretNumber.contains(guessDigits[i])) {
        cows++;
      }
    }

    playerAttempts[currentPlayer]!.add({
      'guess': guess,
      'bulls': bulls,
      'cows': cows
    });

    if (bulls == secretNumberLength) {
      playerWon[currentPlayer] = true;
      stopTimer();
    }

    notifyListeners();
  }

  // Vérifier si le jeu est terminé
  bool isGameOver() {
    if (gameMode == GameMode.solo) {
      return (playerWon[1] ?? false) || (playerAttempts[1]?.length ?? 0) >= maxAttempts;
    } else {
      return ((playerWon[1] ?? false) || (playerWon[2] ?? false)) ||
             ((playerAttempts[1]?.length ?? 0) >= maxAttempts &&
              (playerAttempts[2]?.length ?? 0) >= maxAttempts);
    }
  }

  // Obtenir le gagnant (mode duo)
  int? getWinner() {
    if (gameMode == GameMode.solo) return (playerWon[1] ?? false) ? 1 : null;

    if ((playerWon[1] ?? false) && !(playerWon[2] ?? false)) return 1;
    if ((playerWon[2] ?? false) && !(playerWon[1] ?? false)) return 2;

    if ((playerWon[1] ?? false) && (playerWon[2] ?? false)) {
      // En cas d'égalité, le gagnant est celui qui a utilisé le moins d'essais
      if ((playerAttempts[1]?.length ?? 0) < (playerAttempts[2]?.length ?? 0)) return 1;
      if ((playerAttempts[2]?.length ?? 0) < (playerAttempts[1]?.length ?? 0)) return 2;
      return 0; // Match nul
    }

    return null; // Pas de gagnant
  }

  // Réinitialiser le jeu
  void resetGame() {
    playerAttempts = {1: [], 2: []};
    playerWon = {1: false, 2: false};
    currentPlayer = 1;
    generateSecretNumber();
    resetTimer();
    notifyListeners();
  }
}



void main() {
  // Définir les dimensions de la fenêtre pour Chrome (uniquement sur le web)
  if (kIsWeb) {
    // Nous utilisons une approche plus sûre qui fonctionne sur toutes les plateformes
    // Le code JavaScript est injecté via index.html au lieu d'être appelé directement
    // Voir le fichier web/index.html pour les détails
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameModel()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const ToroChevalApp(),
    ),
  );
}

class ToroChevalApp extends StatelessWidget {
  const ToroChevalApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Toro & Cheval',
      theme: themeProvider.lightTheme,
      darkTheme: themeProvider.darkTheme,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Écran d'accueil
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _bounceController;
  late AnimationController _rotateController;

  @override
  void initState() {
    super.initState();

    // Animation principale pour les mouvements de translation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    // Animation de rebond
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Animation de rotation légère
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _bounceController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Bouton de basculement de thème
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: Icon(
                themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: themeProvider.isDarkMode ? Colors.yellow : Colors.grey.shade800,
                size: 28,
              ),
              onPressed: () {
                themeProvider.toggleTheme();
              },
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              // Titre animé
              AnimatedTextKit(
                animatedTexts: [
                  ColorizeAnimatedText(
                    'TAUREAU & CHEVAL',
                    textStyle: Theme.of(context).textTheme.displayLarge!.copyWith(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                    colors: themeProvider.isDarkMode
                        ? const [
                            Color(0xFFE57373), // Rouge clair
                            Color(0xFFFFCDD2), // Rose très clair
                            Color(0xFF9FA8DA), // Bleu indigo clair
                            Color(0xFFE57373), // Rouge clair
                            Color(0xFFFFCDD2), // Rose très clair
                          ]
                        : const [
                            Color(0xFF2D3142), // Gris-bleu foncé
                            Color(0xFF4F5D75), // Gris-bleu moyen
                            Color(0xFFBF4342), // Rouge-brun du taureau
                            Color(0xFF2D3142), // Gris-bleu foncé
                            Color(0xFF4F5D75), // Gris-bleu moyen
                          ],
                    speed: const Duration(milliseconds: 300),
                  ),
                ],
                totalRepeatCount: 3,
                displayFullTextOnTap: true,
                isRepeatingAnimation: true,
              ).animate().fadeIn(duration: 1.seconds).slideY(),

              const SizedBox(height: 20),

              // Animations professionnelles du taureau et du cheval sans cadre - TRÈS GRANDES
              SizedBox(
                width: 700, // Plus large pour éviter le chevauchement
                height: 450,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Taureau animé
                    Positioned(
                      left: -80, // Plus à gauche
                      bottom: -30,
                      child: SizedBox(
                        width: 380, // Légèrement plus petit
                        height: 400,
                        child: Lottie.asset(
                          'assets/animations/toro.json',
                          animate: true,
                          repeat: true,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    // Cheval animé
                    Positioned(
                      right: -80, // Plus à droite
                      bottom: -30,
                      child: SizedBox(
                        width: 380, // Légèrement plus petit
                        height: 400,
                        child: Lottie.asset(
                          'assets/animations/cheval.json',
                          animate: true,
                          repeat: true,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Bouton pour commencer avec animation
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0.8, end: 1.0),
                duration: const Duration(seconds: 2),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) => const DifficultySelectionScreen(),
                            transitionsBuilder: (_, animation, __, child) {
                              return SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(1, 0),
                                  end: Offset.zero,
                                ).animate(CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeOutQuart,
                                )),
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.play_circle_fill, size: 30),
                          const SizedBox(width: 10),
                          Text(
                            'JOUER',
                            style: GoogleFonts.righteous(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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
            ),
        ),
      ),
    );
  }
}

