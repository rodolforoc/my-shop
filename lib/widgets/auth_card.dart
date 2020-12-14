import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/exceptions/auth_exception.dart';
import '../providers/auth.dart';

enum AuthMode {
  Signup,
  Login,
}

class AuthCard extends StatefulWidget {
  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  GlobalKey<FormState> _form = GlobalKey();
  bool _isLoading = false;
  AuthMode _authMode = AuthMode.Login;
  final _passwordController = TextEditingController();

  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };

  void _showErrorDialog(String msg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Ocorreu um erro!'),
        content: Text(msg),
        actions: [
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Fechar'),
          )
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_form.currentState.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });

    _form.currentState.save();

    Auth auth = Provider.of<Auth>(context, listen: false);

    try {
      if (_authMode == AuthMode.Login) {
        await auth.signin(
          _authData["email"],
          _authData["password"],
        );
      } else {
        await auth.signup(
          _authData["email"],
          _authData["password"],
        );
      }
    } on AuthException catch (error) {
      _showErrorDialog(error.toString());
    } catch (error) {
      _showErrorDialog("Ocorreu um erro inesperado!");
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      elevation: 8.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Container(
        height: _authMode == AuthMode.Login ? 310 : 330,
        width: deviceSize.width * 0.75,
        padding: EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'E-mail',
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value.isEmpty || !value.contains('@')) {
                    return "Informe um email válido";
                  }
                  return null;
                },
                onSaved: (value) => _authData['email'] = value,
              ),
              TextFormField(
                obscureText: true,
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Senha',
                ),
                textInputAction: _authMode == AuthMode.Login
                    ? TextInputAction.done
                    : TextInputAction.next,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value.isEmpty || value.length < 5) {
                    return "Informe uma senha válida";
                  }
                  return null;
                },
                onSaved: (value) => _authData['password'] = value,
              ),
              if (_authMode == AuthMode.Signup)
                TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirmar Senha',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: _authMode == AuthMode.Signup
                      ? (value) {
                          if (value != _passwordController.text) {
                            return "Senhas são diferentes!";
                          }
                          return null;
                        }
                      : null,
                ),
              SizedBox(
                height: 20,
              ),
              _isLoading
                  ? CircularProgressIndicator()
                  : RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      color: Theme.of(context).primaryColor,
                      textColor:
                          Theme.of(context).primaryTextTheme.button.color,
                      padding: EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 8,
                      ),
                      child: Text(
                        _authMode == AuthMode.Login ? 'ENTRAR' : 'REGISRTAR',
                      ),
                      onPressed: _submit,
                    ),
              FlatButton(
                onPressed: _switchAuthMode,
                child: Text(
                  "ALTERNAR PARA ${_authMode == AuthMode.Login ? 'REGISTRAR' : 'LOGIN'}",
                ),
                textColor: Theme.of(context).primaryColor,
              )
            ],
          ),
        ),
      ),
    );
  }
}
