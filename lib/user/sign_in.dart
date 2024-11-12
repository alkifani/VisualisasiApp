import 'package:flutter/material.dart';
import 'package:ta_visualisasi/configure/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ta_visualisasi/pilih_plat/pilih_plat.dart';
import 'package:ta_visualisasi/user/auth_service.dart';
import 'package:ta_visualisasi/user/reset_password.dart';
import 'package:ta_visualisasi/user/sign_up.dart';

class SignIn extends StatefulWidget {
  static const routeName = "/SignIn";

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // Cek apakah ada email dan kata sandi yang tersimpan di shared_preferences
    _loadSavedCredentials();
  }

  // Function untuk memuat email dan kata sandi yang tersimpan
  void _loadSavedCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedEmail = prefs.getString('email');
    String? savedPassword = prefs.getString('password');

    if (savedEmail != null && savedPassword != null) {
      setState(() {
        _emailController.text = savedEmail;
        _passwordController.text = savedPassword;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      //backgroundColor: Color.fromRGBO(255, 230, 173, 1.0),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.93,
              height: MediaQuery.of(context).size.height * 0.5, // Mengatur tinggi kontainer menjadi setengah dari tinggi layar
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
                      children: <Widget> [
                        // const SizedBox(
                        //   height: 20,
                        // ),
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
                        // const SizedBox(
                        //   height: 5.0,
                        // ),
                        // Text("Sign In", style: TextStyle(fontWeight: FontWeight.bold,)),
                        // const SizedBox(
                        //   height: 45.0,
                        // ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text("Sign In",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                          child:
                          TextFormField(
                            // cursorColor: Color.fromRGBO(20, 26, 70, 1.0),
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                // Based on passwordVisible state choose the icon
                                Icons.mail_outline_rounded,
                                color: Colors.black12,
                              ),
                              hintText: 'example@gmail.com',
                              hintStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              // filled: true,
                              // fillColor: Colors.black12,
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
                              labelText: "Email",
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 5.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            keyboardType: TextInputType.visiblePassword,
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                // Based on passwordVisible state choose the icon
                                Icons.lock_outline_rounded,
                                color: Colors.black12,
                              ),
                              hintText: '',
                              hintStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              // filled: true,
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
                              labelText: "Password",
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword ? Icons.visibility_off_rounded :
                                Icons.visibility_rounded, color: Colors.black12,),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                        // const SizedBox(
                        //   height: 5.0,
                        // ),
                        // SignUp Navigation
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, ResetPassword.routeName);
                          },
                          style: ButtonStyle(
                            overlayColor: MaterialStateColor.resolveWith((states) => Colors.transparent), // Mengatur overlay color menjadi transparent
                          ),
                          child: Align(
                            alignment: Alignment.centerRight, // Mengatur posisi ke samping kanan
                            child: Text('Forgot Password', style: TextStyle(color: Colors.black),),
                          ),
                        ),
                        Container(
                          height: 45,
                          // width: 350,
                          width: MediaQuery.of(context).size.width / 2.25,
                          child: ElevatedButton(
                            onPressed: () async {
                              // Simpan email dan kata sandi ke shared_preferences jika autofill diaktifkan
                              _saveCredentials();
                              // Lakukan login
                              final message = await AuthService().login(
                                email: _emailController.text,
                                password: _passwordController.text,
                              );
                              if (message!.contains('Success')) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => DataPlat(email: _emailController.text,),
                                  ),
                                );
                                // Navigasi ke halaman beranda (atau halaman selanjutnya setelah login berhasil)
                                // Navigator.of(context).pushReplacement(
                                //   MaterialPageRoute(
                                //     builder: (context) =>
                                //         DataPlat(),
                                //         //MenuAutentikasi(email: _emailController.text),
                                //       //HomeScreen(email: _emailController.text),
                                //   ),
                                // );
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(message),
                                ),
                              );
                            },
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15), // Adjust the corner radius as desired

                                ),
                              ),
                              backgroundColor: MaterialStateProperty.all<Color>(
                                button,
                                //const Color.fromRGBO(20, 26, 70, 1.0), // Red color (RGB: 255, 0, 0)
                              ),
                            ),
                            child: const Text('Login', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: textbutton),),
                          ),
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, SignUp.routeName);
                          },
                          style: ButtonStyle(
                            overlayColor: MaterialStateColor.resolveWith((states) => Colors.transparent), // Mengatur overlay color menjadi transparent
                          ),
                          child: Text('Don\'t have an account? Sign Up',style: TextStyle(color: Colors.black),),
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
    );
  }

  // Function untuk menyimpan email dan kata sandi ke shared_preferences
  void _saveCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('email', _emailController.text);
    prefs.setString('password', _passwordController.text);
  }
}
