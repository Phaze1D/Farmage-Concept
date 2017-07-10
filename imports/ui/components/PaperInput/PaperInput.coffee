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
    @errorLine = new ReactiveVar ''
    @error = new ReactiveVar
    @charCount = new ReactiveVar "0/#{@data().charMax}"
    @textarea = @data().type is 'textarea'
    @fi = false
    @data().size = "size-small" unless @data().size?
    @data().labelFloat = true unless @data().labelFloat?


  onRendered: ->
    $(@find('.pinput')).trigger('input')
    $(@find('.pinput')).trigger('focusout')
    $(@find('textarea')).textareaAutoSize();

    @float.set('label-floating') if @data().alwaysFloating



  onFocusIn: (event) ->
    @fi = true
    @underline.set('highlight')
    @color.set @data().focusColor
    if @data().labelFloat
      @float.set('label-floating')
      if @data().prefix?
        $(@find '.input-label').css left: "-#{$(@find('.prefix')).outerWidth() + 1}px"
    else
      @float.set('label-hidden') unless @data().alwaysFloating

    if @error.get()?
      @colorL.set '#dd2c00'
    else
      @colorL.set @data().focusColor


  onFocusOut: (event) ->
    @onInput(event.target)
    @underline.set ''
    @color.set ''
    @colorL.set ''
    if @fi
      @fi = false
      @validate(event.currentTarget.value)


  validate: (value) ->
    if @data().schema
      obj = {}
      obj[@data().name] = value
      @data().schema.clean(obj)
      context = @data().schema.namedContext()
      if context.validateOne(obj, @data().name)
        @error.set null
        @errorLine.set ''
        @colorL.set ''
      else
        @error.set context.keyErrorMessage(@data().name)
        @errorLine.set 'highlight'


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


  onChange: (event) ->
    console.log 'acahgn'
    @validate(event.currentTarget.value)


  events: ->
    super.concat
      'focusin .pinput': @onFocusIn
      'focusout .pinput': @onFocusOut
      'input .pinput': @onCharInput
