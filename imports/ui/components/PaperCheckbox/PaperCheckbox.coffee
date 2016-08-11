require './PaperCheckbox.tpl.jade'


class PaperCheckbox extends BlazeComponent
  @register 'PaperCheckbox'

  constructor: (args) ->
    @color = new ReactiveVar('black')

  onClick: (event) ->
    event.stopImmediatePropagation()
    tar = $(event.currentTarget).find('.checkbox-mark')
    tar.toggleClass('checked')
    if @color.get() isnt @data().fcolor
      @color.set @data().fcolor
    else
      @color.set 'black'



  events: ->
    super.concat
      'click .js-checkbox': @onClick
