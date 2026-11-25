import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UsmService {
  Stream<QuerySnapshot> objetos() {
    return FirebaseFirestore.instance.collection('Objetos').snapshots();
  }

  Future<void> agregarObjeto(
    String titulo,
    String descripcion,
    String tipo,
    String categoria,
    String lugar,
    DateTime fechahora,
    Blob foto,
    bool estado,
    String autor,
  ) {
    return FirebaseFirestore.instance.collection('Objetos').doc().set({
      'titulo': titulo,
      'descripcion': descripcion,
      'tipo': tipo,
      'categoria': categoria,
      'lugar': lugar,
      'fechahora': fechahora,
      'foto': foto,
      'estado': estado,
      'autor': autor,
      'autorId': FirebaseAuth.instance.currentUser!.uid,
    });
  }

  Future<void> borrarObjeto(String id) {
    return FirebaseFirestore.instance.collection('Objetos').doc(id).delete();
  }

  Future<void> cambiarEstado(String id, bool estado) {
    return FirebaseFirestore.instance.collection('Objetos').doc(id).update({
      'estado': estado,
    });
  }

  Future<QuerySnapshot> categorias() {
    return FirebaseFirestore.instance
        .collection('Categorias')
        .orderBy('nombre')
        .get();
  }
}
