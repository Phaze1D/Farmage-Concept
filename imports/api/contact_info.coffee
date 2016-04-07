
# Shared Schemas that are used in mulitple documents

AddressSchema =
  new SimpleSchema(

    name:
      type: String
      label: TAPi18n.__ "address_name"
      max: 45
      optional: true

    street:
      type: String
      label: TAPi18n.__ "street"
      max: 45

    street2:
      type: String
      label: TAPi18n.__ "street2"
      optional: true
      max: 45

    city:
      type: String
      label: TAPi18n.__ "city"
      max: 45

    state:
      type: String
      label: TAPi18n.__ "state"
      max: 45

    zip_code:
      type: Number
      label: TAPi18n.__ "zip_code"
      max: 999999999

    country:
      type: String
      label: TAPi18n.__ "country"
      optional: true
      max: 45
  )

TelephoneSchema =
  new SimpleSchema(
    name:
      type: String
      label: TAPi18n.__ "telephone_name"
      optional: true
      max: 45

    number:
      type: String
      label: TAPi18n.__ "telephone"
      max: 20
  )


share.ContactSchema =
  new SimpleSchema(
    email:
      type: String
      label: TAPi18n.__ "email"
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
