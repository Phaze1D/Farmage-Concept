IndexMixin = require '../../../mixins/index_mixin.coffee'
ProviderModule = require '../../../../api/collections/providers/providers.coffee'



require './index.jade'

class ProvidersIndex extends IndexMixin
  @register 'providers.index'

  constructor: (args) ->
    super

  onCreated: ->
    super
    organization_id = FlowRouter.getParam("organization_id")
    @autorun =>
      @subscribe "providers", organization_id,
        onStop: (err) ->
          console.log "sub stop #{err}"
        onReady: ->




  providers: ->
    ProviderModule.Providers.find()
