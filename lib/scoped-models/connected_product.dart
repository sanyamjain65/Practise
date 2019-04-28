import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:scoped_model/scoped_model.dart';

import '../models/product.dart';
import '../models/user.dart';

mixin ConnectedProducts on Model {
  List<Product> products = [];
  User authenticatedUser;
  int selProductIndex;
  bool _isLoading = false;

  void addProducts(
      String title, String description, String image, double price) {
    _isLoading = true;
    final Map<String, dynamic> productData = {
      'title': title,
      'description': description,
      'image':
          'https://cdn1.harryanddavid.com/wcsstore/HarryAndDavid/images/catalog/18_26468_30J_01ex.jpg',
      'price': price,
      'userEmail': authenticatedUser.email,
      'userId': authenticatedUser.id
    };
    http
        .post('https://new-firebase-82fdf.firebaseio.com/products.json',
            body: json.encode(productData))
        .then((http.Response response) {

      print(response.statusCode);
      final Map<String, dynamic> responseData = json.decode(response.body);
      print(responseData);
      final Product newProduct = Product(
          id: responseData['name'],
          title: title,
          description: description,
          price: price,
          image: image,
          userEmail: authenticatedUser.email,
          userId: authenticatedUser.id);
      products.add(newProduct);
      _isLoading = false;
      notifyListeners();
    });
  }
}

mixin UtilityModel on ConnectedProducts {
  bool get isLoading {
    return _isLoading;
  }
}
