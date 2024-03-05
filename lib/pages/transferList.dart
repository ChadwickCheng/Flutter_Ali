import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' show Icons, LinearProgressIndicator;
import 'package:provider/provider.dart';

import '../provider/transferProvider.dart';

class TransferListPage extends StatefulWidget {
  const TransferListPage({super.key});

  @override
  State<TransferListPage> createState() => _TransferListPageState();
}

class _TransferListPageState extends State<TransferListPage> {
  Widget _getFileIcon(suffix) {
    if (suffix == "") {
      return const Icon(
        FluentIcons.folder_fill,
        color: Color.fromRGBO(126, 145, 250, 1),
        size: 28,
      );
    } else if (suffix == '.zip') {
      return const Icon(
        Icons.folder_zip,
        size: 28,
        color: Color.fromRGBO(175, 81, 0, 1),
      );
    } else if (suffix == '.txt') {
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

  @override
  Widget build(BuildContext context) {
    TransfersProvider transfersProvider =
        Provider.of<TransfersProvider>(context);
    return ScaffoldPage.withPadding(
        padding: const EdgeInsets.all(10),
        content: Stack(
          children: [
            _ListViewWidget(transfersProvider),
            _SubHeaderWidget(),
          ],
        ));
  }

  getDate(modifyTime) {
    DateTime d = DateTime.fromMillisecondsSinceEpoch(modifyTime);
    int yearNow = d.year; //当前年份
    int monthNow = d.month; //当前月份
    int dayOfMonthNow = d.day; //当前日期
    return "$yearNow-$monthNow-$dayOfMonthNow";
  }

  Widget _ListViewWidget(TransfersProvider transfersProvider) {
    return ListView.builder(
        padding: const EdgeInsets.only(top: 50),
        itemCount: transfersProvider.fileList.length,
        itemBuilder: (context, index) {
          return Row(
            children: [
              Expanded(
                  child: Container(
                height: 52,
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    _getFileIcon(transfersProvider.fileList[index].suffix),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 400,
                      child: Text(
                        "${transfersProvider.fileList[index].title}",
                        overflow: TextOverflow.clip,
                      ),
                    )
                  ],
                ),
              )),
              Container(
                height: 52,
                alignment: Alignment.centerLeft,
                width: 180,
                child: Text(
                    getDate(transfersProvider.fileList[index].modifyTime!)),
              ),
              Container(
                  height: 52,
                  alignment: Alignment.centerLeft,
                  width: 60,
                  child: Column(
                    children: [
                      Text(
                          "${(transfersProvider.fileList[index].transferSize! / transfersProvider.fileList[index].size! * 100).toStringAsFixed(0)} % "),
                      LinearProgressIndicator(
                        value: transfersProvider.fileList[index].transferSize! /
                            transfersProvider.fileList[index].size!,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                        backgroundColor: const Color.fromRGBO(235, 235, 235, 1),
                      )
                    ],
                  ))
            ],
          );
        });
  }

  Widget _SubHeaderWidget() {
    return Positioned(
        height: 40,
        width: MediaQuery.of(context).size.width - 220,
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                  bottom: BorderSide(
                      color: Color.fromARGB(255, 238, 235, 233), width: 0.5))),
          height: 48,
          child: Row(
            children: [
              Expanded(
                  child: Container(
                alignment: Alignment.centerLeft,
                child: const Text("名称"),
              )),
              Container(
                alignment: Alignment.centerLeft,
                width: 180,
                child: const Text("修改时间"),
              ),
              Container(
                alignment: Alignment.centerLeft,
                width: 100,
                child: const Text("状态"),
              )
            ],
          ),
        ));
  }
}
