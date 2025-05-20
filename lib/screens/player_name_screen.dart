import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import '../main.dart';
import 'game_screen.dart';
import '../widgets/animated_mascots.dart';

class PlayerNameScreen extends StatefulWidget {
  final DifficultyLevel difficulty;
  final GameMode gameMode;

  const PlayerNameScreen({
    Key? key,
    required this.difficulty,
    required this.gameMode,
  }) : super(key: key);

  @override
  State<PlayerNameScreen> createState() => _PlayerNameScreenState();
}

class _PlayerNameScreenState extends State<PlayerNameScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _player1Controller = TextEditingController(text: "Joueur 1");
  final TextEditingController _player2Controller = TextEditingController(text: "Joueur 2");
  final _formKey = GlobalKey<FormState>();

  // Avatars disponibles (icônes de personnages militaires et héros en noir)
  final List<String> _avatars = [
    '🥷', '👮', '🦸', '🦹', '💂', '👨‍✈️'
  ];

  // Avatars sélectionnés
  String _player1Avatar = '🦸';
  String _player2Avatar = '🦹';

  // Animation pour les avatars
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    // Animation plus légère et moins fréquente pour améliorer les performances
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Démarrer l'animation une seule fois au lieu de la répéter
    _animationController.forward();
  }

  @override
  void dispose() {
    _player1Controller.dispose();
    _player2Controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Configuration des Joueurs',
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
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre
                    Text(
                      widget.gameMode == GameMode.solo
                          ? 'Entrez votre nom'
                          : 'Entrez les noms des joueurs',
                      style: GoogleFonts.righteous(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ).animate().fadeIn(duration: 0.5.seconds),

                    const SizedBox(height: 20),

                    // Champ pour le joueur 1
                    _buildPlayerNameField(
                      controller: _player1Controller,
                      label: 'Joueur 1',
                      icon: Icons.person,
                    ).animate().fadeIn(duration: 0.8.seconds).slideX(),

                    const SizedBox(height: 20),

                    // Champ pour le joueur 2 (uniquement en mode duo)
                    if (widget.gameMode == GameMode.duo)
                      _buildPlayerNameField(
                        controller: _player2Controller,
                        label: 'Joueur 2',
                        icon: Icons.person,
                      ).animate().fadeIn(duration: 1.1.seconds).slideX(),

                    const SizedBox(height: 30),

                    // Bouton pour commencer le jeu
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        child: TweenAnimationBuilder(
                          tween: Tween<double>(begin: 0.9, end: 1.0),
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.elasticOut,
                          builder: (context, scale, child) {
                            return Transform.scale(
                              scale: scale,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    // Configurer le jeu avec les paramètres choisis
                                    final gameModel = Provider.of<GameModel>(context, listen: false);
                                    gameModel.setGameParameters(
                                      difficulty: widget.difficulty,
                                      mode: widget.gameMode,
                                      player1: _player1Controller.text,
                                      player2: widget.gameMode == GameMode.duo
                                          ? _player2Controller.text
                                          : null,
                                      player1Avatar: _player1Avatar,
                                      player2Avatar: _player2Avatar,
                                    );

                                    // Démarrer le jeu
                                    gameModel.startTimer();

                                    // Naviguer vers l'écran de jeu
                                    Navigator.pushReplacement(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (_, __, ___) => const GameScreen(),
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
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20), // Plus grand
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                  foregroundColor: Colors.white,
                                  elevation: 12, // Plus d'élévation
                                  shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(40), // Plus arrondi
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.play_arrow, size: 32), // Icône plus grande
                                    const SizedBox(width: 15), // Plus d'espace
                                    Text(
                                      'COMMENCER',
                                      style: GoogleFonts.righteous(
                                        fontSize: 24, // Texte plus grand
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
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
                            );
                          },
                        ),
                      ),
                    ).animate().fadeIn(duration: 1.5.seconds),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerNameField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    // Déterminer si c'est le joueur 1 ou 2
    bool isPlayer1 = label.contains('1');
    String currentAvatar = isPlayer1 ? _player1Avatar : _player2Avatar;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre avec avatar actuel
          Row(
            children: [
              // Avatar actuel
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    currentAvatar,
                    style: const TextStyle(fontSize: 30),
                  ),
                ),
              ),

              const SizedBox(width: 15),

              // Informations du joueur
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.righteous(
                        fontSize: 22,
                        color: Theme.of(context).colorScheme.onBackground,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Choisissez un avatar et un nom',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Champ de saisie du nom - Agrandi
          Container(
            height: 70, // Hauteur fixe plus grande
            child: TextFormField(
              controller: controller,
              style: GoogleFonts.montserrat(
                fontSize: 20, // Texte plus grand
                color: Theme.of(context).colorScheme.onBackground,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.3),
                    offset: const Offset(1, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
              decoration: InputDecoration(
                labelText: 'Nom du joueur',
                labelStyle: GoogleFonts.montserrat(
                  color: Theme.of(context).colorScheme.onBackground,
                  fontSize: 18, // Étiquette plus grande
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(1, 1),
                      blurRadius: 1,
                    ),
                  ],
                ),
                prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.onBackground, size: 28), // Icône plus grande
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20), // Coins plus arrondis
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.5), width: 2), // Bordure plus visible
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 3), // Bordure plus épaisse
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Colors.redAccent, width: 2),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Colors.redAccent, width: 3),
                ),
                filled: true,
                fillColor: Colors.black.withOpacity(0.3), // Fond plus foncé pour meilleur contraste
                contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 20), // Plus d'espace interne
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer un nom';
                }
                return null;
              },
            ),
          ),

          const SizedBox(height: 15),

          // Titre pour la sélection d'avatar
          Text(
            'Choisissez un avatar',
            style: GoogleFonts.righteous(
              fontSize: 20, // Texte plus grand
              color: Theme.of(context).colorScheme.onBackground,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(1, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),

          const SizedBox(height: 15), // Plus d'espace

          // Grille d'avatars agrandie
          Container(
            height: 100, // Plus haut
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3), // Fond plus foncé
              borderRadius: BorderRadius.circular(20), // Coins plus arrondis
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(10),
              children: _avatars.map((avatar) {
                bool isSelected = isPlayer1
                    ? _player1Avatar == avatar
                    : _player2Avatar == avatar;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isPlayer1) {
                        _player1Avatar = avatar;
                      } else {
                        _player2Avatar = avatar;
                      }
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8), // Plus d'espace entre les avatars
                    width: 70, // Plus grand
                    height: 70, // Plus grand
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary.withOpacity(0.8)
                          : Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withOpacity(0.3),
                        width: isSelected ? 3 : 1, // Bordure plus épaisse
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                                blurRadius: 8,
                                spreadRadius: 2,
                              )
                            ]
                          : [],
                    ),
                    child: Center(
                      child: Text(
                        avatar,
                        style: TextStyle(
                          fontSize: 36, // Texte plus grand
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
