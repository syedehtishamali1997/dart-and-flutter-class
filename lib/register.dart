import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  //==================== Text Edit Controller ====================
  TextEditingController name=TextEditingController();
  TextEditingController age=TextEditingController();
  TextEditingController email=TextEditingController();
  TextEditingController password=TextEditingController();

   //==================== Firestore ====================
    final CollectionReference std=FirebaseFirestore.instance.collection("customer");

    //==================== Add User ====================
    Future<void> addUser(BuildContext context)async{
      await std.add({
          's_name':name.text.trim(),
          's_age':age.text.trim(),
          's_email':email.text.trim(),
          's_password':password.text.trim(),
          'role':"user"
      });

      // ignore: use_build_context_synchronously
      Navigator.pushNamed(context, '/login');
    }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(padding: EdgeInsetsGeometry.all(20),
      child: Column(
        children: [
          TextFormField(
            controller: name,
            decoration: InputDecoration(labelText: "Name"),
          ),

          TextFormField(
            controller: age,
            decoration: InputDecoration(labelText: "Age"),
          ),

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
          ElevatedButton(onPressed: ()async{await addUser(context);}, child: Text("register"))
        ],
      ),
      ),
    );
  }
}