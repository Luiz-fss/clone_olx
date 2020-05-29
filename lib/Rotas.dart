import 'package:flutter/material.dart';
import 'package:olx/views/Anuncios.dart';
import 'package:olx/views/Login.dart';
import 'package:olx/views/MeusAnuncios.dart';
import 'package:olx/views/NovoAnuncio.dart';
import 'package:olx/views/widgets/DetalhesAnuncio.dart';

class Rotas {

  static Route<dynamic> generatorRoute(RouteSettings routeSettings){

    final args = routeSettings.arguments;

    switch(routeSettings.name){

      case "/":
        return MaterialPageRoute(
          builder: (_) => Anuncios()
        );
      case "/login":
        return MaterialPageRoute(
            builder: (_) => Login()
        );
      case "/meus-anuncios":
        return MaterialPageRoute(
            builder: (_) => MeusAnuncios()
        );
      case "/novo-anuncio":
        return MaterialPageRoute(
            builder: (_) => NovoAnuncio()
        );
      case "/detalhe-anuncio":
        return MaterialPageRoute(
            builder: (_) => DetalhesAnuncio(args)
        );
      default:
        _erroRota();
    }

  }


  static Route<dynamic> _erroRota(){
    return MaterialPageRoute(
      builder: (_) {
      return  Scaffold(
          appBar: AppBar(
            title: Text("tela nao encontrada"),
          ),
          body: Center(
            child: Text("tela nao encontrada"),
          ),
        );
      }
    );
  }
}