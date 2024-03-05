// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' show showMenu, PopupMenuItem, Icons;
import 'package:go_router/go_router.dart';
import 'package:netdisk/services/userService.dart';
import '../router/router.dart';
import '../services/signServices.dart';
import '../services/httpsClient.dart';
import '../models/ossModel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:contextmenu/contextmenu.dart';
import 'package:path/path.dart' as path; //获取后缀名
import 'package:provider/provider.dart';
import '../provider/transferProvider.dart';

class FilePage extends StatefulWidget {
  const FilePage({super.key});
  @override
  State<FilePage> createState() => _FilePageState();
}

class _FilePageState extends State<FilePage> {
  HttpsClient httpsClient = HttpsClient();
  bool _isGridView = false;
  List<OssModelItems> _filesList = [];

  String _folderName = "";
  String _order = "desc";
  String _orderType = "modifyTime";
  List _diskPathList = [];
  @override
  void initState() {
    super.initState();
    _getFilesData();
  }

  _getFilesData() async {
    List userInfo = await UserService.getUserInfo();
    var sign = SignServices.getSign({
      "folderName": _folderName,
      "order": _order,
      "orderType": _orderType,
      "uid": userInfo[0]["uid"],
      "salt": userInfo[0]["salt"], //私钥
    });
    String apiUrl =
        "api/getFile?folderName=$_folderName&order=$_order&orderType=$_orderType&uid=${userInfo[0]["uid"]}&sign=$sign";
    var response = await httpsClient.get(apiUrl);
    if (response != null) {
      // print(response.data);
      OssModel result = OssModel.fromJson(response.data);
      if (result.success == true) {
        setState(() {
          _filesList = result.files!;
        });
      } else {
        CherryToast.error(
                animationType: AnimationType.fromTop,
                animationDuration: const Duration(milliseconds: 500),
                toastDuration: const Duration(milliseconds: 1500),
                title: const Text("签名错误"))
            .show(context);
      }
    } else {
      CherryToast.error(
              animationType: AnimationType.fromTop,
              animationDuration: const Duration(milliseconds: 500),
              toastDuration: const Duration(milliseconds: 1500),
              title: Text("网络异常"))
          .show(context);
    }
  }

//上传文件的toast
  uploadToast() {
    CherryToast.success(
        animationType: AnimationType.fromTop,
        animationDuration: const Duration(milliseconds: 500),
        toastDuration: const Duration(milliseconds: 10000),
        action: const Text("点击查看", style: TextStyle(fontSize: 14)),
        actionHandler: () {
          router.goNamed('transferList');
        },
        title: const Text(
          "已添加一项到上传列表",
          style: TextStyle(fontSize: 14),
        )).show(context);
  }

  //下载文件的toast
  downloadToast() {
    CherryToast.success(
        animationType: AnimationType.fromTop,
        animationDuration: const Duration(milliseconds: 500),
        toastDuration: const Duration(milliseconds: 10000),
        action: const Text("点击查看", style: TextStyle(fontSize: 14)),
        actionHandler: () {
          router.goNamed('transferList');
        },
        title: const Text(
          "已添加一项到下载列表",
          style: TextStyle(fontSize: 14),
        )).show(context);
  }

  //获取一个文件夹下面所有的文件以及文件夹
  Future<List<OssModelItems>> _getDownloadFiles(
      String downloadFilesName) async {
    List userInfo = await UserService.getUserInfo();
    var sign = SignServices.getSign({
      "folderName": downloadFilesName,
      "uid": userInfo[0]["uid"],
      "salt": userInfo[0]["salt"], //私钥
    });
    String apiUrl =
        "api/getDownloadFiles?folderName=$downloadFilesName&uid=${userInfo[0]["uid"]}&sign=$sign";
    var response = await httpsClient.get(apiUrl);
    if (response != null) {
      OssModel result = OssModel.fromJson(response.data);
      if (result.success == true) {
        return result.files!;
      } else {
        return [];
      }
    } else {
      return [];
    }
  }

//右侧增加按钮组件
  Widget _addButtonWidget(TransfersProvider transfersProvider) {
    return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Listener(
          onPointerDown: (e) {
            if (e.kind == PointerDeviceKind.mouse && e.buttons == 1) {
              showMenu(
                  context: context,
                  position: RelativeRect.fromLTRB(
                      e.position.dx,
                      e.position.dy - 22,
                      MediaQuery.of(context).size.width - e.position.dx,
                      MediaQuery.of(context).size.height - e.position.dy),
                  items: [
                    PopupMenuItem(
                      height: 44,
                      enabled: false,
                      child: Row(
                        children: const [
                          Text("添加文件",
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                  fontFamily: "微软雅黑"))
                        ],
                      ),
                    ),
                    PopupMenuItem(
                        onTap: () async {
                          print(_folderName);
                          List userInfo = await UserService.getUserInfo();

                          FilePickerResult? result =
                              await FilePicker.platform.pickFiles();

                          if (result != null) {
                            uploadToast();
                            print(result.files.single.path); //完整目录
                            print(result.files.single.name); //文件名称
                            //文件在远程保存的路径
                            String dst = _folderName == ""
                                ? result.files.single.name
                                : "$_folderName/${result.files.single.name}";
                            var sign = SignServices.getSign({
                              "dst": dst,
                              "uid": userInfo[0]["uid"],
                              "salt": userInfo[0]["salt"], //私钥
                            });

                            var response = await httpsClient.uploadFile(
                                transfersProvider,
                                "api/uploadFile",
                                {
                                  "dst": dst,
                                  "uid": userInfo[0]["uid"],
                                  "sign": sign
                                },
                                result.files.single.path!);

                            if (response.data["success"] == true) {
                              _getFilesData();
                            }
                          } else {
                            // User canceled the picker
                            print("已取消操作");
                          }
                        },
                        height: 44,
                        child: Row(children: const [
                          Padding(
                            padding: EdgeInsets.only(left: 0, right: 5),
                            child: Icon(FluentIcons.open_file),
                          ),
                          Text(
                            "上传文件",
                            style: TextStyle(fontSize: 14, fontFamily: "微软雅黑"),
                          )
                        ])),
                    PopupMenuItem(
                        onTap: () async {
                          List userInfo = await UserService.getUserInfo();
                          //1、选择文件
                          String? selectedDirectory =
                              await FilePicker.platform.getDirectoryPath();

                          if (selectedDirectory != null) {
                            uploadToast();
                            print(selectedDirectory);
                            //2、获取目录  selectedDirectory

                            //3、获取要上传的文件夹的名称
                            List tempArr = selectedDirectory.split("\\");
                            var folderName = tempArr[tempArr.length - 1];
                            //4、获取selectedDirectory目录下面所有的文件
                            var directory = Directory(selectedDirectory);
                            //5、获取所有的文件以及文件夹
                            List files = directory.listSync(
                                recursive: true); //recursive: true
                            //6、循环遍历实现文件上传
                            for (var f in files) {
                              // print(f.path);   文件路径

                              /*
                              C:\Users\htzhanglong\Desktop\flutter桌面软件开发教程\归档.zip

                               f.path.toString().split(folderName)[1]  ========   \归档.zip


                               C:\Users\htzhanglong\Desktop\flutter桌面软件开发教程\aaa\api.js

                                f.path.toString().split(folderName)[1]  ========   \aaa\api.js
                              */
                              if (f is File) {
                                //5、执行上传
                                String dst = _folderName == ""
                                    ? folderName +
                                        f.path.toString().split(folderName)[1]
                                    : "$_folderName/${folderName + f.path.toString().split(folderName)[1]}";

                                var sign = SignServices.getSign({
                                  "dst": httpsClient.replaeUri(dst),
                                  "uid": userInfo[0]["uid"],
                                  "salt": userInfo[0]["salt"], //私钥
                                });

                                await httpsClient.uploadFile(
                                    transfersProvider,
                                    "api/uploadFile",
                                    {
                                      "dst": httpsClient.replaeUri(dst),
                                      "uid": userInfo[0]["uid"],
                                      "sign": sign
                                    },
                                    f.path);
                              }
                            }
                            _getFilesData();
                          } else {
                            print("已取消操作");
                          }
                        },
                        height: 44,
                        child: Row(children: const [
                          Padding(
                            padding: EdgeInsets.only(left: 0, right: 5),
                            child: Icon(FluentIcons.fabric_folder_upload),
                          ),
                          Text(
                            "上传文件夹",
                            style: TextStyle(fontSize: 14, fontFamily: "微软雅黑"),
                          )
                        ])),
                    PopupMenuItem(
                      enabled: false,
                      height: 44,
                      child: Row(
                        children: const [
                          Text("添加到相博",
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                  fontFamily: "微软雅黑"))
                        ],
                      ),
                    ),
                    PopupMenuItem(
                        height: 44,
                        child: Row(children: const [
                          Padding(
                            padding: EdgeInsets.only(left: 0, right: 5),
                            child: Icon(FluentIcons.camera),
                          ),
                          Text(
                            "上传照片视频",
                            style: TextStyle(fontSize: 14, fontFamily: "微软雅黑"),
                          )
                        ])),
                    PopupMenuItem(
                        height: 44,
                        child: Row(children: const [
                          Padding(
                            padding: EdgeInsets.only(left: 0, right: 5),
                            child: Icon(FluentIcons.fabric_folder),
                          ),
                          Text(
                            "照片文件夹",
                            style: TextStyle(fontSize: 14, fontFamily: "微软雅黑"),
                          )
                        ])),
                  ]);
            }
          },
          child: SizedBox(
            width: 30,
            height: 30,
            child: IconButton(
                icon: const Icon(
                  FluentIcons.add,
                  size: 16,
                ),
                style: ButtonStyle(
                    backgroundColor: ButtonState.all(Colors.blue),
                    foregroundColor: ButtonState.all(Colors.white),
                    shape: ButtonState.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)))),
                onPressed: null),
          ),
        ));
  }

//排序组件
  Widget _sortButtonWidget() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Listener(
        onPointerDown: (e) {
          showMenu(
              color: Colors.white,
              context: context,
              position: RelativeRect.fromLTRB(
                  e.position.dx,
                  e.position.dy - 24,
                  MediaQuery.of(context).size.width - e.position.dx,
                  MediaQuery.of(context).size.height - e.position.dy),
              items: [
                PopupMenuItem(
                    onTap: () {
                      _orderType = "title";
                      _getFilesData();
                    },
                    height: 44,
                    child: Row(children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 0, right: 10),
                        child: _orderType == "title"
                            ? const Icon(
                                FluentIcons.accept,
                                size: 12,
                              )
                            : const Text(""),
                      ),
                      const Text(
                        "资源名称",
                        style: TextStyle(fontSize: 14, fontFamily: "微软雅黑"),
                      )
                    ])),
                PopupMenuItem(
                    onTap: () {
                      _orderType = "modifyTime";
                    },
                    height: 44,
                    child: Row(children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 0, right: 10),
                        child: _orderType == "modifyTime"
                            ? const Icon(
                                FluentIcons.accept,
                                size: 12,
                              )
                            : const Text(""),
                      ),
                      const Text(
                        "修改时间",
                        style: TextStyle(fontSize: 14, fontFamily: "微软雅黑"),
                      )
                    ])),
                PopupMenuItem(
                    onTap: () {
                      _orderType = "size";
                      _getFilesData();
                    },
                    height: 44,
                    child: Row(children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 0, right: 10),
                        child: _orderType == "size"
                            ? const Icon(
                                FluentIcons.accept,
                                size: 12,
                              )
                            : const Text(""),
                      ),
                      const Text(
                        "文档大小",
                        style: TextStyle(fontSize: 14, fontFamily: "微软雅黑"),
                      )
                    ])),
                PopupMenuItem(
                  enabled: false,
                  height: 5,
                  child: Row(
                    children: const [Expanded(child: Divider())],
                  ),
                ),
                PopupMenuItem(
                    onTap: () {
                      _order = "asc";
                      _getFilesData();
                    },
                    height: 44,
                    child: Row(children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 0, right: 10),
                        child: _order == "asc"
                            ? const Icon(
                                FluentIcons.accept,
                                size: 12,
                              )
                            : const Text(""),
                      ),
                      const Text(
                        "升序",
                        style: TextStyle(fontSize: 14, fontFamily: "微软雅黑"),
                      )
                    ])),
                PopupMenuItem(
                    onTap: () {
                      _order = "desc";
                      _getFilesData();
                    },
                    height: 44,
                    child: Row(children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 0, right: 10),
                        child: _order == "desc"
                            ? const Icon(
                                FluentIcons.accept,
                                size: 12,
                              )
                            : const Text(""),
                      ),
                      const Text(
                        "降序",
                        style: TextStyle(fontSize: 14, fontFamily: "微软雅黑"),
                      )
                    ])),
              ]);
        },
        child: SizedBox(
          width: 120,
          child: Row(
            children: [
              const Icon(
                FluentIcons.sort,
                size: 12,
              ),
              const SizedBox(width: 8),
              _getOrderText()
            ],
          ),
        ),
      ),
    );
  }

  Widget _getOrderText() {
    if (_order == "asc") {
      if (_orderType == "title") {
        return const Text(
          "按照名称升序",
          style: TextStyle(fontSize: 12),
        );
      } else if (_orderType == "modifyTime") {
        return const Text(
          "按照修改时间升序",
          style: TextStyle(fontSize: 12),
        );
      } else {
        return const Text(
          "按照文档大小升序",
          style: TextStyle(fontSize: 12),
        );
      }
    } else {
      if (_orderType == "title") {
        return const Text(
          "按照名称降序",
          style: TextStyle(fontSize: 12),
        );
      } else if (_orderType == "modifyTime") {
        return const Text(
          "按照修改时间降序",
          style: TextStyle(fontSize: 12),
        );
      } else {
        return const Text(
          "按照文档大小降序",
          style: TextStyle(fontSize: 12),
        );
      }
    }
  }

//头部
  Widget _headerWidget(TransfersProvider transfersProvider) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  GestureDetector(
                    //点击文件回到根目录
                    onTap: () {
                      _folderName = "";
                      _diskPathList = [];
                      _getFilesData();
                    },
                    child: const MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Text(
                          "文件",
                          style: TextStyle(fontSize: 18, fontFamily: "微软雅黑"),
                        )),
                  ),
                  ..._diskPathList.map((v) {
                    return GestureDetector(
                      onTap: () {
                        /*
                       _folderName: golang桌面软件开发实战/runner/Release/xxxx
                        比如说点击了runner  路径需要变成： golang桌面软件开发实战/runner
                        比如说点击了Release  路径需要变成： golang桌面软件开发实战/runner/Release

                        */
                        _folderName = _folderName.split(v)[0] + v;
                        _diskPathList = _folderName.split("/");
                        _getFilesData();
                      },
                      child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Text(
                            ">$v",
                            style: TextStyle(fontSize: 18, fontFamily: "微软雅黑"),
                          )),
                    );
                  }).toList()
                ],
              ),
              SizedBox(
                width: 80,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                        icon: const Icon(
                          FluentIcons.search,
                          size: 16,
                        ),
                        onPressed: () {}),
                    _addButtonWidget(transfersProvider)
                  ],
                ),
              )
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //左侧
              SizedBox(
                width: 100,
                child: Row(
                  children: [
                    Checkbox(checked: false, onChanged: (v) {}),
                    Text("共10项")
                  ],
                ),
              ),
              //右侧
              SizedBox(
                width: 160,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _sortButtonWidget(),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: _isGridView
                            ? IconButton(
                                icon: const Icon(
                                  FluentIcons.collapse_menu,
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isGridView = !_isGridView;
                                  });
                                },
                              )
                            : IconButton(
                                icon: const Icon(
                                  FluentIcons.table,
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isGridView = !_isGridView;
                                  });
                                },
                              ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        )
      ],
    );
  }

//文件Icons图标
  Widget? _getListviewFileIcon(index) {
    if (_filesList[index].isFolder!) {
      return const Icon(
        FluentIcons.folder_fill,
        color: Color.fromRGBO(126, 145, 250, 1),
        size: 28,
      );
    } else if (_filesList[index].isFile! &&
        _filesList[index].suffix == '.zip') {
      return const Icon(
        Icons.folder_zip,
        size: 28,
        color: Color.fromRGBO(175, 81, 0, 1),
      );
    } else if (_filesList[index].isFile! &&
        _filesList[index].suffix == '.txt') {
      return const Icon(
        FluentIcons.file_comment,
        size: 28,
      );
    } else {
      return const Icon(
        Icons.file_copy_outlined,
        size: 28,
      );
    }
  }

//文件Icons图标
  Widget _getGridviewFileIcon(index) {
    if (_filesList[index].isFolder!) {
      return const Icon(
        FluentIcons.fabric_folder_fill,
        size: 68,
        color: Color.fromRGBO(126, 145, 250, 1),
      );
    } else if (_filesList[index].isFile! &&
        _filesList[index].suffix == '.zip') {
      return const Icon(
        Icons.folder_zip,
        size: 68,
        color: Color.fromRGBO(175, 81, 0, 1),
      );
    } else if (_filesList[index].isFile! &&
        _filesList[index].suffix == '.txt') {
      return const Icon(
        FluentIcons.file_comment,
        size: 68,
      );
    } else {
      return const Icon(
        Icons.file_copy_outlined,
        size: 68,
      );
    }
  }

//listView
  Widget _listViewWidget(TransfersProvider transfersProvider) {
    return ListView.builder(
        padding: const EdgeInsets.only(top: 20),
        itemCount: _filesList.length,
        itemBuilder: (context, index) {
          return ContextMenuArea(
              width: 200,
              builder: (c) {
                return [
                  ListTile(
                      title: const Text(
                        '下载',
                        style: TextStyle(fontSize: 14),
                      ),
                      onPressed: () async {
                        c.pop(); //隐藏ContextMenuArea  需要引入go-router
                        List userInfo = await UserService.getUserInfo();
                        String? outputFile = await FilePicker.platform.saveFile(
                          dialogTitle: '请选择保存文件目录',
                          fileName: _filesList[index].title, //保存的文件名
                        );

                        if (outputFile != null) {
                          downloadToast();

                          //判断下载的是目录还是文件
                          if (_filesList[index].isFile == true) {
                            // 下载文件
                            var sign = SignServices.getSign({
                              "fileName": _filesList[index].fullPath, //完整路径
                              "uid": userInfo[0]["uid"],
                              "salt": userInfo[0]["salt"], //私钥
                            });
                            var apiUrl =
                                "api/downlodFile?fileName=${_filesList[index].fullPath}&uid=${userInfo[0]["uid"]}&sign=$sign";
                            await httpsClient.downLoad(transfersProvider,
                                apiUrl, outputFile, _filesList[index].fullPath);
                          } else {
                            //下载文件夹  获取当前目录下面所有的文件

                            String downloadFilesStr;
                            if (_folderName == "") {
                              downloadFilesStr = _filesList[index].title!;
                            } else {
                              downloadFilesStr =
                                  "$_folderName/${_filesList[index].title!}";
                            }

                            List<OssModelItems> listFiles =
                                await _getDownloadFiles(downloadFilesStr);

                            for (OssModelItems value in listFiles) {
                              //判断value是文件还是文件夹 （根据后缀名判断是文件还是目录）
                              if (path.extension(value.fullPath!) != "") {
                                //获取后缀名，如果有后缀名就是文件
                                var sign = SignServices.getSign({
                                  "fileName": value.fullPath,
                                  "uid": userInfo[0]["uid"],
                                  "salt": userInfo[0]["salt"], //私钥
                                });
                                String apiUrl =
                                    "api/downlodFile?fileName=${value.fullPath}&uid=${userInfo[0]["uid"]}&sign=$sign";

                                if (_folderName == "") {
                                  //一级目录
                                  httpsClient.downLoad(
                                      transfersProvider,
                                      apiUrl,
                                      outputFile.replaceAll(
                                              _filesList[index].title!, "") +
                                          value.fullPath!,
                                      value.fullPath);
                                } else {
                                  //子目录
                                  httpsClient.downLoad(
                                      transfersProvider,
                                      apiUrl,
                                      outputFile.replaceAll(
                                              _filesList[index].title!, "") +
                                          value.fullPath!
                                              .replaceAll("$_folderName/", ""),
                                      value.fullPath);
                                }
                              } else {
                                //目录 空目录      aaa/        ccc/
                                Directory(outputFile.replaceAll(
                                            _filesList[index].title!, "") +
                                        value.fullPath!.substring(
                                            0, value.fullPath!.length - 1))
                                    .create(recursive: true);
                              }
                            }
                          }
                        }
                      }),
                  ListTile(
                    title: const Text(
                      '分享',
                      style: TextStyle(fontSize: 14),
                    ),
                    onPressed: () {},
                  ),
                  ListTile(
                    title: const Text(
                      '收藏',
                      style: TextStyle(fontSize: 14),
                    ),
                    onPressed: () {},
                  ),
                  ListTile(
                    title: const Text(
                      '重命名',
                      style: TextStyle(fontSize: 14),
                    ),
                    onPressed: () {},
                  ),
                  ListTile(
                    title: const Text(
                      '移动',
                      style: TextStyle(fontSize: 14),
                    ),
                    onPressed: () {},
                  ),
                  ListTile(
                    title: Text(
                      '删除',
                      style: TextStyle(color: Colors.red, fontSize: 14),
                    ),
                    onPressed: () {},
                  )
                ];
              },
              child: GestureDetector(
                onDoubleTap: () {
                  if (_filesList[index].isFolder == true) {
                    //文件夹
                    if (_folderName == "") {
                      _folderName = _filesList[index].title!;
                    } else {
                      _folderName = "$_folderName/${_filesList[index].title!}";
                    }
                    print(_folderName);
                    _diskPathList = _folderName.split("/");
                    print(_diskPathList);

                    _getFilesData();
                  }
                },
                child: HoverButton(
                    onPressed: () {}, //必须配置 配置以后才可以监听到state状态
                    builder: (context, state) {
                      // print(state);
                      // print(state.isHovering);
                      return Container(
                        decoration: BoxDecoration(
                            color: state.isHovering
                                ? Color.fromRGBO(245, 245, 246, 1)
                                : Colors.white),
                        padding: const EdgeInsets.all(6.0),
                        child: ListTile(
                          leading: _getListviewFileIcon(index),
                          title: Text(
                            "${_filesList[index].title}",
                            style: const TextStyle(fontSize: 14),
                          ),
                          trailing: Text(
                            "${DateTime.fromMillisecondsSinceEpoch(_filesList[index].modifyTime! * 1000)}",
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      );
                    }),
              ));
        });
  }

  Widget _gridViewWidget(TransfersProvider transfersProvider) {
    return GridView.builder(
        itemCount: _filesList.length,
        // 我们通过它可以快速的创建横轴子元素为固定最大长度的的GridView。
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          maxCrossAxisExtent: 160,
        ),
        itemBuilder: (context, index) {
          return ContextMenuArea(
              width: 200,
              builder: (c) {
                return [
                  ListTile(
                      title: const Text(
                        '下载',
                        style: TextStyle(fontSize: 14),
                      ),
                      onPressed: () async {
                        c.pop(); //隐藏ContextMenuArea  需要引入go-router
                        List userInfo = await UserService.getUserInfo();
                        String? outputFile = await FilePicker.platform.saveFile(
                          dialogTitle: '请选择保存文件目录',
                          fileName: _filesList[index].title, //保存的文件名
                        );

                        if (outputFile != null) {
                          downloadToast();
                          //判断下载的是目录还是文件
                          if (_filesList[index].isFile == true) {
                            // 下载文件
                            var sign = SignServices.getSign({
                              "fileName": _filesList[index].fullPath, //完整路径
                              "uid": userInfo[0]["uid"],
                              "salt": userInfo[0]["salt"], //私钥
                            });

                            var apiUrl =
                                "api/downlodFile?fileName=${_filesList[index].fullPath}&uid=${userInfo[0]["uid"]}&sign=$sign";
                            await httpsClient.downLoad(transfersProvider,
                                apiUrl, outputFile, _filesList[index].fullPath);
                          } else {
                            //下载文件夹  获取当前目录下面所有的文件

                            String downloadFilesStr;
                            if (_folderName == "") {
                              downloadFilesStr = _filesList[index].title!;
                            } else {
                              downloadFilesStr =
                                  "$_folderName/${_filesList[index].title!}";
                            }

                            List<OssModelItems> listFiles =
                                await _getDownloadFiles(downloadFilesStr);

                            for (OssModelItems value in listFiles) {
                              //判断value是文件还是文件夹 （根据后缀名判断是文件还是目录）
                              if (path.extension(value.fullPath!) != "") {
                                //获取后缀名，如果有后缀名就是文件
                                var sign = SignServices.getSign({
                                  "fileName": value.fullPath,
                                  "uid": userInfo[0]["uid"],
                                  "salt": userInfo[0]["salt"], //私钥
                                });
                                String apiUrl =
                                    "api/downlodFile?fileName=${value.fullPath}&uid=${userInfo[0]["uid"]}&sign=$sign";

                                if (_folderName == "") {
                                  //一级目录
                                  httpsClient.downLoad(
                                      transfersProvider,
                                      apiUrl,
                                      outputFile.replaceAll(
                                              _filesList[index].title!, "") +
                                          value.fullPath!,
                                      value.fullPath);
                                } else {
                                  //子目录
                                  httpsClient.downLoad(
                                      transfersProvider,
                                      apiUrl,
                                      outputFile.replaceAll(
                                              _filesList[index].title!, "") +
                                          value.fullPath!
                                              .replaceAll("$_folderName/", ""),
                                      value.fullPath);
                                }
                              } else {
                                //目录 空目录      aaa/        ccc/
                                Directory(outputFile.replaceAll(
                                            _filesList[index].title!, "") +
                                        value.fullPath!.substring(
                                            0, value.fullPath!.length - 1))
                                    .create(recursive: true);
                              }
                            }
                          }
                        }
                      }),
                  ListTile(
                    title: const Text(
                      '分享',
                      style: TextStyle(fontSize: 14),
                    ),
                    onPressed: () {},
                  ),
                  ListTile(
                    title: const Text(
                      '收藏',
                      style: TextStyle(fontSize: 14),
                    ),
                    onPressed: () {},
                  ),
                  ListTile(
                    title: const Text(
                      '重命名',
                      style: TextStyle(fontSize: 14),
                    ),
                    onPressed: () {},
                  ),
                  ListTile(
                    title: const Text(
                      '移动',
                      style: TextStyle(fontSize: 14),
                    ),
                    onPressed: () {},
                  ),
                  ListTile(
                    title: Text(
                      '删除',
                      style: TextStyle(color: Colors.red, fontSize: 14),
                    ),
                    onPressed: () {},
                  )
                ];
              },
              child: GestureDetector(
                  onDoubleTap: () {
                    if (_filesList[index].isFolder == true) {
                      //文件夹
                      if (_folderName == "") {
                        _folderName = _filesList[index].title!;
                      } else {
                        _folderName =
                            "$_folderName/${_filesList[index].title!}";
                      }
                      print(_folderName);
                      _diskPathList = _folderName.split("/");
                      print(_diskPathList);

                      _getFilesData();
                    }
                  },
                  child: HoverButton(
                      onPressed: () {}, //必须配置 配置以后才可以监听到state状态
                      builder: (context, state) {
                        // print(state);
                        // print(state.isHovering);
                        return Container(
                          decoration: BoxDecoration(
                              color: state.isHovering
                                  ? Color.fromRGBO(245, 245, 246, 1)
                                  : Colors.white),
                          padding: const EdgeInsets.all(6.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _getGridviewFileIcon(index),
                              Container(
                                padding: const EdgeInsets.all(5),
                                height: 46,
                                width: double.infinity,
                                child: Text(
                                  "${_filesList[index].title}",
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.clip,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              )
                            ],
                          ),
                        );
                      })));
        });
  }

  @override
  Widget build(BuildContext context) {
    TransfersProvider transfersProvider =
        Provider.of<TransfersProvider>(context);
    return ScaffoldPage.withPadding(
      header: _headerWidget(transfersProvider),
      content: _isGridView
          ? _gridViewWidget(transfersProvider)
          : _listViewWidget(transfersProvider),
    );
  }
}
