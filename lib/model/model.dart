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
  });
}
