import 'dart:convert';

import 'package:http/http.dart' as http;

import './connected_product.dart';
import '../models/product.dart';

mixin ProductsModel on ConnectedProducts {
  bool _showFavorites = false;
  bool _isLoading = false;
  bool _postisLoading = false;

  List<Product> get allProducts {
    return List.from(products);
  }

  List<Product> get displayedProducts {
    if (_showFavorites) {
      return List.from(
          products.where((Product product) => product.isFavourite).toList());
    }
    return List.from(products);
  }

  int get selectedProductIndex {
    return products.indexWhere((Product product) {
      return product.id == selProductId;
    });
  }

  String get selectedProductId {
    return selProductId;
  }

  bool get displayFavoritesOnly {
    return _showFavorites;
  }

  Product get selectedProduct {
    if (selectedProductId == null) {
      return null;
    }
    return products.firstWhere((Product product) {
      return product.id == selProductId;
    });
  }

  Future<Null> updateProducts(
      String title, String description, String image, double price) {
    _postisLoading = true;
    notifyListeners();
    final Map<String, dynamic> updateData = {
      'title': title,
      'description': description,
      'image':
          'https://cdn1.harryanddavid.com/wcsstore/HarryAndDavid/images/catalog/18_26468_30J_01ex.jpg',
      'price': price,
      'userEmail': selectedProduct.userEmail,
      'userId': selectedProduct.userId
    };
    return http
        .put(
            'https://new-firebase-82fdf.firebaseio.com/products/${selectedProduct.id}.json?auth=${authenticatedUser.token}',
            body: json.encode(updateData))
        .then((http.Response response) {
      final Product updatedProduct = Product(
          id: selectedProduct.id,
          title: title,
          description: description,
          price: price,
          image: image,
          userEmail: selectedProduct.userEmail,
          userId: selectedProduct.userId);
      products[selectedProductIndex] = updatedProduct;
      _postisLoading = false;
      notifyListeners();
    });
  }

  void deleteProduct() {
    _isLoading = true;
    final deletedProduct = selectedProduct.id;

    products.removeAt(selectedProductIndex);
    selProductId = null;
    notifyListeners();
    http
        .delete(
            'https://new-firebase-82fdf.firebaseio.com/products/${deletedProduct}.json?auth=${authenticatedUser.token}')
        .then((http.Response response) {
      _isLoading = false;
      notifyListeners();
    });
  }

  void selectProduct(String productId) {
    selProductId = productId;
  }

  void toggleProductFavouriteStatus() async {
    final bool isCurrentlyFavourite = selectedProduct.isFavourite;
    final bool newFavouriteStatus = !isCurrentlyFavourite;
    final Product updatedProduct = Product(
        id: selectedProduct.id,
        title: selectedProduct.title,
        description: selectedProduct.description,
        price: selectedProduct.price,
        image: selectedProduct.image,
        userEmail: selectedProduct.userEmail,
        userId: selectedProduct.userId,
        isFavourite: newFavouriteStatus);
    products[selectedProductIndex] = updatedProduct;
//    selProductId = null;
    notifyListeners();
    http.Response response;
    if (newFavouriteStatus) {
      print('${selectedProduct.id}');
      response = await http.put(
          'https://new-firebase-82fdf.firebaseio.com/products/${selectedProduct.id}/wishlistUsers/${authenticatedUser.id}.json?auth=${authenticatedUser.token}',
          body: json.encode(true));
    } else {
      response = await http.delete(
        'https://new-firebase-82fdf.firebaseio.com/products/${selectedProduct.id}/wishlistUsers/${authenticatedUser.id}.json?auth=${authenticatedUser.token}',
      );
    }
    if (response.statusCode != 200 && response.statusCode != 201) {
      final Product updatedProduct = Product(
          id: selectedProduct.id,
          title: selectedProduct.title,
          description: selectedProduct.description,
          price: selectedProduct.price,
          image: selectedProduct.image,
          userEmail: selectedProduct.userEmail,
          userId: selectedProduct.userId,
          isFavourite: !newFavouriteStatus);
      products[selectedProductIndex] = updatedProduct;
      selProductId = null;
      notifyListeners();
    }
  }

  void toggleDisplayMode() {
    _showFavorites = !_showFavorites;
    notifyListeners();
  }

  Future<Null> fetchProducts() {
    _isLoading = true;
    notifyListeners();
    return http
        .get(
            'https://new-firebase-82fdf.firebaseio.com/products.json?auth=${authenticatedUser.token}')
        .then((http.Response response) {
      final List<Product> fetchedProductList = [];
      final Map<String, dynamic> productListData = json.decode(response.body);
      if (productListData == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }
      productListData.forEach((String productId, dynamic productData) {
        final Product product = Product(
            id: productId,
            title: productData['title'],
            description: productData['description'],
            price: productData['price'],
            image: productData['image'],
            userEmail: productData['userEmail'],
            userId: productData['userId'],
            isFavourite: productData['wishlistUsers'] == null
                ? false
                : (productData['wishlistUsers'] as Map<String, dynamic>)
                    .containsKey(authenticatedUser.id));
        fetchedProductList.add(product);
      });
      products = fetchedProductList;
      _isLoading = false;
      notifyListeners();
      selProductId = null;
    });
  }
}
mixin UtilityModel on ProductsModel {
  bool get isLoading {
    return _isLoading;
  }

  bool get postIsLoading {
    return _postisLoading;
  }
}
