import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/scheduler.dart';
import 'package:ta_visualisasi/configure/constants.dart';
import 'package:ta_visualisasi/user/sign_in.dart';

FirebaseAuth auth = FirebaseAuth.instance;
DatabaseReference dbRef = FirebaseDatabase.instance.ref().child("users");

class SignUp extends StatefulWidget {
  static const routeName = "/SignUp";

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool _passwordVisible1 = false;
  bool _passwordVisible2 = false;
  static bool visible = false;

  void initState() {
    super.initState();
    visible = false;
  }

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _userPasswordController1 = TextEditingController();
  TextEditingController _userPasswordController2 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.93,
                height: MediaQuery.of(context).size.height * 0.6,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(35),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text("Create Account",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 15.0, right: 15.0, top: 15, bottom: 0),
                            child: TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.mail_outline_rounded,
                                    color: Colors.black12,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(15.0),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black), // Warna garis saat difokuskan
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10.0), // Sudut border
                                    ),
                                  ),
                                  labelText: 'Email',
                                  hintText: 'example@gmail.com'),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 15.0, right: 15.0, top: 10, bottom: 0),
                            child: TextFormField(
                              controller: _usernameController,
                              keyboardType: TextInputType.name,
                              decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.account_circle_outlined,
                                    color: Colors.black12,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(15.0),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black), // Warna garis saat difokuskan
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10.0), // Sudut border
                                    ),
                                  ),
                                  labelText: 'User Name',
                                  hintText: 'example'),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 15.0, right: 15.0, top: 10.0, bottom: 0.0),
                            child: TextFormField(
                              keyboardType: TextInputType.visiblePassword,
                              controller: _userPasswordController1,
                              obscureText: !_passwordVisible1,
                              decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.lock_outline_rounded,
                                    color: Colors.black12,
                                  ),
                                  suffixIcon: IconButton(
                                      icon: Icon(
                                        _passwordVisible1
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: Colors.black12,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _passwordVisible1 = !_passwordVisible1;
                                        });
                                      }),
                                  hintStyle: TextStyle(color: Colors.white54),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(15.0),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black), // Warna garis saat difokuskan
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10.0), // Sudut border
                                    ),
                                  ),
                                  labelText: 'New Password',
                                  hintText: ''),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 15.0, right: 15.0, top: 10.0, bottom: 40.0),
                            child: TextFormField(
                              controller: _userPasswordController2,
                              obscureText: !_passwordVisible2,
                              keyboardType: TextInputType.visiblePassword,
                              decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.lock_outline_rounded,
                                    color: Colors.black12,
                                  ),
                                  suffixIcon: IconButton(
                                      icon: Icon(
                                        _passwordVisible2
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: Colors.black12,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _passwordVisible2 = !_passwordVisible2;
                                        });
                                      }),
                                  hintStyle: TextStyle(color: Colors.white54),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(15.0),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black), // Warna garis saat difokuskan
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10.0), // Sudut border
                                    ),
                                  ),
                                  labelText: 'Confirm New Password',
                                  hintText: ''),
                            ),
                          ),
                          Container(
                            height: 45,
                            width: MediaQuery.of(context).size.width / 2.25,
                            child: ElevatedButton(
                              onPressed: () {
                                if (!_emailController.text.contains('@')) {
                                  displayToastMessage('Enter a valid Email', context);
                                } else if (_usernameController.text.isEmpty) {
                                  displayToastMessage('Enter your name', context);
                                } else if (_userPasswordController1.text.length < 8) {
                                  displayToastMessage(
                                      'Password should be a minimum of 8 characters',
                                      context);
                                } else if (_userPasswordController1.text !=
                                    _userPasswordController2.text) {
                                  displayToastMessage(
                                      'Passwords don\'t match', context);
                                } else {
                                  setState(() {
                                    load();
                                  });
                                  registerNewUser(context);
                                }
                              },
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                backgroundColor: MaterialStateProperty.all<Color>(
                                  button,
                                ),
                              ),
                              child: Text(
                                'Register',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: textbutton),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, SignIn.routeName);
                            },
                            style: ButtonStyle(
                              overlayColor: MaterialStateColor.resolveWith((states) => Colors.transparent),
                            ),
                            child: Text('Have an account? Sign In', style: TextStyle(color: Colors.black)),
                          ),
                          Visibility(
                            maintainSize: true,
                            maintainAnimation: true,
                            maintainState: true,
                            visible: visible,
                            child: ClipRRect(
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                                child: Container(
                                    width: 290,
                                    margin: EdgeInsets.only(),
                                    child: LinearProgressIndicator(
                                      minHeight: 2,
                                      backgroundColor: Colors.blueGrey[800],
                                      valueColor: AlwaysStoppedAnimation(Colors.white),
                                    ))),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _userPasswordController1.dispose();
    _userPasswordController2.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> sendVerificationEmail(User user) async {
    await user.sendEmailVerification();
    displayToastMessage('A verification email has been sent to ${user.email}', context);
  }

  Future<void> registerNewUser(BuildContext context) async {
    User? currentUser;
    try {
      currentUser = (await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _userPasswordController1.text.trim())).user;

      if (currentUser != null) {
        await sendVerificationEmail(currentUser);

        // Check if the user already exists
        DatabaseEvent event = await dbRef.child(currentUser.uid).once();
        DataSnapshot snapshot = event.snapshot;
        if (!snapshot.exists) {
          // User does not exist, add user data
          Map<String, String> userDataMap = {
            'User Name': _usernameController.text.trim(),
            'Email': _emailController.text.trim(),
            'User UID' : currentUser.uid,
            'DataKendaraan' : '',
          };

          dbRef.child(currentUser.uid).set(userDataMap);
        }

        if (_formKey.currentState != null) {
          _formKey.currentState!.save();
        }

        SchedulerBinding.instance.addPostFrameCallback((_) {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => SignIn()));
        });

        displayToastMessage('Account created successfully', context);
      }
    } catch (e) {
      displayToastMessage('Error: $e', context);
      load();
    }
  }

  void showInSnackBar(String value, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(value),
      backgroundColor: Colors.white,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 1),
    ));
  }

  void displayToastMessage(String message, BuildContext context) {
    Fluttertoast.showToast(msg: message);
  }

  void load() {
    setState(() {
      visible = !visible;
    });
  }
}


// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:flutter/scheduler.dart';
// import 'package:ta_visualisasi/configure/constants.dart';
// import 'package:ta_visualisasi/user/sign_in.dart';
//
// FirebaseAuth auth = FirebaseAuth.instance;
// DatabaseReference dbRef = FirebaseDatabase.instance.reference().child("users");
//
//
// class SignUp extends StatefulWidget {
//   static const routeName = "/SignUp";
//
//   @override
//   _SignUpState createState() => _SignUpState();
// }
//
// class _SignUpState extends State<SignUp> {
//   bool _passwordVisible1 = false;
//   bool _passwordVisible2 = false;
//   static bool visible = false;
//
//   void initState() {
//     super.initState();
//     visible = false;
//   }
//
//   GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   TextEditingController _emailController = TextEditingController();
//   TextEditingController _usernameController = TextEditingController();
//   TextEditingController _userPasswordController1 = TextEditingController();
//   TextEditingController _userPasswordController2 = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       //backgroundColor: Colors.transparent,
//       backgroundColor: background,
//       // appBar: AppBar(
//       //   title: Text("Login Page", ),
//       // ),
//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             child: Form(
//               key: _formKey,
//               child: Container(
//                 width: MediaQuery.of(context).size.width * 0.93,
//                 height: MediaQuery.of(context).size.height * 0.6, // Mengatur tinggi kontainer menjadi setengah dari tinggi layar
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.5),
//                   borderRadius: BorderRadius.circular(35),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Center(
//                     child: SingleChildScrollView(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: <Widget>[
//                           // Container(
//                           //   padding: const EdgeInsets.only(top: 150.0, bottom: 50),
//                           //   child: (Text(
//                           //     'Create Account',)),
//                           // ),
//                           // const SizedBox(
//                           //   height: 20,
//                           // ),
//                           // Row(
//                           //   mainAxisAlignment: MainAxisAlignment.center,
//                           //   children: [
//                           //     Container(
//                           //       width: 35,
//                           //       height: 35,
//                           //       decoration: const BoxDecoration(
//                           //         image: DecorationImage(
//                           //           image: AssetImage('assets/images/black_box.png'),
//                           //         ),
//                           //       ),
//                           //     ),
//                           //     SizedBox(width: 10,),
//                           //     Text("Black Box Visualisasi")
//                           //   ],
//                           // ),
//                           // const SizedBox(
//                           //   height: 5.0,
//                           // ),
//                           // Text("Sign Up", style: TextStyle(fontWeight: FontWeight.bold,)),
//                           // // Text("Create Account"),
//                           // const SizedBox(
//                           //   height: 45.0,
//                           // ),
//
//                           Padding(
//                             padding: const EdgeInsets.all(10.0),
//                             child: Text("Create Account",
//                                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
//                           ),
//                           Padding(
//                             // padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
//                             padding: const EdgeInsets.only(
//                                 left: 15.0, right: 15.0, top: 15, bottom: 0),
//                             //  padding: EdgeInsets.symmetric(horizontal: 15),
//                             child: TextFormField(
//                               // cursorColor: Color.fromRGBO(20, 26, 70, 1.0),
//                               controller: _emailController,
//                               keyboardType: TextInputType.emailAddress,
//                               // style: TextStyle(color: Colors.white),
//                               decoration: InputDecoration(
//                                   prefixIcon: Icon(
//                                     // Based on passwordVisible state choose the icon
//                                     Icons.mail_outline_rounded,
//                                     color: Colors.black12,
//                                   ),
//                                   // filled: true,
//                                   // fillColor: Colors.black12,
//                                   // hintStyle: TextStyle(color: Colors.white54),
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.all(
//                                       Radius.circular(15.0), // Set the border radius to 20
//                                     ),
//                                   ),
//                                   // enabledBorder: OutlineInputBorder(
//                                   //   //gapPadding: 4.0,
//                                   //   //borderRadius: BorderRadius.all(Radius.circular(5.0)),
//                                   //   borderSide:
//                                   //   BorderSide(color: Colors.white, width: 0.5),
//                                   // ),
//                                   // focusedBorder: OutlineInputBorder(
//                                   //   //gapPadding: .0,
//                                   //   //borderRadius: BorderRadius.all(Radius.circular(5.0)),
//                                   //   borderSide:
//                                   //   BorderSide(color: Colors.white, width: 1.5),
//                                   // ),
//                                   labelText: 'Email',
//                                   hintText: 'example@gmail.com'),
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.only(
//                                 left: 15.0, right: 15.0, top: 10, bottom: 0),
//                             //  padding: EdgeInsets.symmetric(horizontal: 15),
//                             child: TextFormField(
//                               //cursorColor: Color.fromRGBO(20, 26, 70, 1.0),
//                               controller: _usernameController,
//                               keyboardType: TextInputType.name,
//                               // style: TextStyle(color: Colors.white),
//                               decoration: InputDecoration(
//                                   prefixIcon: Icon(
//                                     // Based on passwordVisible state choose the icon
//                                     Icons.account_circle_outlined,
//                                     color: Colors.black12,
//                                   ),
//                                   // filled: true,
//                                   // fillColor: Colors.black12,
//                                   // hintStyle: TextStyle(color: Colors.white54),
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.all(
//                                       Radius.circular(15.0), // Set the border radius to 20
//                                     ),
//                                   ),
//                                   // enabledBorder: OutlineInputBorder(
//                                   //   //gapPadding: 4.0,
//                                   //   //borderRadius: BorderRadius.all(Radius.circular(5.0)),
//                                   //   borderSide:
//                                   //   BorderSide(color: Colors.white, width: 0.5),
//                                   // ),
//                                   // focusedBorder: OutlineInputBorder(
//                                   //   //gapPadding: .0,
//                                   //   //borderRadius: BorderRadius.all(Radius.circular(5.0)),
//                                   //   borderSide:
//                                   //   BorderSide(color: Colors.white, width: 1.5),
//                                   // ),
//                                   labelText: 'User Name',
//                                   hintText: 'example'),
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.only(
//                                 left: 15.0, right: 15.0, top: 10.0, bottom: 0.0),
//                             //padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
//                             child: TextFormField(
//                               keyboardType: TextInputType.visiblePassword,
//                               controller: _userPasswordController1,
//                               obscureText: !_passwordVisible1,
//                               // style: TextStyle(color: Colors.white),
//                               decoration: InputDecoration(
//                                   prefixIcon: Icon(
//                                     // Based on passwordVisible state choose the icon
//                                     Icons.lock_outline_rounded,
//                                     color: Colors.black12,
//                                   ),
//                                   suffixIcon: IconButton(
//                                       icon: Icon(
//                                         // Based on passwordVisible state choose the icon
//                                         _passwordVisible1
//                                             ? Icons.visibility
//                                             : Icons.visibility_off,
//                                         color: Colors.black12,
//                                       ),
//                                       onPressed: () {
//                                         // Update the state i.e. toogle the state of passwordVisible variable
//                                         setState(() {
//                                           _passwordVisible1 = !_passwordVisible1;
//                                         });
//                                       }),
//                                   // filled: true,
//                                   // fillColor: Colors.black12,
//                                   hintStyle: TextStyle(color: Colors.white54),
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.all(
//                                       Radius.circular(15.0), // Set the border radius to 20
//                                     ),
//                                   ),
//                                   // enabledBorder: OutlineInputBorder(
//                                   //   borderRadius:
//                                   //   BorderRadius.all(Radius.circular(5.0)),
//                                   //   borderSide:
//                                   //   BorderSide(color: Colors.white, width: 0.5),
//                                   // ),
//                                   // focusedBorder: OutlineInputBorder(
//                                   //   borderRadius:
//                                   //   BorderRadius.all(Radius.circular(5.0)),
//                                   //   borderSide:
//                                   //   BorderSide(color: Colors.white, width: 1.5),
//                                   // ),
//                                   // //width: 16.0, color: Colors.lightBlue.shade50),
//                                   // //bottom: BorderSide(width: 16.0, color: Colors.lightBlue.shade900),
//
//                                   labelText: 'New Password',
//                                   hintText: ''),
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.only(
//                                 left: 15.0, right: 15.0, top: 10.0, bottom: 40.0),
//                             //padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
//                             child: TextFormField(
//                               controller: _userPasswordController2,
//                               obscureText: !_passwordVisible2,
//                               keyboardType: TextInputType.visiblePassword,
//                               // style: TextStyle(color: Colors.white),
//                               decoration: InputDecoration(
//                                   prefixIcon: Icon(
//                                     // Based on passwordVisible state choose the icon
//                                     Icons.lock_outline_rounded,
//                                     color: Colors.black12,
//                                   ),
//                                   suffixIcon: IconButton(
//                                       icon: Icon(
//                                         _passwordVisible2
//                                             ? Icons.visibility
//                                             : Icons
//                                             .visibility_off, // Based on passwordVisible state choose the icon
//                                         color: Colors.black12,
//                                       ),
//                                       onPressed: () {
//                                         setState(() {
//                                           _passwordVisible2 =
//                                           !_passwordVisible2; // Update the state i.e. toogle the state of passwordVisible variable
//                                         });
//                                       }),
//                                   // filled: true,
//                                   // fillColor: Colors.black12,
//                                   hintStyle: TextStyle(color: Colors.white54),
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.all(
//                                       Radius.circular(15.0), // Set the border radius to 20
//                                     ),
//                                   ),
//                                   // enabledBorder: OutlineInputBorder(
//                                   //   borderRadius:
//                                   //   BorderRadius.all(Radius.circular(5.0)),
//                                   //   borderSide:
//                                   //   BorderSide(color: Colors.white, width: 0.5),
//                                   // ),
//                                   // focusedBorder: OutlineInputBorder(
//                                   //   borderRadius:
//                                   //   BorderRadius.all(Radius.circular(5.0)),
//                                   //   borderSide:
//                                   //   BorderSide(color: Colors.white, width: 1.5),
//                                   // ),
//                                   labelText: 'Confirm New Password',
//                                   hintText: ''),
//                             ),
//                           ),
//                           Container(
//                             height: 45,
//                             // width: 350,
//                             width: MediaQuery.of(context).size.width / 2.25,
//                             //padding: const EdgeInsets.only(bottom: 50.0),
//                             // decoration: BoxDecoration(
//                             //     color: Colors.deepPurple[900],
//                             //     borderRadius: BorderRadius.circular(30)),
//                             child: ElevatedButton(
//                               onPressed: () {
//                                 if (!_emailController.text.contains('@')) {
//                                   displayToastMessage('Enter a valid Email', context);
//                                 } else if (_usernameController.text.isEmpty) {
//                                   displayToastMessage('Enter your name', context);
//                                 } else if (_userPasswordController1.text.length < 8) {
//                                   displayToastMessage(
//                                       'Password should be a minimum of 8 characters',
//                                       context);
//                                 } else if (_userPasswordController1.text !=
//                                     _userPasswordController2.text) {
//                                   displayToastMessage(
//                                       'Passwords don\'t match', context);
//                                 } else {
//                                   setState(() {
//                                     load();
//                                     //   showInSnackBar('Processing...',context);
//                                   });
//                                   registerNewUser(context);
//                                 }
//                               },
//                               style: ButtonStyle(
//                                 shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//                                   RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(15), // Adjust the corner radius as desired
//
//                                   ),
//                                 ),
//                                 backgroundColor: MaterialStateProperty.all<Color>(
//                                   button,
//                                   //const Color.fromRGBO(20, 26, 70, 1.0), // Red color (RGB: 255, 0, 0)
//                                 ),
//                               ),
//                               child: Text(
//                                 'Register',
//                                 //style: TextStyle(color: Colors.white, fontSize: 20,),
//                                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: textbutton),),
//                               // style: ElevatedButton.styleFrom(
//                               //   primary: Colors.black45,
//                               //   onPrimary: Colors.white,
//                               //   shadowColor: Colors.black45,
//                               //   elevation: 8,
//                               //   //side: BorderSide(color: Colors.white70),
//                               //   shape: RoundedRectangleBorder(
//                               //     borderRadius: BorderRadius.circular(10.0),
//                               //     side: BorderSide(
//                               //       color: Colors.white70,
//                               //       width: 2,
//                               //     ),
//                               //   ),
//                               // ),
//                             ),
//                           ),
//                           const SizedBox(
//                             height: 10.0,
//                           ),
//                           TextButton(
//                             onPressed: () {
//                               Navigator.pushNamed(context, SignIn.routeName);
//                             },
//                             style: ButtonStyle(
//                               overlayColor: MaterialStateColor.resolveWith((states) => Colors.transparent), // Mengatur overlay color menjadi transparent
//                             ),
//                             child: Text('Have an account? Sign In',style: TextStyle(color: Colors.black),),
//                           ),
//                           Visibility(
//                             maintainSize: true,
//                             maintainAnimation: true,
//                             maintainState: true,
//                             visible: visible,
//                             child: ClipRRect(
//                                 borderRadius: BorderRadius.all(Radius.circular(10)),
//                                 child: Container(
//                                     width: 290,
//                                     margin: EdgeInsets.only(),
//                                     child: LinearProgressIndicator(
//                                       minHeight: 2,
//                                       backgroundColor: Colors.blueGrey[800],
//                                       valueColor: AlwaysStoppedAnimation(Colors.white),
//                                     ))),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     // Clean up the controller when the widget is disposed.
//     _emailController.dispose();
//     _userPasswordController1.dispose();
//     _userPasswordController2.dispose();
//     _usernameController.dispose();
//     super.dispose();
//   }
//
//   Future<void> sendVerificationEmail(User user) async {
//     await user.sendEmailVerification();
//
//     displayToastMessage(
//         'A verification email has been sent to ${user.email}', context);
//   }
//
//   //final FirebaseAuth auth = FirebaseAuth.instance ;
//   Future<void> registerNewUser(BuildContext context) async {
//     User? currentuser;
//     try {
//       currentuser = (await FirebaseAuth.instance.createUserWithEmailAndPassword(
//           email: _emailController.text.trim(),
//           password: _userPasswordController1.text.trim()))
//           .user;
//       if (currentuser != null) {
//         await _sendEmailVerification(currentuser);
//         dbRef.child(currentuser.uid);
//         Map userDataMap = {
//           'name': _usernameController.text.trim(),
//           'email': _emailController.text.trim(),
//           'DataKendaraan' : '',
//         };
//         dbRef.child(currentuser.uid).set(userDataMap);
//         if (_formKey.currentState != null) {
//           _formKey.currentState!.save();
//         }
//         SchedulerBinding.instance.addPostFrameCallback((_) {
//           Navigator.push(context,
//               MaterialPageRoute(builder: (BuildContext context) => SignIn()));
//         });
//         showInSnackBar('Account Created', context);
//       } else {
//         setState(() {
//           load();
//           //   showInSnackBar('Processing...',context);
//         });
//         displayToastMessage('Account has not been created', context);
//       }
//     } catch (e) {
//       setState(() {
//         load();
//         //   showInSnackBar('Processing...',context);
//       });
//       displayToastMessage(e.toString(), context);
//     }
//   }
//
//   Future<void> _sendEmailVerification(User user) async {
//     try {
//       await user.sendEmailVerification();
//       displayToastMessage('Verification email sent', context);
//     } catch (e) {
//       print("An error occurred while sending email verification: $e");
//     }
//   }
//
//
//   void load() {
//     visible = !visible;
//   }
// }
//
// displayToastMessage(String msg, BuildContext context) {
//   Fluttertoast.showToast(msg: msg);
// }
//
// void showInSnackBar(String value, BuildContext context) {
//   ScaffoldMessenger.of(context)
//       .showSnackBar(new SnackBar(content: new Text(value)));
// }
