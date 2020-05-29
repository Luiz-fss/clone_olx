import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:olx/models/Anuncio.dart';
import 'package:olx/util/Configuracoes.dart';
import 'package:olx/views/widgets/ItemAnuncio.dart';


class Anuncios extends StatefulWidget {
  @override
  _AnunciosState createState() => _AnunciosState();
}

class _AnunciosState extends State<Anuncios> {

  String _itemSelecionadoEstado;
  String _itemSelecionadoCategoria;
  final _controller = StreamController<QuerySnapshot>.broadcast();


  List<DropdownMenuItem<String>> _listaItensDropsEstados = List();
  List<DropdownMenuItem<String>> _listaItensDropsCategorias = List();

  _escolheMenu(String itemEscolhido){

    switch(itemEscolhido){
      case "Meus anúncios":
        Navigator.pushNamed(context, "/meus-anuncios");
        break;
      case "Entrar / Cadastrar":
        Navigator.pushNamed(context, "/login");
        break;
      case "Deslogar":
        _deslogar();

    }
  }
  _deslogar()async{
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signOut();
    Navigator.pushNamed(context, "/login");
  }
  List<String> itensMenu = [

  ];

  Future _verificaUsuarioLogado()async{
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser firebaseUser = await auth.currentUser();

    if(firebaseUser == null){
      itensMenu = [
        "Entrar / Cadastrar"
      ];
    }else{
      itensMenu = [
        "Meus anúncios", "Deslogar"
      ];
    }
  }

  _carregarItensDropdown(){
    //estados
    _listaItensDropsEstados = Configuracoes.getEstado();
    //categorias
    _listaItensDropsCategorias = Configuracoes.getCategorias();
  }

  Future<Stream<QuerySnapshot>> _filtrarAnuncios()async{
    Firestore db = Firestore.instance;

    Query query = db.collection("anuncios");

    if(_itemSelecionadoEstado != null){
      query = query.where("estado", isEqualTo: _itemSelecionadoEstado);
    }
    if(_itemSelecionadoCategoria != null){
      query = query.where("categoria", isEqualTo: _itemSelecionadoEstado);
    }
    Stream<QuerySnapshot> stream = query.snapshots();
    stream.listen((dados){
      _controller.add(dados);
    });
  }


  Future<Stream<QuerySnapshot>> _adcionarListenerAnuncios()async{
    Firestore db = Firestore.instance;
    Stream<QuerySnapshot> stream = db.collection("anuncios")
    .snapshots();

    stream.listen((dados){
      _controller.add(dados);
    });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _carregarItensDropdown();
    _verificaUsuarioLogado();
    _adcionarListenerAnuncios();
  }

  @override
  Widget build(BuildContext context) {

    var carregandoDado = Center(
      child: Column(
        children: <Widget>[
          Text("Carregando anúncios"),
          CircularProgressIndicator()
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("OLX"),
        elevation: 0,
        actions: <Widget>[
          PopupMenuButton<String>(
           onSelected: _escolheMenu,
            itemBuilder: (context){
              return itensMenu.map((String item){
                return PopupMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList();
            },
          )
        ],
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            //filtros
            Row(
              children: <Widget>[

                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: Center(
                      child: DropdownButton(
                        iconEnabledColor: Color(0xff9c27b0),
                        value: _itemSelecionadoEstado,
                        items: _listaItensDropsEstados,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 22
                        ),
                        onChanged: (estado){
                          setState(() {
                            _itemSelecionadoEstado = estado;
                            _filtrarAnuncios();
                          });
                        },
                      ),
                    ),
                  ),
                ),

                //container
                Container(
                  color: Colors.grey[200],
                  width: 2,
                  height: 60,
                ),

                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: Center(
                      child: DropdownButton(
                        iconEnabledColor: Color(0xff9c27b0),
                        value: _itemSelecionadoCategoria,
                        items: _listaItensDropsCategorias,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 22
                        ),
                        onChanged: (categoria){
                          setState(() {
                            _itemSelecionadoCategoria = categoria;
                            _filtrarAnuncios();
                          });
                        },
                      ),
                    ),
                  ),
                )
              ],
            ),

            //listagem de anuncios
            StreamBuilder(
              stream: _controller.stream,
              builder: (context,snapshot){
                switch(snapshot.connectionState){
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return carregandoDado;
                    break;
                  case ConnectionState.active:
                  case ConnectionState.done:
                    QuerySnapshot querySnapshot = snapshot.data;
                    if(querySnapshot.documents.length == 0){
                      return Container(
                        padding: EdgeInsets.all(25),
                        child: Text(
                          "Nenhum anúncio! :(",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      );
                    }

                    return Expanded(
                      child: ListView.builder(
                        itemCount: querySnapshot.documents.length,
                          itemBuilder: (_,indice){

                          List<DocumentSnapshot> anuncios = querySnapshot.documents.toList();
                          DocumentSnapshot documentSnapshot = anuncios[indice];
                          Anuncio anuncio = Anuncio.fromDocumentSnapshot(documentSnapshot);

                          return ItemAnuncio(
                            anuncio: anuncio,
                            onTapItem: (){
                              Navigator.pushNamed(context, "/detalhe-anuncio",
                              arguments: anuncio);

                            },
                          );
                          }),
                    );

                }
                return Container();
              },
            )

          ],

        ),
      ),
    );
  }
}
