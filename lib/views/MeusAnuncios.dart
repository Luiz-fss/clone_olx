import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:olx/models/Anuncio.dart';
import 'package:olx/views/widgets/ItemAnuncio.dart';

class MeusAnuncios extends StatefulWidget {
  @override
  _MeusAnunciosState createState() => _MeusAnunciosState();
}

class _MeusAnunciosState extends State<MeusAnuncios> {

  final _controller = StreamController<QuerySnapshot>.broadcast();
  String _idUsuarioLogado;

  Future<Stream<QuerySnapshot>> _adcionarListenerAnuncio()async{

    await _recuperaDadosUsuarioLogado();
    Firestore db = Firestore.instance;
    Stream<QuerySnapshot> stream = db.collection("meus_anuncios")
    .document(_idUsuarioLogado)
    .collection("anuncios")
    .snapshots();
    stream.listen((dados){
      _controller.add(dados);
    });
  }

  _recuperaDadosUsuarioLogado()async{
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser firebaseUser = await auth.currentUser();
    String idUsuarioLogado = firebaseUser.uid;
    _idUsuarioLogado = idUsuarioLogado;
  }

  _removerAnuncio(String idAnuncio){
    Firestore db = Firestore.instance;
    db.collection("meus_anuncios")
    .document(_idUsuarioLogado)
    .collection("anuncios")
    .document(idAnuncio)
    .delete().then((_){
      
      db.collection("anuncios").document(idAnuncio).delete();
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _adcionarListenerAnuncio();
  }

  @override
  Widget build(BuildContext context) {

    var carregandoDado = Center(
      child: Column(
        children: <Widget>[
          Text("Carregano anuncio"),
          CircularProgressIndicator()
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Meus anúncios"),
      ),
      floatingActionButton: FloatingActionButton(
        foregroundColor: Colors.white,
        child: Icon(Icons.add),
        onPressed: (){
          Navigator.pushNamed(context, "/novo-anuncio");
        },
      ),
      body: StreamBuilder(
        stream: _controller.stream,
        builder: (context,snapshot){

          switch(snapshot.connectionState){
            case ConnectionState.none:
            case ConnectionState.waiting:
              return carregandoDado;
              break;
            case ConnectionState.active:
            case ConnectionState.done:
              //mensagem de erro

              if(snapshot.hasError){
                return Text("Erro ao carregar dados");
              }
              QuerySnapshot querySnapshot = snapshot.data;
              return ListView.builder(
                  itemCount: querySnapshot.documents.length,
                  itemBuilder: (_,indice){

                    List<DocumentSnapshot> anuncios = querySnapshot.documents.toList();
                    DocumentSnapshot documentSnapshot = anuncios[indice];
                    Anuncio anuncio = Anuncio.fromDocumentSnapshot(documentSnapshot);
                    return ItemAnuncio(
                      anuncio: anuncio,
                      onPressedRemover: (){
                        showDialog(
                            context: context,
                          builder: (context){
                              return AlertDialog(
                                title: Text("Confirmar"),
                                content: Text("Deseja realmente excluir o anuncio?"),
                                actions: <Widget>[

                                  FlatButton(
                                    child:Text("Cancelar",style: TextStyle(color: Colors.white),),
                                    onPressed: (){
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  FlatButton(
                                    color: Colors.red,
                                    child:Text("Remover",style: TextStyle(color: Colors.white),),
                                    onPressed: (){
                                      _removerAnuncio(anuncio.id);
                                      Navigator.of(context).pop();
                                    },
                                  )
                                ],
                              );
                          }
                        );
                      },
                    );
                  });
          }
          return Container();

        },
      )
    );
  }
}
