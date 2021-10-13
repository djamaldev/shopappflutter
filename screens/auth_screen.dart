import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopapp/providers/auth.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({Key? key}) : super(key: key);
  static const routName = '/Auth';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
              colors: [
                Color.fromRGBO(0, 0, 139, 1).withOpacity(0.5),
                Color.fromRGBO(39, 0, 42, 1).withOpacity(0.5),
              ],
              begin: Alignment.topLeft,
              end: Alignment.topRight,
              stops: [0, 1],
            )),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 20),
                      padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 94),
                      transform: Matrix4.rotationZ(-8 * pi / 180)
                        ..translate(-10.0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.deepOrange.shade900,
                          boxShadow: [
                            BoxShadow(
                                blurRadius: 8,
                                color: Colors.black26,
                                offset: Offset(0, 2))
                          ]),
                      child: Text(
                        "My Shop",
                        style: TextStyle(
                            color: theme.textTheme.headline6!.color,
                            fontSize: 50,
                            fontFamily: 'Anton'),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: AuthCard(),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({Key? key}) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

enum AuthMode { Login, Signup }

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {'email': '', 'password': ''};
  var _isLoading = false;
  final _passController = TextEditingController();
  AnimationController? _controller;
  Animation<Offset>? _slideAnimation;
  Animation<double>? _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _slideAnimation = Tween<Offset>(begin: Offset(0, -0.15), end: Offset(0, 0))
        .animate(
            CurvedAnimation(parent: _controller!, curve: Curves.fastOutSlowIn));
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller!, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    super.dispose();
    _controller!.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    FocusScope.of(context).unfocus();
    _formKey.currentState?.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_authMode == AuthMode.Login) {
        await Provider.of<Auth>(context, listen: false).login(
            _authData['email'] as String, _authData['password'] as String);
      } else {
        await Provider.of<Auth>(context, listen: false).signUp(
            _authData['email'] as String, _authData['password'] as String);
        print('errrrrrrrrrrrrrr');
      }
    } on HttpException catch (error) {
      var errorMessage = error.toString();
      if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'This email is already in use!';
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errorMessage = 'This is not a valid email!';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMessage = 'This password is too weak!';
      }
      if (error.toString().contains('EMAIL__NOT_FOUND')) {
        errorMessage = 'Could not find a user with that email!';
      }
      if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'invalid password!';
      }
      _showMessageError(errorMessage);
    } catch (error) {
      const errorMessage = 'Somthing went wrong! Please try later';
      _showMessageError(errorMessage);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _showMessageError(String message) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text("an error occured"),
              content: Text(message),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      primary: Theme.of(context).primaryColor,
                      textStyle: TextStyle(
                          color: Theme.of(context).textTheme.headline6?.color)),
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text("okey"),
                )
              ],
            ));
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
      _controller!.forward();
    } else {
      if (_authMode == AuthMode.Signup) {
        setState(() {
          _authMode = AuthMode.Login;
        });
        _controller!.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 8.0,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
        height: _authMode == AuthMode.Signup ? 400 : 300,
        constraints: BoxConstraints(
          minHeight: _authMode == AuthMode.Signup ? 400 : 350,
        ),
        width: deviceSize.width * 0.75,
        padding: EdgeInsets.all(30),
        child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: 'E_mail'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) {
                      if (val!.isEmpty || !val.contains('@')) {
                        return 'Invalid email';
                      }
                      return null;
                    },
                    onSaved: (val) => _authData['email'] = val!,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    controller: _passController,
                    validator: (val) {
                      if (val!.isEmpty || val.length < 5) {
                        return 'Password is too short';
                      }
                      return null;
                    },
                    onSaved: (val) => _authData['password'] = val!,
                  ),
                  AnimatedContainer(
                    constraints: BoxConstraints(
                        minHeight: _authMode == AuthMode.Signup ? 60 : 0,
                        maxHeight: _authMode == AuthMode.Signup ? 170 : 0),
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                    child: FadeTransition(
                        opacity: _opacityAnimation!,
                        child: SlideTransition(
                          position: _slideAnimation!,
                          child: TextFormField(
                            decoration:
                                InputDecoration(labelText: 'Confirm password'),
                            obscureText: true,
                            validator: _authMode == AuthMode.Signup
                                ? (val) {
                                    if (val != _passController.text) {
                                      return 'Password do not match!';
                                    }
                                    return null;
                                  }
                                : null,
                          ),
                        )),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  if (_isLoading) CircularProgressIndicator(),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 30),
                    child: ElevatedButton(
                      child: Text(
                          _authMode == AuthMode.Login ? 'LOGIN' : 'SIGNUP'),
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          primary: Theme.of(context).primaryColor,
                          textStyle: TextStyle(
                              color: Theme.of(context)
                                  .textTheme
                                  .headline6
                                  ?.color)),
                      onPressed: _submit,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 30),
                    child: TextButton(
                        style: TextButton.styleFrom(
                            primary: Theme.of(context).primaryColor,
                            textStyle: TextStyle(
                                color: Theme.of(context).primaryColor)),
                        onPressed: _switchAuthMode,
                        child: Text(
                            '${_authMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'} INSTEAD')),
                  )
                ],
              ),
            )),
      ),
    );
  }
}
