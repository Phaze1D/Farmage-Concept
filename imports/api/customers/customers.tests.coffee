
CustomersModule = require 'meteor/steadypathstudios:sa-core'
Customers = CustomersModule.Customers

describe "Testing customers collection on the client side", () ->

  it "Customers validation only without organization_id", () ->
    doc =
      first_name: 'David'


    expect(Customers.simpleSchema().namedContext().validate(doc)).to.equal(false) # Should return false because invalid ( Client must have organization_id )

    return
