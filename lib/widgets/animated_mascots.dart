import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AnimatedMascots extends StatefulWidget {
  final double width;
  final double height;
  final bool isInteractive;

  const AnimatedMascots({
    Key? key,
    this.width = 300,
    this.height = 200,
    this.isInteractive = true,
  }) : super(key: key);

  @override
  State<AnimatedMascots> createState() => _AnimatedMascotsState();
}

class _AnimatedMascotsState extends State<AnimatedMascots> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isBullAnimating = true;
  bool _isHorseAnimating = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    // Démarrer l'animation automatiquement
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleBullAnimation() {
    setState(() {
      _isBullAnimating = !_isBullAnimating;
    });
  }

  void _toggleHorseAnimation() {
    setState(() {
      _isHorseAnimating = !_isHorseAnimating;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      child: Stack(
        children: [
          // Fond avec dégradé
          Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF2D3142).withOpacity(0.3), // Gris-bleu foncé
                  const Color(0xFF4F5D75).withOpacity(0.3), // Gris-bleu moyen
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
          ),

          // Taureau animé
          Positioned(
            left: -20,
            bottom: 0,
            child: GestureDetector(
              onTap: widget.isInteractive ? _toggleBullAnimation : null,
              child: SizedBox(
                width: widget.width * 0.5, // Légèrement plus petit
                height: widget.height,
                child: Lottie.asset(
                  'assets/animations/toro.json',
                  animate: _isBullAnimating,
                  repeat: true,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // Cheval animé
          Positioned(
            right: -20,
            bottom: 0,
            child: GestureDetector(
              onTap: widget.isInteractive ? _toggleHorseAnimation : null,
              child: SizedBox(
                width: widget.width * 0.5, // Légèrement plus petit
                height: widget.height,
                child: Lottie.asset(
                  'assets/animations/cheval.json',
                  animate: _isHorseAnimating,
                  repeat: true,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget pour afficher les mascottes avec animation automatique
class AutoAnimatedMascots extends StatelessWidget {
  final double width;
  final double height;
  final double scale;
  final bool withBackground;

  const AutoAnimatedMascots({
    Key? key,
    this.width = 350,
    this.height = 250,
    this.scale = 1.2,
    this.withBackground = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          // Taureau animé
          Positioned(
            left: -30,
            bottom: -10,
            child: Transform.scale(
              scale: scale,
              child: SizedBox(
                width: width * 0.5, // Légèrement plus petit
                height: height,
                child: Lottie.asset(
                  'assets/animations/toro.json',
                  animate: true,
                  repeat: true,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // Cheval animé
          Positioned(
            right: -30,
            bottom: -10,
            child: Transform.scale(
              scale: scale,
              child: SizedBox(
                width: width * 0.5, // Légèrement plus petit
                height: height,
                child: Lottie.asset(
                  'assets/animations/cheval.json',
                  animate: true,
                  repeat: true,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
