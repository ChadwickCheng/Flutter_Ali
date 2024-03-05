import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:fluent_ui/fluent_ui.dart';
//引入material UI库使用里面的方法和组件
import 'package:flutter/material.dart' show showMenu, PopupMenuItem;
import 'package:netdisk/services/storage.dart';
import 'package:netdisk/services/userService.dart';
import '../router/router.dart';
import '../widgets/windowButtons.dart';

class NavigationPage extends StatefulWidget {
  final Widget child;
  const NavigationPage({super.key, required this.child});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  int topIndex = 0; //第几个选中
  //左侧的选项卡 以及选项卡对应的页面
  List<NavigationPaneItem> items = [
    PaneItemExpander(
      icon: const Icon(
        FluentIcons.folder_open,
      ),
      title: const Text(
        '文件',
        style: TextStyle(fontSize: 14, fontFamily: "微软雅黑"),
      ),
      body: const SizedBox.shrink(),
      onTap: () {
        if (router.location != '/file') {
          router.goNamed('file');
        }
      },
      items: [
        PaneItem(
          icon: const Icon(FluentIcons.reminder_time),
          title: const Text(
            '最近播放',
            style: TextStyle(fontSize: 14, fontFamily: "微软雅黑"),
          ),
          body: const SizedBox.shrink(),
          onTap: () {
            if (router.location != '/recentlyPlayed') {
              router.goNamed('recentlyPlayed');
            }
          },
        ),
        PaneItem(
          icon: const Icon(FluentIcons.document_set),
          title: const Text(
            '我的资料',
            style: TextStyle(fontSize: 14, fontFamily: "微软雅黑"),
          ),
          body: const SizedBox.shrink(),
          onTap: () {
            if (router.location != '/myProfile') {
              router.goNamed('myProfile');
            }
          },
        ),
      ],
    ),
    PaneItem(
        icon: const Icon(FluentIcons.photo_collection),
        title: const Text(
          '相册',
          style: TextStyle(fontSize: 14, fontFamily: "微软雅黑"),
        ),
        body: const SizedBox.shrink(),
        onTap: () {
          if (router.location != '/photo') {
            router.goNamed('photo');
          }
        }),
    PaneItem(
        icon: const Icon(FluentIcons.heart),
        title: const Text(
          '收藏夹',
          style: TextStyle(fontSize: 14, fontFamily: "微软雅黑"),
        ),
        body: const SizedBox.shrink(),
        onTap: () {
          if (router.location != '/favorites') {
            router.goNamed('favorites');
          }
        }),
    PaneItem(
        icon: const Icon(FluentIcons.password_field),
        title: const Text(
          '密码箱',
          style: TextStyle(fontSize: 14, fontFamily: "微软雅黑"),
        ),
        body: const SizedBox.shrink(),
        onTap: () {
          if (router.location != '/password') {
            router.goNamed('password');
          }
        }),
    PaneItem(
        icon: const Icon(FluentIcons.subscribe),
        title: const Text(
          '订阅',
          style: TextStyle(fontSize: 14, fontFamily: "微软雅黑"),
        ),
        body: const SizedBox.shrink(),
        onTap: () {
          if (router.location != '/subscribe') {
            router.goNamed('subscribe');
          }
        }),
    PaneItem(
        icon: const Icon(FluentIcons.empty_recycle_bin),
        title: const Text(
          '回收站',
          style: TextStyle(fontSize: 14, fontFamily: "微软雅黑"),
        ),
        body: const SizedBox.shrink(),
        onTap: () {
          if (router.location != '/recycle') {
            router.goNamed('recycle');
          }
        }),
    PaneItemSeparator(),
    PaneItem(
      icon: const Icon(FluentIcons.account_management),
      title: const Text(
        '传输列表',
        style: TextStyle(fontSize: 14, fontFamily: "微软雅黑"),
      ),
      body: const SizedBox.shrink(),
      onTap: () {
        if (router.location != '/transferList') {
          router.goNamed('transferList');
        }
      },
    ),
    PaneItem(
        icon: const Icon(FluentIcons.cloud),
        title: const Text(
          '备份空间',
          style: TextStyle(fontSize: 14, fontFamily: "微软雅黑"),
        ),
        body: const SizedBox.shrink(),
        onTap: () {
          if (router.location != '/bacup') {
            router.goNamed('bacup');
          }
        },
        trailing: Padding(
          padding: const EdgeInsets.only(right: 58),
          child: Container(
            padding: const EdgeInsets.only(top: 3),
            width: 50, //54px实际项目中需要量一下设计稿
            child: Image.asset(
              "assets/vip.png",
              fit: BoxFit.contain,
            ),
          ),
        )),
    PaneItem(
      enabled: false,
      icon: SizedBox.shrink(),
      body: const SizedBox.shrink(),
    ),
    PaneItem(
        enabled: false,
        icon: const Text(
          '36.7GB/100GB',
          style:
              TextStyle(fontSize: 12, fontFamily: "微软雅黑", color: Colors.grey),
        ),
        body: const SizedBox.shrink(),
        trailing: Padding(
          padding: const EdgeInsets.only(right: 32),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {},
              child: Text(
                "容量管理",
                style: TextStyle(
                    fontSize: 12, fontFamily: "微软雅黑", color: Colors.blue),
              ),
            ),
          ),
        )),
    PaneItem(
      enabled: false,
      icon: Padding(
        padding: const EdgeInsets.only(left: 2),
        child: Slider(
          label: '',
          value: 20,
          onChanged: (v) {},
        ),
      ),
      body: const SizedBox.shrink(),
    ),
  ];

  List? _userinfo;
  @override
  void initState() {
    super.initState();
    _getUserInfo();
  }

  _getUserInfo() async {
    var userinfo = await UserService.getUserInfo();
    setState(() {
      _userinfo = userinfo;
    });
  }

  @override
  Widget build(BuildContext context) {
    //获取屏幕的宽度高度  窗口最大化 最小化的时候会重新出发build方法
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return NavigationView(
      appBar: NavigationAppBar(
          // backgroundColor: Colors.red,  //导航背景颜色
          height: 36,
          leading: const Text(""),
          title: WindowTitleBarBox(child: MoveWindow()),
          actions: Platform.isWindows
              ? Container(
                  alignment: Alignment.centerRight,
                  width: 140,
                  child: const WindowButtons(),
                )
              : Text("")),
      //右侧区域
      paneBodyBuilder: (item, child) {
        return widget.child;
      },
      pane: NavigationPane(
        size: const NavigationPaneSize(openWidth: 220), //配置左侧宽度
        selected: topIndex,
        onChanged: (index) => setState(() => topIndex = index),
        displayMode: PaneDisplayMode.open,
        items: items,
        footerItems: [
          PaneItem(
              enabled: false,
              icon: const Icon(FluentIcons.people),
              title: Text(
                _userinfo != null ? _userinfo![0]["phone"] : "",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              body: const SizedBox.shrink(),
              onTap: () {
                if (router.location != '/settings') {
                  router.goNamed('settings');
                }
              },
              trailing: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: IconButton(
                    icon: const Icon(FluentIcons.settings),
                    onPressed: () {
                      print("设置");
                      showMenu(
                          context: context,
                          position: RelativeRect.fromLTRB(
                              200, screenHeight - 320, screenWidth - 200, 300),
                          items: [
                            PopupMenuItem(
                              height: 44,
                              child: Row(
                                children: const [
                                  Text("会员中心",
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                          fontFamily: "微软雅黑"))
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              height: 44,
                              child: Row(
                                children: const [
                                  Text("达人中心",
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                          fontFamily: "微软雅黑"))
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              height: 44,
                              child: Row(
                                children: const [
                                  Text("帮助反馈",
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                          fontFamily: "微软雅黑"))
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              height: 44,
                              child: Row(
                                children: const [
                                  Text("关于",
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                          fontFamily: "微软雅黑"))
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              height: 44,
                              child: Row(
                                children: const [
                                  Text("设置",
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                          fontFamily: "微软雅黑"))
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              onTap: () async {
                                await Storage.removeData("userinfo");
                                appWindow.close();
                              },
                              height: 44,
                              child: Row(
                                children: const [
                                  Text("退出登录",
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                          fontFamily: "微软雅黑"))
                                ],
                              ),
                            ),
                          ]);
                    }),
              )),
        ],
      ),
    );
  }
}
