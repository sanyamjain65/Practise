import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../scoped-models/main.dart';
import '../models/auth.dart';



class AuthPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _AuthPageState();
  }
}

class _AuthPageState extends State<AuthPage> {
  String _emailValue = '';
  String _passwordValue = '';
  bool _acceptTerms = false;
  final TextEditingController _passwordTextController = TextEditingController();
  AuthMode _authMode = AuthMode.Login;

  DecorationImage _buildBackgroundImage() {
    return DecorationImage(
      fit: BoxFit.cover,
      colorFilter:
          ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.dstATop),
      image: AssetImage('assets/background.jpg'),
    );
  }

  Widget _buildEmailTextField() {
    return TextField(
      decoration: InputDecoration(
        labelText: 'Email',
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: TextInputType.emailAddress,
      onChanged: (String value) {
        setState(() {
          _emailValue = value;
        });
      },
    );
  }

  Widget _buildConfirmPasswordTextField() {
    return TextField(
      decoration: InputDecoration(
        labelText: 'Confirm Password',
        filled: true,
        fillColor: Colors.white,
      ),
      obscureText: true,
      onChanged: (String value) {
        setState(() {
//          if (_passwordTextController.text != value) {
//            print('password do not match');
//            return;
//          }
          _passwordValue = value;
        });
      },
    );
  }

  Widget _buildPasswordTextField() {
    return TextField(
      decoration: InputDecoration(
        labelText: 'Password',
        fillColor: Colors.white,
        filled: true,
      ),
      controller: _passwordTextController,
      obscureText: true,
      onChanged: (String value) {
        setState(() {
          _passwordValue = value;
        });
      },
    );
  }

  Widget _buildAcceptSwitch() {
    return SwitchListTile(
      value: _acceptTerms,
      title: Text('Accept Terms'),
      onChanged: (bool value) {
        setState(() {
          _acceptTerms = value;
        });
      },
    );
  }

  void _submitForm(Function authenticate) async {
    Map<String, dynamic> successInformation;
      successInformation =
          await authenticate(_emailValue, _passwordValue, _authMode);
    if (successInformation['success']) {
//      Navigator.pushReplacementNamed(context, '/');
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('An Error Occured'),
              content: Text(successInformation['message']),
              actions: <Widget>[
                FlatButton(
                  child: Text('Okay'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.95;
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: _buildBackgroundImage(),
        ),
        padding: EdgeInsets.all(10.0),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: targetWidth,
              child: Column(
                children: <Widget>[
                  _buildEmailTextField(),
                  SizedBox(
                    height: 10.0,
                  ),
                  _buildPasswordTextField(),
                  SizedBox(
                    height: 10.0,
                  ),
                  _authMode == AuthMode.Signup
                      ? _buildConfirmPasswordTextField()
                      : Container(),
                  SizedBox(
                    height: 10.0,
                  ),
                  _buildAcceptSwitch(),
                  SizedBox(
                    height: 10.0,
                  ),
                  FlatButton(
                    child: Text(
                        'Switch to ${_authMode == AuthMode.Login ? 'Signup' : 'Login'}'),
                    onPressed: () {
                      setState(() {
                        _authMode = _authMode == AuthMode.Login
                            ? AuthMode.Signup
                            : AuthMode.Login;
                      });
                    },
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  ScopedModelDescendant<MainModel>(
                    builder:
                        (BuildContext context, Widget child, MainModel model) {
                      return model.isUserISLoading == true
                          ? CircularProgressIndicator()
                          : RaisedButton(
                              child: Text(_authMode == AuthMode.Login
                                  ? 'Login'
                                  : 'Signup'),
                              textColor: Colors.white,
                              onPressed: () =>
                                  _submitForm(model.authenticate),
                            );
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
