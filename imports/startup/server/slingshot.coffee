
{ Slingshot } = require 'meteor/edgee:slingshot'

Slingshot.fileRestrictions "receiptsUpload", {
  allowedFileTypes: ["image/png", "image/jpeg"]
  maxSize: 10 * 1024
}


Slingshot.createDirective "receiptsUpload", Slingshot.S3Storage,
  bucket: "sa-units-dev"

  acl: "public-read"

  authorize: () ->
    if !this.userId
      message = "Please login before posting files";
      throw new Meteor.Error("notLoggedIn", message);

    return true;

  key: (file, organization_id) ->
    user = Meteor.users.findOne(this.userId);
    return "receipts/" + organization_id + "/"+ file.name;
