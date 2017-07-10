

class ErrorComponent extends BlazeComponent

  constructor: (args) ->
    super
    @errorDict = new ReactiveDict


  error: (key) ->
    @errorDict.get(key)

module.exports = ErrorComponent
