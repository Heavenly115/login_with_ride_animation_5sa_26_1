import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscureText = true;
  
  // Rive Controller y SMIs
  StateMachineController? _controller;
  SMIBool? _isChecking;
  SMIBool? _isHandsUp;
  SMITrigger? _trigSuccess;
  SMITrigger? _trigfail;

  // 1) Variables para FocusNode
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // 2) Listeners para reaccionar al foco
    _emailFocusNode.addListener(() {
      if (_emailFocusNode.hasFocus) {
        _isChecking?.change(true);  // Mira el texto si entro al email
        _isHandsUp?.change(false);  // Baja las manos si estaban arriba
      } else {
        _isChecking?.change(false); // Deja de mirar si salgo del email
      }
    });

    _passwordFocusNode.addListener(() {
      if (_passwordFocusNode.hasFocus) {
        _isHandsUp?.change(true);   // Se tapa los ojos al entrar a password
        _isChecking?.change(false); // Deja de mirar el email
      } else {
        _isHandsUp?.change(false);  // Se destapa los ojos al salir
      }
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
                height: 200,
                child: RiveAnimation.asset(
                  'assets/3645-7621-remix-of-login-machine.riv',
                  stateMachines: const ['Login Machine'],
                  onInit: (artboard) {
                    _controller = StateMachineController.fromArtboard(artboard, 'Login Machine');
                    if (_controller == null) return;
                    artboard.addController(_controller!);

                    _isChecking = _controller!.findSMI('isChecking');
                    _isHandsUp = _controller!.findSMI('isHandsUp');
                    _trigSuccess = _controller!.findSMI('istrigSuccess');
                    _trigfail = _controller!.findSMI('trigfail');
                  },
                ),
              ),
              const SizedBox(height: 10),
              
              // Campo de Email
              TextField(
                focusNode: _emailFocusNode, // 1.3) Asignar FocusNode
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Email',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 10),

              // Campo de Password
              TextField(
                focusNode: _passwordFocusNode, // Asignar FocusNode
                obscureText: _obscureText,
                decoration: InputDecoration(
                  hintText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),

              // Botón de ejemplo para disparar éxito/error
              ElevatedButton(
                onPressed: () {
                  // Aquí podrías disparar los triggers
                  _trigSuccess?.fire(); 
                },
                child: const Text('Iniciar Sesión'),
              ),
            ],
          ),
        ),
      ),
    );
    }
    
    // 1.4) Liberar los FocusNode para evitar fugas de memoria
    @override
    void dispose() {
      _emailFocusNode.dispose();
      _passwordFocusNode.dispose();
      _controller?.dispose();
      super.dispose();
  }
}