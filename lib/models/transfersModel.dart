class TransfersModel {
  String? title;
  int? status; //0 未完成  1表示完成
  int? size;
  int? transferSize;
  int? modifyTime;
  int? type; //1 表示上传  2表示下载
  String? suffix;
  TransfersModel(
      {this.title,
      this.status,
      this.size,
      this.transferSize,
      this.modifyTime,
      this.type,
      this.suffix});
}
