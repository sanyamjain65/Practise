import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../scoped-models/main.dart';
import '../widgets/products/products.dart';

class ProductsPage extends StatefulWidget {
  final MainModel model;

  ProductsPage(this.model);
  @override
  State<StatefulWidget> createState() {
    return _ProductPageState();
  }

}

class _ProductPageState extends State<ProductsPage> {


  Widget _buildSideDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            automaticallyImplyLeading: false,
            title: Text('Choose'),
          ),
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('Manage Products'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/admin');
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildSideDrawer(context),
      appBar: AppBar(
        title: Text('EasyList'),
        actions: <Widget>[
          ScopedModelDescendant<MainModel>(
            builder: (BuildContext context, Widget child, MainModel model) {
              return IconButton(
                icon: Icon(model.displayFavoritesOnly
                    ? Icons.favorite
                    : Icons.favorite_border),
                onPressed: () {
                  model.toggleDisplayMode();
                },
              );
            },
          )
        ],
      ),
      body: _buildMyProductsList(),
    );
  }

  Widget _buildMyProductsList() {
    return ScopedModelDescendant<MainModel> (builder: (BuildContext context, Widget child, MainModel model) {
      Widget content = Center(child: Text('no Product found'),);
      if (model.displayedProducts.length > 0 && !model.isLoading) {
        content = Products();
      } else if(model.isLoading) {
        content = CircularProgressIndicator();
      }
      return content;
    },);
  }

  @override
  void initState() {
    widget.model.fetchProducts();
    super.initState();
  }
}
