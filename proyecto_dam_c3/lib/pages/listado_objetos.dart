import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:proyecto_dam_c3/pages/detalle_objeto.dart';
import 'package:proyecto_dam_c3/services/usm_service.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ListadoObjetos extends StatelessWidget {
  const ListadoObjetos({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: UsmService().objetos(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData ||
              snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          return ListView.separated(
            separatorBuilder: (context, index) => Divider(),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var objeto = snapshot.data!.docs[index];
              final vigente = objeto['estado'] == true;
              final usuario = FirebaseAuth.instance.currentUser;
              final esAutor = objeto['autorId'] == usuario!.uid;
              return Slidable(
                startActionPane: esAutor
                    ? ActionPane(
                        motion: ScrollMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (value) {
                              UsmService().cambiarEstado(objeto.id, !vigente);
                            },
                            icon: MdiIcons.swapHorizontal,
                            label: vigente ? 'Devolver' : 'Vigente',
                            backgroundColor: Color(0xFF000080),
                            foregroundColor: Colors.white,
                          ),
                        ],
                      )
                    : null,

                endActionPane: esAutor
                    ? ActionPane(
                        motion: ScrollMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (value) {
                              showDialog(
                                context: context,
                                builder: (dialogContext) => AlertDialog(
                                  title: Text('Eliminar publicación'),
                                  content: Text(
                                    '¿Desea eliminar esta publicación?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(dialogContext),
                                      child: Text('Cancelar'),
                                    ),
                                    FilledButton(
                                      onPressed: () async {
                                        await UsmService().borrarObjeto(
                                          objeto.id,
                                        );
                                        Navigator.pop(dialogContext);
                                      },
                                      child: Text('Eliminar'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            icon: MdiIcons.trashCan,
                            label: 'Borrar',
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ],
                      )
                    : null,
                child: ListTile(
                  leading: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: vigente ? Colors.white : Colors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      vigente ? 'Vigente' : 'Devuelto',
                      style: TextStyle(
                        color: vigente ? Colors.green : Colors.grey,
                        fontSize: 15,
                      ),
                    ),
                  ), //foto
                  title: Column(
                    children: [
                      Text(
                        objeto['titulo'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    children: [
                      Row(children: [Text('Tipo: '), Text(objeto['tipo'])]),
                      Row(
                        children: [
                          Text('Categoria: '),
                          Text(objeto['categoria']),
                        ],
                      ),
                    ],
                  ),
                  trailing: Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    clipBehavior: Clip.antiAlias,
                    width: 56,
                    height: 56,
                    child: Image.memory(
                      (objeto['foto'] as Blob).bytes,
                      fit: BoxFit.cover,
                      cacheWidth: 112,
                    ),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetalleObjeto(id: objeto.id),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
