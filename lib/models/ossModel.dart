class OssModel {
  List<OssModelItems>? files;
  String? message;
  bool? success;

  OssModel({this.files, this.message, this.success});

  OssModel.fromJson(Map<String, dynamic> json) {
    if (json['files'] != null) {
      files = <OssModelItems>[];
      json['files'].forEach((v) {
        files!.add(OssModelItems.fromJson(v));
      });
    }
    message = json['message'];
    success = json['success'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (this.files != null) {
      data['files'] = this.files!.map((v) => v.toJson()).toList();
    }
    data['message'] = this.message;
    data['success'] = this.success;
    return data;
  }
}

class OssModelItems {
  String? title;
  String? fullPath;
  bool? isFolder;
  bool? isFile;
  String? suffix;
  int? size;
  int? modifyTime;
  String? modifyTimeStr;

  OssModelItems(
      {this.title,
      this.fullPath,
      this.isFolder,
      this.isFile,
      this.suffix,
      this.size,
      this.modifyTime,
      this.modifyTimeStr});

  OssModelItems.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    fullPath = json['full_path'];
    isFolder = json['is_folder'];
    isFile = json['is_file'];
    suffix = json['suffix'];
    size = json['size'];
    modifyTime = json['modify_time'];
    modifyTimeStr = json['modify_time_str'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['full_path'] = this.fullPath;
    data['is_folder'] = this.isFolder;
    data['is_file'] = this.isFile;
    data['suffix'] = this.suffix;
    data['size'] = this.size;
    data['modify_time'] = this.modifyTime;
    data['modify_time_str'] = this.modifyTimeStr;
    return data;
  }
}
