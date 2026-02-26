import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'dart:async'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscureText = true;

  // Controlador y Entradas (Inputs) de Rive
  StateMachineController? _controller;
  SMIBool? _isChecking;
  SMIBool? _isHandsUp;
  SMITrigger? _trigSuccess;
  SMITrigger? _trigFail;
  SMINumber? _numLook; 

  // Nodos de enfoque para detectar dónde hace clic el usuario
  final _emailFocusNode = FocusNode();
  final _passowrdFocusNode = FocusNode();

  Timer? _typingDebounce;

  @override
  void initState() {
    super.initState();
    
    // Escuchar cuando el usuario entra al campo de Email
    _emailFocusNode.addListener(() {
      if (_emailFocusNode.hasFocus) {
        _isHandsUp?.change(false); // Baja las manos
        _numLook?.value = 50.0;    // Centra la mirada
      }
    });

    // Escuchar cuando el usuario entra al campo de Password
    _passowrdFocusNode.addListener(() {
      // Sube las manos si tiene el foco, las baja si no
      _isHandsUp?.change(_passowrdFocusNode.hasFocus);
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              SizedBox(
                width: size.width,
                height: 250, // Un poco más de espacio para el oso
                child: RiveAnimation.asset(
                  'assets/3645-7621-remix-of-login-machine.riv', 
                  stateMachines: const ['Login Machine'],
                  onInit: (artboard) {
                    final controller = StateMachineController.fromArtboard(
                      artboard, 
                      'Login Machine'  
                    );

                    if (controller != null) {
                      artboard.addController(controller);
                      _controller = controller;
                      
                      // Vinculación segura de los inputs
                      _isChecking = controller.findSMI<SMIBool>('isChecking');
                      _isHandsUp = controller.findSMI<SMIBool>('isHandsUp');
                      _trigSuccess = controller.findSMI<SMITrigger>('trigSuccess');
                      _trigFail = controller.findSMI<SMITrigger>('trigFail');
                      _numLook = controller.findSMI<SMINumber>('numLook');
                    }
                  },
                ),
              ),

              const SizedBox(height: 18),

              // CAMPO EMAIL
              TextField(
                focusNode: _emailFocusNode,
                onChanged: (value) {
                  // Activa la mirada del oso hacia el texto
                  _isChecking?.change(true);

                  // Calcula la posición de los ojos (0 a 100)
                  final lookValue = (value.length / 80.0 * 100.0).clamp(0.0, 100.0);
                  _numLook?.value = lookValue;

                  // Si deja de escribir por 2 segundos, el oso deja de mirar fijamente
                  _typingDebounce?.cancel();
                  _typingDebounce = Timer(const Duration(seconds: 2), () {
                    if (!mounted) return;
                    _isChecking?.change(false); 
                  });
                },
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Email',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),

              const SizedBox(height: 15),

              // CAMPO PASSWORD
              TextField(
                focusNode: _passowrdFocusNode,
                onChanged: (value) {
                  // Mantiene las manos arriba mientras escribe la clave
                  _isHandsUp?.change(true);
                },
                obscureText: _obscureText,
                decoration: InputDecoration(
                  hintText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscureText = !_obscureText),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passowrdFocusNode.dispose();
    _typingDebounce?.cancel(); 
    super.dispose();
  }
}