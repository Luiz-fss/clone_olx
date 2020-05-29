import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:olx/models/Usuario.dart';
import 'package:olx/views/widgets/CustomButton.dart';
import 'package:olx/views/widgets/InputCustom.dart';


class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  bool _cadastrar = false;
  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerSenha = TextEditingController();
  String _mensagemErro ="";
  String _textoBotao= "Entrar";

  _cadastrarUsuario(Usuario usuario)async{
    FirebaseAuth auth = FirebaseAuth.instance;
     await auth.createUserWithEmailAndPassword(
         email: usuario.email,
         password: usuario.senha
     ).then((firebaseUser){
        Navigator.pushReplacementNamed(context, "/");
     });
  }
  _logarUsuario(Usuario usuario)async{
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signInWithEmailAndPassword(
        email: usuario.email,
        password: usuario.senha
    ).then((firebaseUser){
      Navigator.pushReplacementNamed(context, "/");
    });
  }

  _validarCampos(){
    String email = _controllerEmail.text;
    String senha = _controllerSenha.text;
    if(email.isNotEmpty && email.contains("@")){
      if(senha.isNotEmpty && senha.length >6){
        Usuario usuario = Usuario();
        usuario.email = email;
        usuario.senha = senha;
        if(_cadastrar){
          _cadastrarUsuario(usuario);
        }else{
          _logarUsuario(usuario);
        }
      }else{
        setState(() {
          _mensagemErro = "Preencha a senha";
        });
      }
    }else{
      setState(() {
        _mensagemErro = "Preencha o email válido";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(""),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 32),
                  child: Image.asset(
                      "imagens/logo.png",
                    width: 200,
                    height: 150,
                  ),
                ),
                InputCustom(
                  controller: _controllerEmail,
                  hint: "Email",
                  autofocus: true,
                  obscure: false,
                  type: TextInputType.emailAddress,
                ),
                InputCustom(
                  controller: _controllerSenha,
                  hint: "Senha",
                  autofocus: false,
                  obscure: true,
                  type: TextInputType.text,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("Logar"),
                    Switch(
                      value: _cadastrar,
                      onChanged: (bool valor){
                        setState(() {
                          _cadastrar = valor;
                          _textoBotao = "Entrar";
                          if(_cadastrar){
                            _textoBotao = "Cadastrar";
                          }
                        });
                      },
                    ),
                    Text("Cadastrar")
                  ],
                ),
                CustomButton(
                  texto: _textoBotao,
                  onPressed: _validarCampos,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text(
                    _mensagemErro,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red),),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
