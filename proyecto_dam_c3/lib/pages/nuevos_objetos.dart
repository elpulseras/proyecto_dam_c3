import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_dam_c3/services/usm_service.dart';
import 'package:image_picker/image_picker.dart';

import 'dart:typed_data';

import 'package:proyecto_dam_c3/utils/fechas.dart';

class NuevosObjetos extends StatefulWidget {
  const NuevosObjetos({super.key});

  @override
  State<NuevosObjetos> createState() => _NuevosObjetosState();
}

class _NuevosObjetosState extends State<NuevosObjetos> {
  bool guardando = true;
  final agregarkey = GlobalKey<FormState>();
  final tituloCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  String? tipoSeleccionado;
  String? categoriaSeleccionado;
  final lugarCtrl = TextEditingController();
  DateTime fechaHora = DateTime.now();
  Blob? foto;
  Uint8List? fotoBytes;
  bool estado = true;
  late String autor;

  @override
  void initState() {
    super.initState();
    autor = FirebaseAuth.instance.currentUser!.displayName!;
  }

  @override
  void dispose() {
    tituloCtrl.dispose();
    descCtrl.dispose();
    lugarCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(10),
        child: Form(
          key: agregarkey,
          child: Column(
            children: [
              TextFormField(
                controller: tituloCtrl,
                decoration: InputDecoration(labelText: 'Titulo'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingrese un titulo';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: descCtrl,
                decoration: InputDecoration(labelText: 'Descripcion'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingrese una descripcion';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField(
                decoration: InputDecoration(labelText: 'Tipo'),
                items: ['Perdido', 'Encontrado']
                    .map(
                      (tipo) =>
                          DropdownMenuItem(value: tipo, child: Text(tipo)),
                    )
                    .toList(),
                onChanged: (tipo) => tipoSeleccionado = tipo,
                validator: (value) {
                  if (value == null) {
                    return 'Seleccione un tipo';
                  }
                  return null;
                },
              ),
              FutureBuilder(
                future: UsmService().categorias(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData ||
                      snapshot.connectionState == ConnectionState.waiting) {
                    return Text('Cargando las categorias');
                  }

                  var datos = snapshot.data!.docs;

                  return DropdownButtonFormField(
                    decoration: InputDecoration(labelText: 'Categoria'),

                    items: datos.map((dato) {
                      return DropdownMenuItem(
                        child: Text(dato['nombre']),
                        value: dato['nombre'].toString(),
                      );
                    }).toList(),

                    onChanged: (valor) {
                      categoriaSeleccionado = valor;
                    },

                    validator: (value) {
                      if (value == null) {
                        return 'Seleccione la categoria';
                      }
                      return null;
                    },
                  );
                },
              ),
              TextFormField(
                controller: lugarCtrl,
                decoration: InputDecoration(labelText: 'Lugar'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Seleccione el lugar';
                  }
                  return null;
                },
              ),
              Row(
                children: [
                  Text('Fecha y hora de la publicacion: '),
                  Text(formatearFecha(fechaHora.toString())),
                  Spacer(),
                  IconButton(
                    onPressed: () async {
                      showDatePicker(
                        context: context,
                        initialDate: fechaHora,
                        firstDate: DateTime(2026),
                        lastDate: DateTime.now(),
                      ).then((fecha) {
                        if (fecha != null) {
                          setState(() {
                            fechaHora = DateTime(
                              fecha.year,
                              fecha.month,
                              fecha.day,
                              fechaHora.hour,
                              fechaHora.minute,
                            );
                          });
                        }
                      });
                    },
                    icon: Icon(Icons.calendar_month_outlined),
                  ),
                ],
              ),
              Text('Fotografia'),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final imagen = await ImagePicker().pickImage(
                          source: ImageSource.camera,
                        );

                        if (imagen != null) {
                          final bytes = await imagen.readAsBytes();

                          setState(() {
                            fotoBytes = bytes;
                            foto = Blob(bytes);
                          });
                        }
                      },
                      child: Text('Tomar foto'),
                    ),
                  ),

                  SizedBox(width: 10),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final imagen = await ImagePicker().pickImage(
                          source: ImageSource.gallery,
                        );

                        if (imagen != null) {
                          final bytes = await imagen.readAsBytes();

                          setState(() {
                            fotoBytes = bytes;
                            foto = Blob(bytes);
                          });
                        }
                      },
                      child: Text('Galeria'),
                    ),
                  ),
                ],
              ),
              Container(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Estado: Vigente', style: TextStyle(fontSize: 20)),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Autor: $autor', style: TextStyle(fontSize: 20)),
                  ],
                ),
              ),
              Spacer(),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    if (!agregarkey.currentState!.validate()) {
                      return;
                    }

                    if (foto == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('La fotografia es obligatoria')),
                      );
                      return;
                    }

                    try {
                      if (guardando) return;
                      guardando = true;

                      UsmService().agregarObjeto(
                        tituloCtrl.text.trim(),
                        descCtrl.text.trim(),
                        tipoSeleccionado!,
                        categoriaSeleccionado!,
                        lugarCtrl.text.trim(),
                        fechaHora,
                        foto!,
                        estado,
                        autor,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Se ha insertado la publicacion.'),
                        ),
                      );
                    } finally {
                      guardando = false;
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF000080),
                  ),
                  child: Text(
                    'Insertar publicacion',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
