import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import './pages/product.dart';
import './pages/products.dart';
import './pages/products_admin.dart';
import './scoped-models/products.dart';
import './scoped-models/main.dart';
import './pages/auth.dart';

void main() {
//  debugPaintSizeEnabled = true;
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    final MainModel model = MainModel();
    return ScopedModel<MainModel>(
      model: model,
      child: MaterialApp(
        theme: ThemeData(
          fontFamily: 'Oswald',
          primarySwatch: Colors.deepOrange,
          accentColor: Colors.deepPurple,
          brightness: Brightness.light,
          buttonColor: Colors.deepPurple,
        ),
//      home: AuthPage(),
        routes: {
          '/': (BuildContext context) => AuthPage(),
          '/product': (BuildContext context) => ProductsPage(model),
          '/admin': (BuildContext context) => ManageProducts(),
        },
        onGenerateRoute: (RouteSettings settings) {
          final List<String> pathElements = settings.name.split('/');
          if (pathElements[0] != '') {
            return null;
          }
          if (pathElements[1] == 'product') {
            final int index = int.parse(pathElements[2]);
            return MaterialPageRoute<bool>(
              builder: (BuildContext context) => ProductPage(index),
            );
          }
          return null;
        },
        onUnknownRoute: (RouteSettings settings) {
          return MaterialPageRoute<bool>(
            builder: (BuildContext context) => ProductsPage(model),
          );
        },
      ),
    );
  }
}
