import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'dart:async'; //3.1 IMPORTA EL TIEMPO/TIMER

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //Controlar para mostra o ocultar la contraseña
  bool _obscureText = true;

  //Crear el cerebro de la animacion
  StateMachineController? _controller;
  //SMI: State Machine Input
  SMIBool? _isChecking;
  SMIBool? _isHandsUp;
  SMITrigger? _trigSuccess;
  SMITrigger? _trigFail;

  //2.1 VARIABLE PARA EL RECORRIDO DE LA MIRADA
  SMINumber? _numLook; 


  //1.1 CREAR VARIABLES PARA FOCUSNODE
  final _emailFocusNode = FocusNode();
  final _passowrdFocusNode = FocusNode();

  //3.2 TIMER PATA DETENER MIRAD AL DEJAR DE ESCRIBIR
  Timer? _typingDebounce;

  //4.1 CREAR LOS CONTROLES(PARA MANIPUALAR EL TEXTO ESCRITO)
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

   // 4.2 Errores para mostrar en la UI
  String? emailError;
  String? passError;

  // 4.3 Validadores
  bool isValidEmail(String email) {
    final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return re.hasMatch(email);
  }

  bool isValidPassword(String pass) {
    // mínimo 8, una mayúscula, una minúscula, un dígito y un especial
    final re = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$',
    );
    return re.hasMatch(pass);
  }

  // 4.4 Acción al botón
  void _onLogin() {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;

    // Recalcular errores
    final eError = isValidEmail(email) ? null : 'Email inválido';
    final pError =
        isValidPassword(pass)
            ? null
            : 'Mínimo 8 caracteres, 1 mayúscula,  1 minúscula, 1 número y 1 caracter especial';

    // 4.5 Para avisar que hubo un cambio
    setState(() {
      emailError = eError;
      passError = pError;
    });

    // 4.6 Cerrar el teclado y bajar manos
    FocusScope.of(context).unfocus();
    _typingDebounce?.cancel();
    _isChecking?.change(false);
    _isHandsUp?.change(false);
    _numLook?.value = 50.0; // Mirada neutral

    // 4.7 Activar triggers
    if (eError == null && pError == null) {
      _trigSuccess?.fire();
    } else {
      _trigFail?.fire();
    }
  }

  //1.2 LISTENERS (OYENTE/CHISMOSOS)

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() {
      if (_emailFocusNode.hasFocus) {
        //Virificar que no sea nulo
        if (_isHandsUp != null) {
          //Manos abajo en el email
          _isHandsUp!.change(false);
          //2.2 MIRADA NEUTRAL
          _numLook?.value = 50.0;
        }
      }
    });
    _passowrdFocusNode.addListener(() {
      //Maanos arriba en password
      _isHandsUp?.change(_passowrdFocusNode.hasFocus);
    });

  }

  @override
  Widget build(BuildContext context) {
    //Para obtener el tamaño de la memoria 
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      // CORRECCIÓN: Formato de color correcto para Flutter
      backgroundColor: const Color(0xFFD6E2EA),
      body: SafeArea(
        // CORRECCIÓN: SingleChildScrollView agregado para evitar que el teclado oculte al oso
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 20), // Espacio inicial
              SizedBox(
                width: size.width,
                height: 250, // Aumentado un poco para mejor visibilidad
                child: RiveAnimation.asset(
                    'assets/3645-7621-remix-of-login-machine.riv', // Ruta actualizada al archivo que mostraste
                    stateMachines: const ['Login Machine'],
                    onInit: (artboard) {
                      _controller = StateMachineController.fromArtboard(
                        artboard, 
                        'Login Machine'  
                      );

                      if(_controller == null) return;
                      artboard.addController(_controller!);
                      
                      _isChecking = _controller!.findSMI('isChecking');
                      _isHandsUp = _controller!.findSMI('isHandsUp');
                      _trigSuccess = _controller!.findSMI('trigSuccess');
                      _trigFail = _controller!.findSMI('trigFail');
                      _numLook = _controller!.findSMI('numLook');
                    },
                  ),
                ),
              const SizedBox(height: 18),
              //CAMPO DE TEXTO EMAIL
              TextField(
                controller: _emailCtrl,
                focusNode: _emailFocusNode,
                onChanged: (value){
                  if (_isChecking == null) return;
                  _isChecking!.change(true);
                  
                  //2.4 IMPLEMENTAR NUMLOOK
                  final look = (value.length/90.0*100.0).clamp(0.0, 100.0);
                  _numLook?.value = look;

                  _typingDebounce?.cancel();
                  _typingDebounce = Timer(
                    const Duration(seconds: 2), 
                    () {
                      if(!mounted) return;
                      _isChecking!.change(false);
                    });
                },
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  errorText: emailError,
                  hintText: 'Email',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)  
                  ),
                ),
              ),
              const SizedBox(height: 10,),
              //TextField de contraseña
              TextField(
                controller: _passCtrl,
                focusNode: _passowrdFocusNode,
                onChanged: (value){
                  if (_isHandsUp == null) return;
                  _isHandsUp!.change(true);
                },
                obscureText: _obscureText,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  errorText: passError,
                  hintText: 'Password' ,
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 10,),
              SizedBox(
                width: size.width,
                child: const Text (
                  "Forgot passsword?",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    decoration: TextDecoration.underline
                  ),
                  ),
              ),
               const SizedBox(height: 10,),
              MaterialButton(
                minWidth: size.width,
                height: 50,
                color: const Color(0xFFAD0000), // Rojo corregido
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  ),
                onPressed: _onLogin,
                child: const Text("Login", style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 10,),
                SizedBox(
                  width: size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        "Register",
                      style: TextStyle(color: Color.fromARGB(255, 0, 0, 0),
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.bold,
                      ),
                      ),
                    ),
                  ],)
                ),
                const SizedBox(height: 20), // Espacio final para el scroll
            ],
          ),
        ),
      )
    );
  }

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passowrdFocusNode.dispose();
    _emailCtrl.dispose(); // Agregado para limpiar memoria
    _passCtrl.dispose();  // Agregado para limpiar memoria
    _typingDebounce?.cancel();
    super.dispose();
  }
}