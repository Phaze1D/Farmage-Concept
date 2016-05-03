{ Slingshot } = require 'meteor/edgee:slingshot'


Slingshot.fileRestrictions "receiptsUpload", {
  allowedFileTypes: ["image/png", "image/jpeg"]
  maxSize: 10 * 1024
}
