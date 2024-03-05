// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:netdisk/services/storage.dart';
import '../widgets/loginButtons .dart';
import '../services/httpsClient.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _photo = "";
  String _code = "";
  bool sendCodeButton = true;
  int seconds = 10;

  HttpsClient httpsClient = HttpsClient();
  Timer? t;
  @override
  void dispose() {
    super.dispose();
    if (t != null) {
      //取消定时器
      t!.cancel();
    }
  }

//执行登录
  _doLogin() async {
    if (_photo != "" || _code != "") {
      var result = await httpsClient
          .post("api/doLogin", data: {"phone": _photo, "code": _code});

      if (result != null) {
        if (result.data["success"]) {
          //执行登录  保存用户信息   执行跳转
          // print(result.data["userinfo"]); //[{phone: 15212345678, salt: 8088f53fa26c5521174c58cabe673464, uid: 22812}]

          Storage.setData("userinfo", result.data["userinfo"]);
          context.go("/file");
          appWindow.hide(); //macos需要去掉这句话
          sleep(const Duration(milliseconds: 50));
          appWindow.minSize = const Size(1000, 600);
          appWindow.size = const Size(1000, 600);
          appWindow.alignment = Alignment.center;
          appWindow.show();
        } else {
          CherryToast.error(
                  animationType: AnimationType.fromTop,
                  animationDuration: const Duration(milliseconds: 500),
                  toastDuration: const Duration(milliseconds: 1500),
                  title: Text(result.data["message"]))
              .show(context);
        }
      } else {
        CherryToast.error(
                animationType: AnimationType.fromTop,
                animationDuration: const Duration(milliseconds: 500),
                toastDuration: const Duration(milliseconds: 1500),
                title: const Text("网络异常,请检查网络"))
            .show(context);
      }
    } else {
      CherryToast.error(
          animationType: AnimationType.fromTop,
          animationDuration: const Duration(milliseconds: 500),
          toastDuration: const Duration(milliseconds: 1500),
          title: const Text(
            "手机号/验证码不能为空",
            style: TextStyle(fontSize: 14),
          )).show(context);
    }
  }

//发送验证码
  _sendCode() async {
    var reg = RegExp(r'^1\d{10}$');
    if (_photo.length == 11 && reg.hasMatch(_photo)) {
      var result =
          await httpsClient.post("api/sendCode", data: {"phone": _photo});

      if (result != null) {
        if (result.data["success"]) {
          //实际项目code需要手机查看，这里是模拟
          CherryToast.success(
                  animationType: AnimationType.fromTop,
                  animationDuration: const Duration(milliseconds: 500),
                  toastDuration: const Duration(milliseconds: 1500),
                  title: Text("提示：验证码是${result.data["code"]}"))
              .show(context);
          //发送验证码成功 倒计时
          _showTimer();
        } else {
          CherryToast.error(
                  animationType: AnimationType.fromTop,
                  animationDuration: const Duration(milliseconds: 500),
                  toastDuration: const Duration(milliseconds: 1500),
                  title: Text(result.data["message"]))
              .show(context);
        }
      } else {
        //请求失败 网络出问题了

        CherryToast.error(
                animationType: AnimationType.fromTop,
                animationDuration: const Duration(milliseconds: 500),
                toastDuration: const Duration(milliseconds: 1500),
                title: const Text("请求失败,请检查网络"))
            .show(context);
      }
    } else {
      CherryToast.error(
              animationType: AnimationType.fromTop,
              animationDuration: const Duration(milliseconds: 500),
              toastDuration: const Duration(milliseconds: 1500),
              title: const Text("手机号格式不合法"))
          .show(context);
    }
  }

  //倒计时
  _showTimer() {
    setState(() {
      sendCodeButton = false;
    });
    t = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      setState(() {
        seconds--;
      });
      if (seconds == 0) {
        timer.cancel();
        sendCodeButton = true;
        seconds = 10;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          toolbarHeight: 40,
          elevation: 0,
          backgroundColor: Colors.white,
          title: WindowTitleBarBox(child: MoveWindow()),
          actions: [
            Platform.isWindows
                ? Container(
                    alignment: Alignment.centerRight,
                    width: 94,
                    child: const LoginButtons(),
                  )
                : Text("")
          ],
        ),
        body: Center(
          child: Container(
            alignment: Alignment.center,
            width: 400,
            height: 400,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.cloud_done_rounded,
                        size: 60,
                        color: Color.fromRGBO(126, 145, 250, 1),
                      ),
                      Text(
                        " IT营网盘",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                            fontFamily: "微软雅黑"),
                      )
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  width: 360,
                  height: 68,
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _photo = value;
                      });
                    },
                    decoration: const InputDecoration(
                        hintText: "手机号", border: OutlineInputBorder()),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  width: 360,
                  height: 68,
                  child: Stack(
                    children: [
                      TextField(
                        onChanged: (value) {
                          setState(() {
                            _code = value;
                          });
                        },
                        decoration: const InputDecoration(
                            hintText: "验证码", border: OutlineInputBorder()),
                      ),
                      Positioned(
                          top: 6,
                          right: 4,
                          child: Container(
                            height: 36,
                            child: sendCodeButton
                                ? OutlinedButton(
                                    onPressed: () {
                                      _sendCode();
                                    },
                                    child: const Text("发送验证码"))
                                : OutlinedButton(
                                    onPressed: null,
                                    child: Text("$seconds秒后重发")),
                          ))
                    ],
                  ),
                ),
                SizedBox(
                  width: 320,
                  height: 42,
                  child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            Color.fromRGBO(126, 145, 250, 1)),
                        shape: MaterialStateProperty.all(//圆角
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)))),
                    child: const Text('登录'),
                    onPressed: () {
                      //请求接口验证数据
                      _doLogin();
                    },
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
