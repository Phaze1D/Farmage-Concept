require './PaperInput.tpl.jade'


class PaperInput extends BlazeComponent
  @register 'PaperInput'

  constructor: (args) ->

  onCreated: ->
    super
    @color = new ReactiveVar ''
    @colorL = new ReactiveVar ''
    @underline = new ReactiveVar ''
    @float = new ReactiveVar ''
    @charCount = new ReactiveVar "0/#{@data().charMax}"
    @textarea = @data().type is 'textarea'

  onRendered: ->
    $(@find('.pinput')).trigger('input')
    $(@find('.pinput')).trigger('focusout')

    $(@find('textarea')).textareaAutoSize();


  onFocusIn: (event) ->
    @underline.set('highlight')
    @color.set @data().focusColor
    @colorL.set @data().focusColor if event.target.value.length > 0

  onFocusOut: (event) ->
    @underline.set ''
    @color.set ''
    @colorL.set ''


  onInput: (event) ->
    empty = event.target.value.length <= 0
    @charCount.set("#{event.target.value.length}/#{@data().charMax}")
    if empty
      @float.set ''
      @colorL.set ''
    else if @data().labelFloat == 'false'
      @float.set('label-hidden')
    else
      @float.set('label-floating')
      @colorL.set @data().focusColor






  events: ->
    super.concat
      'focusin .pinput': @onFocusIn
      'focusout .pinput': @onFocusOut
      'input .pinput': @onInput