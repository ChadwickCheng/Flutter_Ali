//这里可以是fluent_ui也可以是 material.dart
import 'package:fluent_ui/fluent_ui.dart';

import '../models/transfersModel.dart';

class TransfersProvider with ChangeNotifier {
  //_fileList 属性
  List<TransfersModel> _fileList = [];

  List<TransfersModel> get fileList => _fileList; //获取状态
  //更新状态
  updateData(TransfersModel fileData) {
    //fileData上传下载的文件以及进度
    if (hasFileData(fileData)) {
      for (var v in _fileList) {
        if (v.title == fileData.title && v.type == fileData.type) {
          v.transferSize = fileData.transferSize;
          v.status = fileData.status;
        }
      }
    } else {
      _fileList.add(fileData);
    }

    notifyListeners(); //表示更新状态
  }

  //判断_fileList里面有没有fileData
  hasFileData(TransfersModel fileData) {
    for (var v in _fileList) {
      if (v.title == fileData.title && v.type == fileData.type) {
        return true;
      }
    }
    return false;
  }
}
