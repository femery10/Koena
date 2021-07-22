import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expandable_listview_example/page/home_screen.dart';
import 'package:expandable_listview_example/page/login_screen.dart';
import 'package:expandable_listview_example/validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'auth.dart';
import 'classes/users.dart';
import 'custom_form_field.dart';

class RegisterForm extends StatefulWidget {
  final FocusNode nameFocusNode;
  final FocusNode emailFocusNode;
  final FocusNode passwordFocusNode;

  const RegisterForm({
    Key? key,
    required this.nameFocusNode,
    required this.emailFocusNode,
    required this.passwordFocusNode,
  }) : super(key: key);
  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final kuserRef =
  FirebaseFirestore.instance.collection('users').withConverter<KUser>(
    fromFirestore: (snapshot, _) => KUser.fromJson(snapshot.data()!),
    toFirestore: (kuser, _) => kuser.toJson(),
  );


  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  int userIdNumCounter = 0;
  createUserProfile(String name, String email) async
  {
    FirebaseFirestore.instance
        .collection('users')
        .orderBy('userId', descending: false)
        .limitToLast(1)
        .get()
        .then((QuerySnapshot querySnapshot) async {
      querySnapshot.docs.forEach((doc) {
        setState(() {
          userIdNumCounter = doc["userId"] + 1;
        });
      });
      await kuserRef.add(
        KUser(userId: userIdNumCounter, email: _emailController.text, name: _nameController.text),
      );
    });
  }


  final _registerFormKey = GlobalKey<FormState>();

  bool _isSigningUp = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _registerFormKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 8.0,
              right: 8.0,
            ),
            child: Column(
              children: [
                CustomFormField(
                  controller: _nameController,
                  focusNode: widget.nameFocusNode,
                  keyboardType: TextInputType.name,
                  inputAction: TextInputAction.next,
                  isCapitalized: true,
                  validator: (value) => Validator.validateName(
                    name: value,
                  ),
                  label: 'Name',
                  hint: 'Enter your name',
                ),
                SizedBox(height: 16.0),
                CustomFormField(
                  controller: _emailController,
                  focusNode: widget.emailFocusNode,
                  keyboardType: TextInputType.emailAddress,
                  inputAction: TextInputAction.next,
                  validator: (value) => Validator.validateEmail(
                    email: value,
                  ),
                  label: 'Email',
                  hint: 'Enter your email',
                ),
                SizedBox(height: 16.0),
                CustomFormField(
                  controller: _passwordController,
                  focusNode: widget.passwordFocusNode,
                  keyboardType: TextInputType.text,
                  inputAction: TextInputAction.done,
                  validator: (value) => Validator.validatePassword(
                    password: value,
                  ),
                  isObscure: true,
                  label: 'Password',
                  hint: 'Enter your password',
                ),
              ],
            ),
          ),
          SizedBox(height: 24.0),
          _isSigningUp
              ? Padding(
            padding: const EdgeInsets.all(16.0),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.blue,
              ),
            ),
          )
              : Padding(
            padding: EdgeInsets.only(left: 0.0, right: 0.0),
            child: Container(
              width: double.maxFinite,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                      Colors.blue
                  ),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                onPressed: () async {
                  widget.emailFocusNode.unfocus();
                  widget.passwordFocusNode.unfocus();

                  createUserProfile(_nameController.text, _emailController.text);

                  setState(() {
                    _isSigningUp = true;
                  });

                  if (_registerFormKey.currentState!.validate()) {
                    User? user =
                    await Authentication.registerUsingEmailPassword(
                      name: _nameController.text,
                      email: _emailController.text,
                      password: _passwordController.text,
                      context: context,
                    );

                    if (user != null) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                            builder: (context) => HomeScreen()
                        ),
                      );
                    }
                  }

                  setState(() {
                    _isSigningUp = false;
                  });
                },
                child: Padding(
                  padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
                  child: Text(
                    'REGISTER',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 16.0),
          InkWell(
            onTap: () {
              Navigator.of(context)
                  .pushReplacement(_routeToSignInScreen());
            },
            child: Text(
              'Already have an account? Sign in',
              style: TextStyle(
                color: Colors.black,
                letterSpacing: 0.5,
              ),
            ),
          )
        ],
      ),
    );
  }
}

Route _routeToSignInScreen() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => SignInScreen(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(-1.0, 0.0);
      var end = Offset.zero;
      var curve = Curves.ease;

      var tween =
      Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}