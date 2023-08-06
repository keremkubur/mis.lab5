import 'package:flutter/cupertino.dart';
import 'package:mislab3/signup.dart';

import 'login.dart';

class AuthPage extends StatefulWidget{
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true;

  @override
  Widget build(BuildContext context) => isLogin
      ? LoginWidget(onClickedSignUp: toggle,)
      : SignUpWidget(onClickedSignIn: toggle);

  void toggle() => setState(() => isLogin = !isLogin);
}