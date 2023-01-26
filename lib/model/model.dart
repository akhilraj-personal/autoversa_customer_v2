class NotificationModel {
  var nt_id;
  var nt_header;
  var nt_content;
  var nt_created_on;
  var pkg_name;
  var nt_read;
  var nt_bookid;
  var cv_make;
  var cv_model;
  var cv_variant;
  var cv_year;
  var st_code;

  NotificationModel({
    this.nt_id,
    this.nt_header,
    this.nt_content,
    this.nt_created_on,
    this.pkg_name,
    this.nt_read,
    this.nt_bookid,
    this.cv_make,
    this.cv_model,
    this.cv_variant,
    this.cv_year,
    this.st_code,
  });
}

class VehicleModel {
  var cv_id;
  var cv_make;
  var cv_model;
  var cv_variant;
  var cv_year;
  var cv_vinnumber;
  var cv_plate_number;
  var cv_odometer;
  var cv_group_id;
  var cv_cust_id;
  var cv_created_on;
  var cv_created_by;
  var cv_updated_on;
  var cv_updated_by;
  var cv_status_flag;
  var cv_delete_flag;

  VehicleModel(
      {this.cv_id,
      this.cv_make,
      this.cv_model,
      this.cv_variant,
      this.cv_year,
      this.cv_vinnumber,
      this.cv_plate_number,
      this.cv_odometer,
      this.cv_group_id,
      this.cv_cust_id,
      this.cv_created_on,
      this.cv_created_by,
      this.cv_updated_on,
      this.cv_updated_by,
      this.cv_status_flag,
      this.cv_delete_flag});
}

class AddressModel {
  var cad_id;
  var cad_address;
  var cad_landmark;
  var cad_address_type;
  var cad_lattitude;
  var cad_longitude;
  var state_name;
  var country_code;
  var city_name;
  var cad_distance;

  AddressModel({
    this.cad_id,
    this.cad_address,
    this.cad_landmark,
    this.cad_address_type,
    this.cad_lattitude,
    this.cad_longitude,
    this.state_name,
    this.country_code,
    this.city_name,
    this.cad_distance,
  });
}

class MessageModel {
  String? img;
  String? name;
  String? message;
  String? lastSeen;

  MessageModel({this.img, this.name, this.message, this.lastSeen});
}

class AMMessageModel {
  int? senderId;
  int? receiverId;
  String? msg;
  String? time;
  String? username;

  AMMessageModel(
      {this.senderId, this.receiverId, this.msg, this.time, this.username});
}

class ServiceListdata {
  String? service;
  String? date;
  String? month;
  String? doctor;
  String? patient;
  String? department;

  ServiceListdata(
      {this.service,
      this.date,
      this.month,
      this.doctor,
      this.patient,
      this.department});
}

class AMSeviceModel {
  var serid;
  var sername;
  var ser_type;
  var serdesctypeid;
  var ser_desc = [];
  var ser_pack_desc = [];
  var sercost;
  var packcost;
  bool isPackageCheck;
  bool isServiceCheck;

  AMSeviceModel(
      {this.serid,
      this.sername,
      this.ser_type,
      this.serdesctypeid,
      this.sercost,
      this.packcost,
      this.isServiceCheck = false,
      this.isPackageCheck = false});
}
