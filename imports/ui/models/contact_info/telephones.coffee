

require './telephones.jade'


class TelephoneAdd extends BlazeComponent
  @register 'telephonesAdd'

  constructor: (args) ->
    super


  onCreated: ->
    @telephones = new ReactiveVar([])
    @data().title = 'Telephone' unless @data().title?

  onRendered: ->
    super

  initHeight: ->
    if @telephones.get().length > 0
      return 'auto'
    return '0px'

  showTelephone: (event) ->
    @addTelephone()
    target = $(@find '.atcontact-div')
    target.velocity
      p:
        height: target.height() + 60
      o:
        duration: 250
        easing: 'linear'
        complete: ->
          target.css height: 'auto'


  addTelephone: ->
    temp = @telephones.get()
    temp.push name: '', number: ''
    @telephones.set temp

    # if temp.length is @data().max
      # $('.js-add-telephone-b').velocity
      #   p:
      #     opacity: 0
      #   o:
      #     duration: 200
      #     complete: ->
      #       $('.js-add-telephone-b').css display: 'none'



  hideTelephone: (event) ->
    $(@find '.atcontact-div').css height: 'auto'
    target = $(event.target).closest('.contact-single')
    index = target.attr('data-index')
    target.velocity
      p:
        height: 0
      o:
        duration: 250
        easing: 'linear'
        complete: =>
          $(@find '.atcontact-div').css height: $(@find '.atcontact-div').height()
          target.css height: 'auto'
          @removeTelephone(index)




  removeTelephone: (index) ->
    if @telephones.get().length is @data().max
      $('.js-add-telephone-b').css display: 'inline-block'
      $('.js-add-telephone-b').velocity
        p:
          opacity: 1
        o:
          duration: 200

    teles = []
    for telephone, i in @telephones.get()
      if i isnt Number index
        telephone.name = $(".index-#{i}").find('[name=telephone_name]').val()
        telephone.number = $(".index-#{i}").find('[name=number]').val()
        teles.push telephone

    @telephones.set(teles)





  events: ->
    super.concat
      'click .js-add-telephone-b': @showTelephone
      'click .js-remove-telephone-b': @hideTelephone
