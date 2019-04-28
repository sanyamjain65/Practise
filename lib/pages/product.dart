import 'dart:async';

import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../scoped-models/main.dart';
import '../widgets/ui_elements/title_default.dart';

class ProductPage extends StatelessWidget {
  final int productIndex;

  ProductPage(
    this.productIndex,
  );

  _showWarningDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Are you Sure'),
            content: Text('This action cannot be undone'),
            actions: <Widget>[
              FlatButton(
                child: Text('DISCARD'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text('CONTINUE'),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context, true);
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return WillPopScope(onWillPop: () {
      print('back button pressed');
      Navigator.pop(context, false);
      return Future.value(false);
    }, child: ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return Scaffold(
          appBar: AppBar(
            title: Text(model.products[productIndex].title),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.asset(model.products[productIndex].image),
              Container(
                padding: EdgeInsets.all(10.0),
                child: TitleDefault(model.products[productIndex].title),
              ),
              Container(
                padding: EdgeInsets.all(10.0),
                child: RaisedButton(
                    color: Theme.of(context).accentColor,
                    child: Text('DELETE'),
                    onPressed: () => _showWarningDialog(context)),
              )
            ],
          ),
        );
      },
    ));
  }
}
