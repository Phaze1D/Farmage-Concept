
# Shared Schemas that are used in mulitple documents

{ SimpleSchema } = require 'meteor/aldeed:simple-schema'

AddressSchema = exports.AddressSchema =
  new SimpleSchema(

    name:
      type: String
      label: "address_name"
      max: 64
      optional: true

    street:
      type: String
      label: "street"
      max: 64

    street2:
      type: String
      label: "street2"
      optional: true
      max: 64

    city:
      type: String
      label: "city"
      max: 64

    state:
      type: String
      label: "state"
      max: 64

    zip_code:
      type: String
      label: "zip_code"
      max: 32

    country:
      type: String
      label: "country"
      optional: true
      max: 64
  )

TelephoneSchema = exports.TelephoneSchema =
  new SimpleSchema(
    name:
      type: String
      label: "telephone_name"
      optional: true
      max: 45

    number: # Need to add telephone regex validation
      type: String
      label: "telephone"
      max: 32
  )


exports.ContactSchema =
  new SimpleSchema(
    email:
      type: String
      label: "email"
      regEx: SimpleSchema.RegEx.Email
      index: true
      sparse: true
      optional: true
      max: 45

    addresses:
      type: [AddressSchema]
      optional: true
      defaultValue: []
      maxCount: 5

    telephones:
      type: [TelephoneSchema]
      optional: true
      defaultValue: []
      maxCount: 5
  )
