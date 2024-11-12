import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/scheduler.dart';
import 'package:ta_visualisasi/configure/constants.dart';
import 'package:ta_visualisasi/user/sign_in.dart';
import 'package:fluttertoast/fluttertoast.dart';


FirebaseAuth auth = FirebaseAuth.instance;
DatabaseReference dbRef = FirebaseDatabase.instance.reference().child("users");

class ResetPassword extends StatefulWidget {
  static const routeName = "/ResetPassword";

  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  static bool visible = false;

  void initState() {
    super.initState();
    visible = false;
  }

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      //backgroundColor: Colors.transparent,
      backgroundColor: background,
      // appBar: AppBar(
      //   title: Text("Login Page", ),
      // ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.93,
                height: MediaQuery.of(context).size.height * 0.4, // Mengatur tinggi kontainer menjadi setengah dari tinggi layar
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(35),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          const SizedBox(
                            height: 20,
                          ),
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.center,
                          //   children: [
                          //     Container(
                          //       width: 35,
                          //       height: 35,
                          //       decoration: const BoxDecoration(
                          //         image: DecorationImage(
                          //           image: AssetImage('assets/images/black_box.png'),
                          //         ),
                          //       ),
                          //     ),
                          //     SizedBox(width: 10,),
                          //     Text("Black Box Visualisasi")
                          //   ],
                          // ),
                          const SizedBox(
                            height: 5.0,
                          ),
                          Text("Reset Password",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                          const SizedBox(
                            height: 20.0,
                          ),
                          Container(
                            padding: const EdgeInsets.only(),
                            child: (Text(
                              'Please enter your email below, \n to recieve your password reset instructions!',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                                fontWeight: FontWeight.normal
                              ),
                              textAlign: TextAlign.center,
                            )),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 15.0, right: 15.0, top: 20, bottom: 0),
                            //  padding: EdgeInsets.symmetric(horizontal: 15),
                            child: TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              // style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.mail_outline_rounded,
                                    color: Colors.black12,
                                  ),
                                  // filled: true,
                                  // fillColor: Colors.black12,
                                  hintText: 'example@gmail.com',
                                  // hintStyle: TextStyle(
                                  //   fontWeight: FontWeight.bold,
                                  // ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(15.0), // Set the border radius to 20
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black), // Warna garis saat difokuskan
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10.0), // Sudut border
                                    ),
                                  ),
                                  labelText: 'Email'),
                            ),
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
                                      margin: EdgeInsets.only(top: 10),
                                      child: LinearProgressIndicator(
                                        minHeight: 2,
                                        backgroundColor: Colors.blueGrey[800],
                                        valueColor: AlwaysStoppedAnimation(Colors.white),
                                      )))),
                          Container(
                            height: 45,
                            // width: 350,
                            width: MediaQuery.of(context).size.width / 2.25,
                            //padding: const EdgeInsets.only(bottom: 50.0),
                            // decoration: BoxDecoration(
                            //     color: Colors.deepPurple[900],
                            //     borderRadius: BorderRadius.circular(30)),
                            child: ElevatedButton(
                              onPressed: () {
                                if (_emailController.text.isEmpty) {
                                  displayToastMessage('Enter a valid Email', context);
                                }
                                else {
                                  setState(() {
                                    load();
                                  });
                                  resetPwd(context);
                                }
                              },
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15), // Adjust the corner radius as desired

                                  ),
                                ),
                                backgroundColor: MaterialStateProperty.all<Color>(
                                  // Colors.transparent
                                  button,
                                  //const Color.fromRGBO(20, 26, 70, 1.0), // Red color (RGB: 255, 0, 0)
                                ),
                              ),
                              child: Text(
                                'Reset Password',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: textbutton)
                                //style: TextStyle(color: Colors.white, fontSize: 20,),
                                // style: TextStyle(
                                //   fontSize: 19,
                                //   color: Colors.white,
                                //   fontWeight: FontWeight.w500,
                                // ),
                              ),
                              // style: ElevatedButton.styleFrom(
                              //   primary: Colors.black45,
                              //   onPrimary: Colors.white,
                              //   shadowColor: Colors.black45,
                              //   elevation: 8,
                              //   //side: BorderSide(color: Colors.white70),
                              //   shape: RoundedRectangleBorder(
                              //     borderRadius: BorderRadius.circular(10.0),
                              //     side: BorderSide(
                              //       color: Colors.white70,
                              //       width: 2,
                              //     ),
                              //   ),
                              //),
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
                              overlayColor: MaterialStateColor.resolveWith((states) => Colors.transparent), // Mengatur overlay color menjadi transparent
                            ),
                            child: Text('Have an account? Sign In',style: TextStyle(color: Colors.black),),
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

  Future<void> resetPwd(BuildContext context) async {
    // final ParseUser user = ParseUser(null, null, _emailidController.text.trim());
    try {
      await auth.sendPasswordResetEmail(email: _emailController.text.trim());
      displayToastMessage('Email has been sent to the given id', context);
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext context) => SignIn()));
      });
    } catch (e) {
      displayToastMessage(e.toString(), context);
      setState(() {
        load();
      });
      // Message.showError(context: context, message: parseResponse.error.message);
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _emailController.dispose();
    super.dispose();
  }

  void load() {
    visible = !visible;
  }

  void displayToastMessage(String message, BuildContext context) {
    Fluttertoast.showToast(msg: message);
  }
}
