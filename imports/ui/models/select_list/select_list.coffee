require './select_list.jade'


class SelectList extends BlazeComponent
  @register 'selectList'

  onCreated: ->
    organization_id = FlowRouter.getParam 'organization_id'
    @autorun =>
      @subscribe @data().subscription, organization_id,
        onStop: (err) ->
          console.log "sub stop #{err}"
        onReady: ->


  title: ->
    string = @data().subscription
    string.charAt(0).toUpperCase() + string.slice(1);
