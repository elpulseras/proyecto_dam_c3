import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String mensaje = "";
  bool error = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        backgroundColor: Color(0xFF000080),
        title: Text(
          "Bienvenido a Objetos Perdidos USM",
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
      body: Center(
        child: Container(
          width: 300,
          height: 250,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 60),
              Text(
                "Inicia Sesion",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              Text("Ingresar al sistema", style: TextStyle(fontSize: 15)),
              SizedBox(height: 30),
              SizedBox(
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      error = false;
                      final GoogleSignInAccount googleUser = await GoogleSignIn
                          .instance
                          .authenticate();

                      final GoogleSignInAuthentication googleAuth =
                          googleUser.authentication;

                      final credencial = GoogleAuthProvider.credential(
                        idToken: googleAuth.idToken,
                      );

                      await FirebaseAuth.instance.signInWithCredential(
                        credencial,
                      );

                      setState(() {
                        mensaje = "Inicio de sesion exitoso";
                        error = false;
                      });
                    } catch (e) {
                      print("ERROR GOOGLE $e");
                      setState(() {
                        mensaje = "Error al iniciar sesion";
                        error = true;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  child: Icon(MdiIcons.google, color: Colors.white),
                ),
              ),
              Text(
                mensaje,
                style: TextStyle(color: error ? Colors.red : Colors.green),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
