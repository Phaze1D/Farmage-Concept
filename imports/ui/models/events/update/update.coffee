EventModule = require '../../../../api/collections/events/events.coffee'
EMethods = require '../../../../api/collections/events/methods.coffee'




require './update.jade'

class EventsUpdate extends BlazeComponent
  @register 'eventsUpdate'

  constructor: (args) ->
    super

  onCreated: ->
    super
    @schema = EventModule.Events.simpleSchema()

  event: ->
    EventModule.Events.findOne @data().update_id

  forType: ->
    st = @event().for_type
    st.charAt(0).toUpperCase() + st.slice(1);

  identifer: ->
    name = @event().for_doc().fetch()[0].name
    if name? then name else @data().event.for_id

  update: (event_doc) ->
    organization_id = FlowRouter.getParam('organization_id')
    event_id = @data().update_id
    EMethods.update.call {organization_id, event_id, event_doc}, (err, res) =>
      console.log err
      $('.js-hide-new').trigger('click') unless err?

  onSubmit: (event) ->
    event.preventDefault()
    $form = $('.js-event-update-form')
    event_doc =
      description: $form.find('[name=description]').val()

    @update event_doc

  events: ->
    super.concat
      'submit .js-event-update-form': @onSubmit
      'click .js-submit-update-event': @onSubmit
