import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import './pages/product.dart';
import './pages/products.dart';
import './pages/products_admin.dart';
import './scoped-models/products.dart';
import './scoped-models/main.dart';
import './pages/auth.dart';
import './models/product.dart';

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
  final MainModel model = MainModel();
  bool _isAuthenticated = false;

  @override
  Widget build(BuildContext context) {

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
          '/': (BuildContext context) => ScopedModelDescendant(builder: (BuildContext context, Widget child, MainModel model) {
            return !_isAuthenticated ?  AuthPage() : ProductsPage(model);
          },),
          '/admin': (BuildContext context) => !_isAuthenticated ?  AuthPage() : ManageProducts(model),
        },
        onGenerateRoute: (RouteSettings settings) {
          if (!_isAuthenticated) {
            return MaterialPageRoute<bool> (
              builder: (BuildContext context) => AuthPage(),
            );
          }
          final List<String> pathElements = settings.name.split('/');
          if (pathElements[0] != '') {
            return null;
          }
          if (pathElements[1] == 'product') {
            final String productId = pathElements[2];
            final Product product = model.allProducts.firstWhere((Product product) {
              return product.id == productId;
            } );
            return MaterialPageRoute<bool>(
              builder: (BuildContext context) => !_isAuthenticated ?  AuthPage() :  ProductPage(product),
            );
          }
          return null;
        },
        onUnknownRoute: (RouteSettings settings) {
          return MaterialPageRoute<bool>(
            builder: (BuildContext context) => !_isAuthenticated ?  AuthPage() : ProductsPage(model),
          );
        },
      ),
    );
  }

  @override
  void initState() {
    model.autoAuth();
    model.userSubject.listen((bool isAuthenticated) {
      setState(() {
        _isAuthenticated = isAuthenticated;
      });
    });
    super.initState();
  }
}
