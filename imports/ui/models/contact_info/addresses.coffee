
# Show Animation is weird pls fix

require './addresses.jade'

class AddressAdd extends BlazeComponent
  @register 'addressesAdd'

  constructor: (args) ->


  onCreated: ->
    @addresses = new ReactiveVar([])
    @data().title = 'Address' unless @data().title?


  onRendered: ->
    super

  initHeight: ->
    if @addresses.get().length > 0
      return 'auto'
    return '0px'

  showAddress: (event) ->
    @addAddress()
    target = $(@find '.atcontact-div')
    target.velocity
      p:
        height: target.height() + 270
      o:
        duration: 250
        easing: 'linear'
        complete: ->
          target.css height: 'auto'


  addAddress: ->
    temp = @addresses.get()
    temp.push name: '', number: ''
    @addresses.set temp

    # if temp.length is @data().max
    #   $('.js-add-address-b').velocity
    #     p:
    #       opacity: 0
    #     o:
    #       duration: 200
    #       complete: ->
    #         $('.js-add-address-b').css display: 'none'

    # if temp.length is 1
    #   $('.js-add-address-b').css 'margin-top': '0'



  hideAddress: (event) ->
    # if @addresses.get().length is 1
    #   # $('.js-add-address-b').css 'margin-top': '20px'

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
          @removeAddress(index)




  removeAddress: (index) ->

    if @addresses.get().length is @data().max
      $('.js-add-address-b').css display: 'inline-block'
      $('.js-add-address-b').velocity
        p:
          opacity: 1
        o:
          duration: 200

    adds = []
    for address, i in @addresses.get()
      if i isnt Number index
        address.name = $(".index-#{i}").find('[name=address_name]').val()
        address.street = $(".index-#{i}").find('[name=street]').val()
        address.street2 = $(".index-#{i}").find('[name=street2]').val()
        address.city = $(".index-#{i}").find('[name=city]').val()
        address.state = $(".index-#{i}").find('[name=state]').val()
        address.zip_code = $(".index-#{i}").find('[name=zip_code]').val()
        address.country = $(".index-#{i}").find('[name=country]').val()

        adds.push address

    @addresses.set(adds)





  events: ->
    super.concat
      'click .js-add-address-b': @showAddress
      'click .js-remove-address-b': @hideAddress
