import 'package:dio/dio.dart';

import '../models/transfersModel.dart';
import '../provider/transferProvider.dart';
import 'package:path/path.dart' as path; //获取后缀名

class HttpsClient {
  static String domain = "https://netdisk.itying.com/";
  static Dio dio = Dio();
  HttpsClient() {
    dio.options.baseUrl = domain;
    dio.options.connectTimeout = const Duration(milliseconds: 5000); //5s
  }

  Future get(apiUrl) async {
    try {
      var response = await dio.get(apiUrl);
      return response;
    } catch (e) {
      print("请求超时");
      return null;
    }
  }

  Future post(String apiUrl, {Map? data}) async {
    try {
      var response = await dio.post(apiUrl, data: data);
      return response;
    } catch (e) {
      print("请求超时");
      return null;
    }
  }

  //上传文件
  Future uploadFile(TransfersProvider transfersProvider, String apiUrl,
      Map<String, dynamic> params, String filePath) async {
    try {
      params["file"] = await MultipartFile.fromFile(filePath); //上传的文件
      final formData = FormData.fromMap(params);
      final response = await dio.post(apiUrl, data: formData,
          onSendProgress: (int sent, int total) {
        int status = 0;
        if (sent == total) {
          status = 1;
        }
        var fileData = TransfersModel(
            title: params["dst"],
            modifyTime: DateTime.now().millisecondsSinceEpoch,
            size: total,
            status: status,
            transferSize: sent,
            type: 1, //上传文件
            suffix: path.extension(params["dst"]));
        transfersProvider.updateData(fileData);
      });
      return response;
    } catch (e) {
      print("请求超时");
      return null;
    }
  }

  //替换路径
  String replaeUri(uri) {
    return uri.replaceAll("\\", "/");
  }

  //下载文件
  Future downLoad(
      TransfersProvider transfersProvider, apiUrl, savePath, title) async {
    try {
      await dio.download(apiUrl, savePath, onReceiveProgress: (sent, total) {
        if (total != -1) {
          print('$sent $total');
          int status = 0;
          if (sent == total) {
            status = 1;
          }
          var fileData = TransfersModel(
              title: title,
              modifyTime: DateTime.now().millisecondsSinceEpoch,
              size: total,
              status: status,
              transferSize: sent,
              type: 2, //下载文件
              suffix: path.extension(title));
          transfersProvider.updateData(fileData);
        }
      });
    } catch (e) {
      print("请求超时");
      return null;
    }
  }
}
