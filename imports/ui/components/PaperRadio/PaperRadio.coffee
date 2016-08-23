require './PaperRadio.tpl.jade'


class PaperRadio extends BlazeComponent
  @register 'PaperRadio'

  onCreated: ->
    super
    @color = new ReactiveVar('black')
    if @data().checked
      @data().checked = 'checked'
      @color.set @data().fcolor
    else
      @data().checked = ''

  onClick: (event) ->
    event.stopImmediatePropagation()
    if @data().clickCallback.callback?
      @data().clickCallback.callback(event)

    tar = $(event.currentTarget).find('.radio-mark')
    tar.toggleClass('checked')
    if @color.get() isnt @data().fcolor
      @color.set @data().fcolor
    else
      @color.set 'black'



  events: ->
    super.concat
      'click .js-radio': @onClick
