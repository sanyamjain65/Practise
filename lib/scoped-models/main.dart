import 'package:scoped_model/scoped_model.dart';
import './products.dart';
import './user.dart';
import './connected_product.dart';
class MainModel extends Model with ConnectedProducts, UserModel, ProductsModel, UtilityModel {}