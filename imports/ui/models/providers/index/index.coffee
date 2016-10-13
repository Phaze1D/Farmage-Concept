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
    @canLoadMore = true
    @autorun =>
        @page = Meteor.subscribeWithPagination "providers", organization_id, 'organization', organization_id, 9,
                  onStop: (err) ->
                    console.log "sub stop #{err}"
                  onReady: ->


  providers: ->
    ProviderModule.Providers.find()

  ready: ->
    if @page.ready()
      count = ProviderModule.Providers.find().count()
      if @previous is count
        @canLoadMore = false
      else
        @canLoadMore = true
        @previous = count
