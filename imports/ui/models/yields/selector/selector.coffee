
require './selector.jade'

class YieldSelector extends BlazeComponent
  @register 'yieldsSelector'

  constructor: (args) ->
    # body...

  onCreated: ->
    super
    @data().isChecked = new ReactiveVar(@data().isChecked)

  onItemClick: (event) ->
    $(event.currentTarget).find('.js-checkbox').trigger('click')

  color: ->
    if @data().isChecked
      return 'darkblue'
    else
      return ''

  onItemClickCallback: ->
    ret =
      callback: (event) =>
        targ = $(@find '.js-list-item')
        if targ.attr('selected')
          @data().isChecked.set(false)
        else
          @data().isChecked.set(true)



  events: ->
    super.concat
      'click .js-list-item':@onItemClick
