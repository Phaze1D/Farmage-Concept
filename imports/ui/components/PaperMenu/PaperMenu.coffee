require './PaperMenu.tpl.jade'

class PaperMenu extends BlazeComponent
  @register "PaperMenu"

  constructor: (args) ->

  onCreated: ->

  toggleSubMenu: (event) ->
    subMenu = $(event.target).closest('.menu-item').find('.sub-menu:first')
    if subMenu.length > 0
      @showSub(subMenu) if subMenu.height() <= 0
      @hideSub(subMenu) if subMenu.height() > 0



  showSub: ($subMenu) ->
    $subMenu.velocity
      p:
        height: $subMenu[0].scrollHeight + 'px'
      o:
        duration: 250
        easing: 'ease-in-out'
        complete: (elements) ->
          $subMenu.css height: 'auto'




  hideSub: ($subMenu) ->
    $subMenu.velocity
      p:
        height: '0px'
      o:
        duration: 250
        easing: 'ease-in-out'
        complete: ->
          $subMenu.closest('.menu-item').find('.sub-menu').css height: '0px'

  events: ->
    super.concat
      'click .paper-item': @toggleSubMenu
