import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pinput/pinput.dart';
import '../HomeScreen/homeScreen.dart';
import 'registerUser.dart';

class OtpPage extends StatefulWidget {
  final String? phone;
  OtpPage({this.phone});
  @override
  OtpPageState createState() => OtpPageState();
}

class OtpPageState extends State<OtpPage> {
  String? uid;
  final _auth = FirebaseAuth.instance;
  String? _verificationCode;
  final _pinPutController = TextEditingController();
  final _pinPutFocusNode = FocusNode();
  final BoxDecoration pinPutDecoration = BoxDecoration(
    border: Border.all(color: Colors.deepPurpleAccent),
    borderRadius: BorderRadius.circular(15.0),
  );

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _verifyPhone();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xFFeaeaea),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              child: Stack(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.fromLTRB(15.0, 60.0, 0.0, 0.0),
                    child: Text('Share',
                        style: TextStyle(
                            fontSize: 70.0, fontWeight: FontWeight.bold)),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(16.0, 125.0, 0.0, 0.0),
                    child: Text('MyRide',
                        style: TextStyle(
                            fontSize: 70.0, fontWeight: FontWeight.bold)),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(255.0, 115.0, 0.0, 0.0),
                    child: Text('.',
                        style: TextStyle(
                            fontSize: 80.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue)),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(20, 40.0, 0.0, 0.0),
              child: Text(
                "Verifying your number!",
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(20, 10.0, 20.0, 0.0),
              child: RichText(
                text: TextSpan(
                  text: 'Please type the verification code sent to  ',
                  style: TextStyle(fontSize: 20, color: Colors.black),
                  children: <TextSpan>[
                    TextSpan(
                        text: "+92 ${widget.phone}",
                        style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue)),
                  ],
                ),
              ),
            ),
            Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Image(
                    image: AssetImage('assets/otp_icon.png'),
                    height: 120.0,
                    width: 120.0,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50.0),
                  child: Row(
                    children: [
                      Text(
                        "Didn't receive OTP ?",
                        style: TextStyle(
                            fontSize: 15.0, fontWeight: FontWeight.normal),
                        textAlign: TextAlign.center,
                      ),
                      TextButton(
                        child: Text(
                          " Resend OTP",
                          style: TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.redAccent),
                          textAlign: TextAlign.center,
                        ),
                        onPressed: () => _verifyPhone(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Pinput(
                defaultPinTheme: PinTheme(
                  width: 56,
                  height: 56,
                  textStyle: TextStyle(
                      fontSize: 20,
                      color: Color.fromRGBO(30, 60, 87, 1),
                      fontWeight: FontWeight.w600),
                  decoration: BoxDecoration(
                    border: Border.all(color: Color.fromARGB(255, 18, 88, 144)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                length: 6,
                // withCursor: true,
                onCompleted: (pin) async {
                  try {
                    await _auth
                        .signInWithCredential(PhoneAuthProvider.credential(
                            verificationId: _verificationCode!, smsCode: pin))
                        .then((value) async {
                      if (value.user != null) {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => SignUp()),
                            (route) => false);
                      }
                    });
                  } catch (e) {
                    FocusScope.of(context).unfocus();
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text("Invalid OTP")));
                  }
                },
                focusNode: _pinPutFocusNode,
                controller: _pinPutController,
                // focusedPinTheme: PinTheme(decoration: pinPutDecoration),
                // followingPinTheme: PinTheme(
                //   decoration: BoxDecoration(
                //     borderRadius: BorderRadius.circular(5.0),
                //     border: Border.all(
                //       color: Colors.blueAccent.withOpacity(.5),
                //     ),
                //   ),
                // ),
                // onCompleted: (pin) => print(pin),
                // validator: (s) {
                //   return s == '123456' ? null : 'Pin is incorrect';
                // },
                showCursor: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _verifyPhone() async {
    await _auth.verifyPhoneNumber(
      timeout: Duration(seconds: 60),
      phoneNumber: '+92${widget.phone}',
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential).then((value) async {
          final SharedPreferences sharedPreferences =
              await SharedPreferences.getInstance();
          var status = sharedPreferences.getBool('isLoggedIn') ?? false;
          if (status) {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => SignUp()),
                (route) => false);
          } else {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
                (route) => false);
          }
        });
      },
      verificationFailed: (FirebaseAuthException e) {
        print(e.message);
      },
      codeSent: (String? verficationID, int? resendToken) {
        setState(() {
          _verificationCode = verficationID;
        });
      },
      codeAutoRetrievalTimeout: (String verificationID) {
        setState(() {
          _verificationCode = verificationID;
        });
      },
    );
  }
}
