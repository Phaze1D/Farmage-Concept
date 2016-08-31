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
    @data().size = "size-small" unless @data().size?
    @data().labelFloat = true unless @data().labelFloat?


  onRendered: ->
    $(@find('.pinput')).trigger('input')
    $(@find('.pinput')).trigger('focusout')
    $(@find('textarea')).textareaAutoSize();

    @float.set('label-floating') if @data().alwaysFloating



  onFocusIn: (event) ->
    @underline.set('highlight')
    @color.set @data().focusColor
    @colorL.set @data().focusColor if event.target.value.length > 0
    if @data().labelFloat
      @float.set('label-floating')
      if @data().prefix?
        $(@find '.input-label').css left: "-#{$(@find('.prefix')).outerWidth() + 1}px"
    else
      @float.set('label-hidden') unless @data().alwaysFloating

    @colorL.set @data().focusColor


  onFocusOut: (event) ->
    @onInput(event.target)
    @underline.set ''
    @color.set ''
    @colorL.set ''




  onInput: (input) ->

    if input.value.length <= 0
      @colorL.set ''
      if @data().alwaysFloating
        if @data().prefix?
          $(@find '.input-label').css left: "-#{$(@find('.prefix')).outerWidth() + 1}px"
      else
        $(@find '.input-label').css left: '0px'
        @float.set ''

    else if @data().labelFloat
      @float.set('label-floating')
      if @data().prefix?
        $(@find '.input-label').css left: "-#{$(@find('.prefix')).outerWidth() + 1}px"
    else
      @float.set('label-hidden') unless @data().alwaysFloating


  onCharInput: (event) ->
    if @data().showCount
      input = @find('.pinput')
      @charCount.set("#{input.value.length}/#{@data().charMax}")





  events: ->
    super.concat
      'focusin .pinput': @onFocusIn
      'focusout .pinput': @onFocusOut
      'input .pinput': @onCharInput
