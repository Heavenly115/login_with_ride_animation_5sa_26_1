import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key}); ///c0nstructor para crear una instancia de LoginScreen
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  bool _obscureText = true; // Variable para controlar la visibilidad de la contraseña
 //CREAR EL CEREBRO 
  StateMachineController? _controller;
  
  //SMIT : STATE MACHINE INPUT
  SMIBool? _isChecking;
  SMIBool? _isHandsUp;
  SMITrigger? _trigSuccess;
  SMITrigger? _trigfail;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery .of(context).size;
    //para obtener el tamaño de la pantalla 
    return Scaffold(
      // Evita que se quite espacio del nudge
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              SizedBox(
                width: size.width,
                height: 200, // Ajustar el tamaño del RiveAnimation
                child: RiveAnimation.asset('assets/3645-7621-remix-of-login-machine.riv', stateMachines: ['Login Machine'],
                //Iniciar animacion
                onInit: (artboard){

                  _controller = StateMachineController.fromArtboard(
                    artboard, 
                    'Login Machine');

                    //verifica que inicio bien
                    if (_controller == null) return;
                    //agrega el controlador al tablero/escenario
                    artboard.addController(_controller!);
                    //vincular variables 
                    _isChecking = _controller!.findSMI('isChecking');
                    _isHandsUp = _controller!.findSMI('isHandsUp');
                    _trigSuccess = _controller!.findSMI('istrigSuccess');
                    _trigfail = _controller!.findSMI('trigfail'); 

                },

                
                ),
              ),
              //para separacion 
              const SizedBox(height: 10),
              //campo de texto email 
              TextField(


        onChanged: (value) {
          if (_isHandsUp != null) {
            _isHandsUp!.change(false);
          }
          if (_isChecking == null) return;
          _isChecking!.change(true);


        }, // <--- AQUÍ cierras la función del onChanged
        keyboardType: TextInputType.emailAddress, // <--- AHORA sí es una propiedad válida
        decoration: InputDecoration(
          hintText: 'Email',
          prefixIcon: const Icon(Icons.email),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
              const SizedBox(height: 10),
              TextField(
                   onChanged: (value) {
                     //si ischecking no es nulo
                    if (_isChecking != null) { 
                  //activar el modo chismoso
                      _isChecking!.change(false);}
                  //no tapes los ojos al ver email 
                      if (_isHandsUp == null) return;
                      _isHandsUp!.change(true);
                  
                },
              
                obscureText: _obscureText,
                decoration: InputDecoration(
                  hintText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  suffix: IconButton(
                    icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
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
              const SizedBox(height: 10),
              
                
                
            ]
          ),
        )
      )
    );
  }
}