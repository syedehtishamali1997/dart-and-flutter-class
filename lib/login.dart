import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  bool hidePassword = true;
  bool loading = false;

  final CollectionReference data =
      FirebaseFirestore.instance.collection('customer');

  Future<void> login() async {
    // Empty fields check
    if (email.text.trim().isEmpty || password.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter email and password'),
        ),
      );

      return;
    }

    // Loading start
    setState(() {
      loading = true;
    });

    try {
      // Firebase se user search
      QuerySnapshot res = await data
          .where(
            's_email',
            isEqualTo: email.text.trim(),
          )
          .where(
            's_password',
            isEqualTo: password.text.trim(),
          )
          .get();

      // await ke baad mounted check
      if (!mounted) return;

      // User nahi mila
      if (res.docs.isEmpty) {
        setState(() {
          loading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid email or password'),
          ),
        );

        return;
      }

      // User data
      var users =
          res.docs.first.data() as Map<String, dynamic>;

      String role = users['role'];

      // Loading stop
      setState(() {
        loading = false;
      });

      // Admin
      if (role == "admin") {
        Navigator.pushNamed(
          context,
          '/dashboard',
        );
      }

      // User
      else if (role == "user") {
        Navigator.pushNamed(
          context,
          '/home',
        );
      }

      // Invalid role
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid user role'),
          ),
        );
      }
    } catch (e) {
      // Widget check
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
    }
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    body: Padding(padding: EdgeInsetsGeometry.all(20),
      child: Column(
        children: [

          TextFormField(
            controller: email,
            decoration: InputDecoration(labelText: "Email"),
          ),
          TextFormField(
            controller: password,
            obscureText: true,
            decoration: InputDecoration(labelText: "Password"),
          ),
          SizedBox(height: 20,),
          ElevatedButton(onPressed: ()async{await login();}, child: Text("Login"))
        ],
      ),
      ),
    );
  }
}

