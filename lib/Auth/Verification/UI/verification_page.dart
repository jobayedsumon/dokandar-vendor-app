import 'dart:convert';

import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:pin_code_text_field/pin_code_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:vendor/Routes/routes.dart';
import 'package:vendor/Themes/colors.dart';
import 'package:vendor/Themes/style.dart';
import 'package:vendor/baseurl/baseurl.dart';
import 'package:vendor/orderbean/vendorprofilebean.dart';
import 'package:vendor/restaturant/order_item_account_rest.dart';

//Verification page that sends otp to the phone number entered on phone number page
class VerificationPage extends StatelessWidget {
  final VoidCallback onVerificationDone;

  VerificationPage(this.onVerificationDone);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Text(
          'Verification',
          style: headingStyle,
        ),
      ),
      body: OtpVerify(onVerificationDone),
    );
  }
}

//otp verification class
class OtpVerify extends StatefulWidget {
  final VoidCallback onVerificationDone;

  OtpVerify(this.onVerificationDone);

  @override
  _OtpVerifyState createState() => _OtpVerifyState();
}

class _OtpVerifyState extends State<OtpVerify> {
  final TextEditingController _controller = TextEditingController();
  FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  bool isDialogShowing = false;
  var deviceToken = '';
  var showDialogBox = false;

  var verificaitonPin = "";

  bool showTimer = true;

  @override
  void initState() {
    firebaseMessaging.getToken().then((value) {
      deviceToken = value;
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height - 100,
        child: Stack(
          children: <Widget>[
            Positioned(
                top: 10,
                left: 0,
                right: 0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(
                          top: 10, bottom: 5, right: 80, left: 80),
                      child: Center(
                        child: Text(
                          'Verify your phone number',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: kMainTextColor,
                              fontSize: 30,
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 20.0, right: 20.0),
                      child: Text(
                        "Enter your otp code here.",
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headline6
                            .copyWith(fontSize: 16, color: Colors.black87),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      padding: EdgeInsets.only(right: 20.0, left: 20.0),
                      child: Column(
                        children: <Widget>[
                          SizedBox(height: 10.0),
                          PinCodeTextField(
                            autofocus: true,
                            controller: _controller,
                            hideCharacter: false,
                            highlight: true,
                            highlightColor: kHintColor,
                            defaultBorderColor: kMainColor,
                            hasTextBorderColor: kMainColor,
                            maxLength: 4,
                            pinBoxRadius: 40,
                            onDone: (text) {
                              SystemChannels.textInput
                                  .invokeMethod('TextInput.hide');
                              verificaitonPin = text;
                            },
                            pinBoxWidth: 60,
                            pinBoxHeight: 60,
                            hasUnderline: false,
                            wrapAlignment: WrapAlignment.spaceAround,
                            pinBoxDecoration: ProvidedPinBoxDecoration
                                .roundedPinBoxDecoration,
                            pinTextStyle: TextStyle(fontSize: 22.0),
                            pinTextAnimatedSwitcherTransition:
                                ProvidedPinBoxTextAnimation.scalingTransition,
                            pinTextAnimatedSwitcherDuration:
                                Duration(milliseconds: 300),
                            highlightAnimationBeginColor: Colors.black,
                            highlightAnimationEndColor: Colors.white12,
                            keyboardType: TextInputType.number,
                          ),
                          SizedBox(height: 15.0),
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Didn't you receive any code? Wait!",
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: Colors.black, fontSize: 16),
                            ),
                          ),
                          SizedBox(height: 15.0),
                          showTimer
                              ? CircularCountDownTimer(
                                  duration: 40,
                                  initialDuration: 0,
                                  controller: CountDownController(),
                                  width: 80.0,
                                  height: 80.0,
                                  ringColor: Colors.grey[300],
                                  ringGradient: null,
                                  fillColor: Colors.pink[300],
                                  fillGradient: null,
                                  backgroundColor: Colors.pink[400],
                                  backgroundGradient: null,
                                  strokeWidth: 20.0,
                                  strokeCap: StrokeCap.round,
                                  textStyle: TextStyle(
                                      fontSize: 33.0,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                  textFormat: CountdownTextFormat.S,
                                  isReverse: true,
                                  isReverseAnimation: true,
                                  isTimerTextShown: true,
                                  autoStart: true,
                                  onStart: () {
                                    print('Countdown Started');
                                  },
                                  onComplete: () {
                                    print('Countdown Ended');
                                    setState(() {
                                      showTimer = false;
                                    });
                                  },
                                )
                              : FlatButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    "TRY AGAIN",
                                    textDirection: TextDirection.ltr,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: kMainColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                  ],
                )),
            Positioned(
              bottom: 12,
              left: 20,
              right: 20.0,
              child: InkWell(
                onTap: () {
                  setState(() {
                    showDialogBox = true;
                  });
                  hitService(verificaitonPin, context);
                },
                child: Container(
                  alignment: Alignment.center,
                  height: 52,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                      color: kMainColor),
                  child: Text(
                    'Verify',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      color: kWhiteColor,
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
                child: Visibility(
              visible: showDialogBox,
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height - 100,
                  alignment: Alignment.center,
                  child: SizedBox(
                    height: 120,
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Material(
                      elevation: 5,
                      borderRadius: BorderRadius.circular(20),
                      clipBehavior: Clip.hardEdge,
                      child: Container(
                        color: kWhiteColor,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            CircularProgressIndicator(),
                            SizedBox(
                              width: 20,
                            ),
                            Text(
                              'Loading please wait!....',
                              style: TextStyle(
                                  color: kMainTextColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 20),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  void hitService(String verificaitonPin, BuildContext context) async {
    if (deviceToken != null && deviceToken.length > 0) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      print(prefs.getString('store_phone'));
      var url = storelogin;
      http.post(url, body: {
        'store_phone': prefs.getString('store_phone'),
        'otp': verificaitonPin,
        'device_id': '${deviceToken}'
      }).then((response) {
        print(response.body);
        if (response.statusCode == 200) {
          var jsonData = jsonDecode(response.body);
          if (jsonData['status'] == 1) {
            VendorProfile profile = VendorProfile.fromJson(jsonData['data']);
            CurrencyData currencyData =
                CurrencyData.fromJson(jsonData['currency']);
            print('${profile.toString()}');
            print('${currencyData.toString()}');
            prefs.setString("curency", '${currencyData.currency_sign}');
            var venId = int.parse('${profile.vendor_id}');
            prefs.setInt("vendor_id", venId);
            prefs.setString("vendor_name", profile.vendor_name);
            prefs.setString("vendor_logo", profile.vendor_logo);
            prefs.setString("vendor_phone", profile.vendor_phone);
            prefs.setString("vendor_pass", profile.vendor_pass);
            prefs.setString("owner", profile.owner);
            prefs.setString("device_id", profile.device_id);
            prefs.setString("comission", '${profile.comission}');
            prefs.setString("delivery_range", '${profile.delivery_range}');
            prefs.setString(
                "vendor_category_id", '${profile.vendor_category_id}');
            prefs.setString("opening_time", '${profile.opening_time}');
            prefs.setString("closing_time", '${profile.closing_time}');
            prefs.setString("vendor_loc", '${profile.vendor_loc}');
            prefs.setString("lat", '${profile.lat}');
            prefs.setString("lng", '${profile.lng}');
            prefs.setString("cityadmin_id", profile.cityadmin_id);
            var uiType = int.parse('${profile.ui_type}');
            prefs.setString("ui_type", '$uiType');
            var phone_verified = int.parse('${profile.phone_verified}');
            prefs.setInt("phoneverifed", phone_verified);
            prefs.setBool("islogin", true);
            Toast.show(jsonData['message'], context,
                duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
            widget.onVerificationDone();
          } else {
            prefs.setInt("phoneverifed", 0);
            prefs.setBool("islogin", false);
            setState(() {
              showDialogBox = false;
            });
          }
        } else {
          print(response);
        }
      });
    } else {
      firebaseMessaging.getToken().then((value) {
        deviceToken = value;
        hitService(verificaitonPin, context);
      });
    }
  }
}

class GoMarketMangerHomeRestt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      supportedLocales: [
        const Locale('en'),
        const Locale('hi'),
      ],
      theme: appTheme,
      home: OrderItemAccountRest(),
      routes: PageRoutes().routes(),
    );
  }
}
