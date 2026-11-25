import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proyecto_dam_c3/pages/listado_objetos.dart';
import 'package:proyecto_dam_c3/pages/nuevos_objetos.dart';

class Principal extends StatefulWidget {
  const Principal({super.key});

  @override
  State<Principal> createState() => _PrincipalState();
}

class _PrincipalState extends State<Principal> {
  int indice = 0;

  final List<Widget> paginas = const [ListadoObjetos(), NuevosObjetos()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF000080),
        title: Text(
          "Bienvenido ${FirebaseAuth.instance.currentUser!.displayName}",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          PopupMenuButton(
            onSelected: (valueSeleccionado) => FirebaseAuth.instance.signOut(),
            iconColor: Colors.white,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: "logout",
                child: Text(
                  "Cerrar sesion",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ],
      ),
      body: paginas[indice],
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: Color(0xFF000080),
          indicatorColor: Colors.grey,
          iconTheme: WidgetStateProperty.all(
            IconThemeData(color: Colors.white),
          ),
          labelTextStyle: WidgetStateProperty.all(
            TextStyle(color: Colors.white),
          ),
        ),
        child: NavigationBar(
          selectedIndex: indice,
          onDestinationSelected: (i) => setState(() => indice = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.list),
              label: 'Publicaciones',
            ),
            NavigationDestination(
              icon: Icon(Icons.add),
              label: 'Crear Publicacion',
            ),
          ],
        ),
      ),
    );
  }
}
