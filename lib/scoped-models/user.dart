import 'package:scoped_model/scoped_model.dart';
import '../models/user.dart';
import './connected_product.dart';

mixin  UserModel on ConnectedProducts {


  void login(String email, String password) {
    authenticatedUser = User(id: 'one', email: email, password: password);
  }
}