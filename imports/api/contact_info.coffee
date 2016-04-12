
# Shared Schemas that are used in mulitple documents

{ SimpleSchema } = require 'meteor/aldeed:simple-schema'

exports.AddressSchema =
  new SimpleSchema(

    name:
      type: String
      label: "address_name"
      max: 45
      optional: true

    street:
      type: String
      label: "street"
      max: 45

    street2:
      type: String
      label: "street2"
      optional: true
      max: 45

    city:
      type: String
      label: "city"
      max: 45

    state:
      type: String
      label: "state"
      max: 45

    zip_code:
      type: Number
      label: "zip_code"
      max: 999999999

    country:
      type: String
      label: "country"
      optional: true
      max: 45
  )

exports.TelephoneSchema =
  new SimpleSchema(
    name:
      type: String
      label: "telephone_name"
      optional: true
      max: 45

    number:
      type: String
      label: "telephone"
      max: 20
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
      max: 5

    telephones:
      type: [TelephoneSchema]
      optional: true
      max: 5
  )
