import 'package:brasil_fields/brasil_fields.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:olx/models/Anuncio.dart';
import 'package:olx/util/Configuracoes.dart';
import 'package:olx/views/widgets/CustomButton.dart';
import 'package:olx/views/widgets/InputCustom.dart';
import 'dart:io';

import 'package:validadores/Validador.dart';

class NovoAnuncio extends StatefulWidget {
  @override
  _NovoAnuncioState createState() => _NovoAnuncioState();
}

class _NovoAnuncioState extends State<NovoAnuncio> {

  final _formKey = GlobalKey<FormState>();
  List<File> _listaImagens = List();
  List<DropdownMenuItem<String>> _listaItensDropsEstados = List();
  List<DropdownMenuItem<String>> _listaItensDropsCategorias = List();
  String _itemSelecionadoEstado;
  String _itemSelecionadoCategoria;
  Anuncio _anuncio;
  BuildContext _buildContext;


  _selecionarImagemGaleria()async{
    File imagemSelecionada = await ImagePicker.pickImage(source: ImageSource.gallery);
    if(imagemSelecionada != null){
      setState(() {
        _listaImagens.add(imagemSelecionada);
      });
    }


  }

  _carregarItensDropdown(){
    //estados
    _listaItensDropsEstados = Configuracoes.getEstado();
    //categorias
    _listaItensDropsCategorias = Configuracoes.getCategorias();
  }

  Future _uploadImagens()async{
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference pastaRaiz = storage.ref();

    for(var imagem in _listaImagens){
      String nomeImagem = DateTime.now().millisecondsSinceEpoch.toString();
      StorageReference arquivo = pastaRaiz.child("meus_anuncios")
          .child(_anuncio.id)
          .child(nomeImagem);

      StorageUploadTask uploadTask = arquivo.putFile(imagem);
      StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;

      String url = await taskSnapshot.ref.getDownloadURL();
      _anuncio.fotos.add(url);
    }
  }

  _abrirDialog(BuildContext context){
    showDialog(
        context: context,
      barrierDismissible: false,
      builder: (BuildContext context){
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CircularProgressIndicator(),
                SizedBox(height: 20,),
                Text("Salvando anúncio...")
              ],
            ),
          );
      }
    );
  }

  _salvarAnuncio()async{
    _abrirDialog(_buildContext);
    //upload das imagens
    await _uploadImagens();
    //salvar no firestore
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser firebaseUser = await auth.currentUser();
    String idUsuarioLogado = firebaseUser.uid;
    Firestore db = Firestore.instance;
    db.collection("meus_anuncios")
        .document(idUsuarioLogado)
        .collection("anuncios")
        .document(_anuncio.id)
        .setData(_anuncio.toMap()).then((_){


          //salvar publico
      db.collection("anuncios")
      .document(_anuncio.id)
      .setData(_anuncio.toMap()).then((_){
        Navigator.pop(_buildContext);
        Navigator.pop(context);
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _carregarItensDropdown();
    _anuncio = Anuncio.gerarId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Novo anúncio"),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                //area imagens
                FormField<List>(
                  initialValue: _listaImagens,
                  validator: (imagens){
                    if(imagens.length == 0){
                        return "Necessário selecionar imagem";
                    }
                    return null;
                  },
                  builder: (state){
                    return Column(
                      children: <Widget>[
                        Container(
                          height: 100,
                          child: ListView.builder(
                              itemCount: _listaImagens.length + 1,//truque para adicionar um item fake
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, indice){
                                if(indice == _listaImagens.length){
                                  return Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8),
                                    child: GestureDetector(
                                      onTap: (){
                                        _selecionarImagemGaleria();
                                      },
                                      child: CircleAvatar(
                                        backgroundColor: Colors.grey[400],
                                        radius: 50,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            Icon(Icons.add_a_photo,size: 40,color: Colors.grey[100],),
                                            Text(
                                                "Adicionar",
                                              style: TextStyle(
                                                color: Colors.grey[100]
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                if(_listaImagens.length > 0){
                                  return Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8),
                                    child: GestureDetector(
                                      onTap: (){
                                        showDialog(
                                            context: context,
                                          builder: (context) => Dialog(
                                            child: SingleChildScrollView(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  Image.file(_listaImagens[indice], fit: BoxFit.cover,),
                                                  FlatButton(
                                                    child: Text("Excluir",),
                                                    textColor: Colors.red,
                                                    onPressed: (){
                                                      setState(() {
                                                        _listaImagens.removeAt(indice);
                                                        Navigator.of(context).pop();
                                                      });
                                                    },
                                                  )
                                                ],
                                              ),
                                            ),
                                          )
                                        );
                                      },
                                      child: CircleAvatar(
                                        radius: 50,
                                        backgroundImage: FileImage(_listaImagens[indice]),
                                        child: Container(
                                          color: Color.fromRGBO(255, 255, 255, 0.4),
                                          alignment: Alignment.center,
                                          child: Icon(Icons.delete,color: Colors.red,),
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                return Container();
                              }
                          ),
                        ),
                        if(state.hasError)
                          Container(
                            child: Text(
                             "[${state.errorText}]",
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 14
                              ),
                            ),
                          )
                      ],
                    );
                  },
                ),
                //menu dropdown
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: DropdownButtonFormField(
                          hint: Text("Estados"),
                          onSaved: (estado){
                            _anuncio.estado = estado;
                          },
                          value: _itemSelecionadoEstado,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20
                          ),
                          validator: (valor){
                            return Validador().add(
                              Validar.OBRIGATORIO, msg: "Campo Obrigatório"
                            ).valido(valor);
                          },
                          items: _listaItensDropsEstados,
                          onChanged: (valor){
                            setState(() {
                              _itemSelecionadoEstado = valor;
                            });
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: DropdownButtonFormField(
                          hint: Text("Categorias"),
                          onSaved: (categoria){
                            _anuncio.categoria = categoria;
                          },
                          value: _itemSelecionadoCategoria,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 20
                          ),
                          validator: (valor){
                            return Validador().add(
                                Validar.OBRIGATORIO, msg: "Campo Obrigatório"
                            ).valido(valor);
                          },
                          items: _listaItensDropsCategorias,
                          onChanged: (valor){
                            setState(() {
                              _itemSelecionadoCategoria = valor;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 15,top: 15),
                  child: InputCustom(
                    hint: "Título",
                    onSaved: (titulo){
                      _anuncio.titulo = titulo;
                    },
                    validator: (valor){
                      return Validador().add(Validar.OBRIGATORIO, msg: "Campo Obrigatório")
                          .valido(valor);
                    },
                  ),
                ),

                Padding(
                  padding: EdgeInsets.only(bottom: 15),
                  child: InputCustom(
                    hint: "Preço",
                    onSaved: (preco){
                      _anuncio.preco = preco;
                    },
                    type: TextInputType.number,
                    inputFormaters: [
                      WhitelistingTextInputFormatter.digitsOnly,
                      RealInputFormatter(centavos: true)
                    ],
                    validator: (valor){
                      return Validador().add(Validar.OBRIGATORIO, msg: "Campo Obrigatório")
                          .valido(valor);
                    },
                  ),
                ),

                Padding(
                  padding: EdgeInsets.only(bottom: 15),
                  child: InputCustom(
                    hint: "Telefone",
                    onSaved: (telefone){
                      _anuncio.telefone = telefone;
                    },
                    type: TextInputType.phone,
                    inputFormaters: [
                      WhitelistingTextInputFormatter.digitsOnly,
                      TelefoneInputFormatter()
                    ],
                    validator: (valor){
                      return Validador().add(Validar.OBRIGATORIO, msg: "Campo Obrigatório")
                          .valido(valor);
                    },
                  ),
                ),

                Padding(
                  padding: EdgeInsets.only(bottom: 15),
                  child: InputCustom(
                    hint: "Descrição (200 caracteres)",
                    onSaved: (descricao){
                      _anuncio.descricao = descricao;
                    },
                    maxLines: null,
                    type: TextInputType.text,
                    validator: (valor){
                      return Validador().add(Validar.OBRIGATORIO, msg: "Campo Obrigatório")
                          .maxLength(200,msg: "Máximo 200 caracteres")
                          .valido(valor);
                    },
                  ),
                ),

                CustomButton(
                  texto: "Cadastrar anúncio",
                  onPressed: (){
                    if (_formKey.currentState.validate()){
                      //salva os campos

                      _formKey.currentState.save();

                      //contexto
                      _buildContext = context;

                      //salva anuncio

                      _salvarAnuncio();
                    }
                  },
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
