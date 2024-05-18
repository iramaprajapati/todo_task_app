import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_task_app/screens/register_screen.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
           body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 100,
                ),
                Text('Todo Login',style: TextStyle(
                    color: Colors.black,
                    fontSize: 30,
                    fontWeight:
                    FontWeight.w500)),
                SizedBox(height: 8),

                Text('Enter your credential to login',style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight:
                    FontWeight.w400)),
                SizedBox(height: 60,),
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) => value!.isEmpty ? 'Enter an email' : null,
                  onChanged: (value) {
                    setState(() => _email = value);
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                  ),

                  obscureText: true,
                  validator: (value) =>
                      value!.length < 6 ? 'Password too short' : null,
                  onChanged: (value) {
                    setState(() => _password = value);
                  },

                ),
                SizedBox(height: 30),
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await Provider.of<AuthService>(context, listen: false)
                            .signInWithEmail(_email, _password);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    ),
                    child: Text('Login',style: TextStyle(
                      fontSize: 16,
                        color: Colors.black,
                        fontWeight:
                        FontWeight.w600)),
                  ),
                ),
                SizedBox(height: 100),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              RegisterScreen()), // Navigate to the register screen
                    );
                  },
                  child: Text(
                    'Don\'t have an account? Sign up here!',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
