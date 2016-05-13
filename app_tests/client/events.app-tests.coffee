{ SimpleSchema }  = require  'meteor/aldeed:simple-schema'

describe "Atesing", ->
  it "etsting", ->
    yd = {}
    yd["nono"] = 0
    yd["nono"] += (1/2)
    console.log yd

    for i in [0..10]
      console.log i

    unless 1/2 is 2
      console.log "nsfd"
