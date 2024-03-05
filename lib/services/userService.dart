import 'storage.dart';

class UserService {
  //获取用户信息
  static Future<List> getUserInfo() async {
    List? userinfo = await Storage.getData("userinfo");
    if (userinfo != null) {
      return userinfo;
    }
    return [];
  }

  //判断用户有没有登录
  static Future<bool> isLogin() async {
    List userinfo = await getUserInfo();
    if (userinfo.isNotEmpty && userinfo[0]["phone"] != "") {
      return true;
    }
    return false;
  }

  //退出登录
  static loginOut() async {
    await Storage.removeData("userinfo");
  }
}
