{ ReactiveVar } = require 'meteor/reactive-var'
{ ReactiveDict } = require 'meteor/reactive-dict'

require 'velocity-animate'

require './PaperPanel.tpl.jade'
require './PaperDrawer.tpl.jade'
require './PaperMain.tpl.jade'


class PaperPanel extends BlazeComponent
  @register "PaperPanel"

  constructor: (args) ->
    super
    @isWide = new ReactiveVar
    @startVars = {}

    @handleResize = @handleResize.bind(@)
    @scrimHandleMove = @scrimHandleMove.bind(@)
    @scrimHandleStart = @scrimHandleStart.bind(@)
    @scrimHandleEnd = @scrimHandleEnd.bind(@)
    @mainHandleMove = @mainHandleMove.bind(@)
    @mainHandleStart = @mainHandleStart.bind(@)
    @mainHandleEnd = @mainHandleEnd.bind(@)


  onCreated: ->
    super

  onRendered: ->
    super
    @handleResize()
    window.addEventListener 'resize', @handleResize

  onDestroyed: ->
    super
    window.removeEventListener 'resize', @handleResize
    @scrimRemoveEvents()
    @mainRemoveEvents()


  scrimRemoveEvents: ->
    scrim = document.getElementById('scrim')
    scrim.removeEventListener 'touchmove', @scrimHandleMove
    scrim.removeEventListener 'touchstart', @scrimHandleStart
    scrim.removeEventListener 'touchend', @scrimHandleEnd

  scrimAddEvents: ->
    scrim = document.getElementById('scrim')
    scrim.addEventListener 'touchstart', @scrimHandleStart
    scrim.addEventListener 'touchmove', @scrimHandleMove
    scrim.addEventListener 'touchend', @scrimHandleEnd

  mainRemoveEvents: ->
    main = document.getElementById('paper-main')
    main.removeEventListener 'touchstart', @mainHandleStart
    main.removeEventListener 'touchmove', @mainHandleMove
    main.removeEventListener 'touchend', @mainHandleEnd

  mainAddEvents: ->
    main = document.getElementById('paper-main')
    main.addEventListener 'touchstart', @mainHandleStart
    main.addEventListener 'touchmove', @mainHandleMove
    main.addEventListener 'touchend', @mainHandleEnd

  moveMainFoward: ->
    drawer = $("#paper-drawer")
    drawer.attr 'opened', 'false'
    drawer.removeClass('move-foward').addClass('move-back')
    $("#paper-main").removeClass('move-back').addClass('move-foward')
    $('#scrim').removeClass('show').addClass('hide')

  moveDrawerFoward: ->
    drawer = $("#paper-drawer")
    drawer.attr 'opened', 'true'
    drawer.removeClass('move-back').addClass('move-foward')
    $("#paper-main").removeClass('move-foward').addClass('move-back')
    $('#scrim').addClass('show').removeClass('hide') if @isWide.get()? && !@isWide.get()

  handleResize: ->

    if window.innerWidth < 1024 && (!@isWide.get()? || @isWide.get())
      $("#paper-main").velocity
        p:
          left: "0px"
        o:
          duration: 200
          easing: "ease-in-out"
      @isWide.set false
      @closeDrawer()

    if window.innerWidth >= 1024 && (!@isWide.get()? || !@isWide.get())
      $('#scrim').removeClass('show').addClass('hide')
      $("#paper-main").velocity
        p:
          left: "240px"
        o:
          duration: 200
          easing: "ease-in-out"
      @isWide.set true
      @openDrawer()

  openDrawer: (event) ->
    @moveDrawerFoward()
    drawer = $("#paper-drawer")
    drawer.velocity
      p:
        left: "0px"
      o:
        duration: 200
        easing: "ease-in-out"
        complete: =>
          @scrimAddEvents()
          @mainRemoveEvents()

  closeDrawer: (event) ->
    drawer = $("#paper-drawer")
    drawer.velocity
      p:
        left: "-240px"
      o:
        duration: 200
        easing: "ease-in-out"
        complete: =>
          @scrimRemoveEvents()
          @mainAddEvents()
          @moveMainFoward()

  toggleDrawer: (event) ->
    if $("#paper-drawer").attr('opened') is 'true'
      @closeDrawer() unless @isWide.get()
    else
      @openDrawer()

  scrimHandleStart: (event) ->
    @startVars.eventX = event.touches[0].pageX
    @startVars.drawerX = parseInt $('#paper-drawer').css('left')

  scrimHandleMove: (event) ->
    event.preventDefault()
    left = event.touches[0].pageX - @startVars.eventX + @startVars.drawerX
    left = -240 if left < -240
    left = 0 if left > 0
    $('#paper-drawer').css('left': "#{left}px")
    @startVars.left = left

  scrimHandleEnd: (event) ->
    if @startVars.left? && @startVars.left isnt 0
      @closeDrawer()
    @startVars = {}

  mainHandleStart: (event) ->
    @startVars.eventX = event.touches[0].pageX
    @startVars.drawerX = parseInt $('#paper-drawer').css('left')

  mainHandleMove: (event) ->
    event.preventDefault()
    @moveDrawerFoward()
    left = event.touches[0].pageX - @startVars.eventX + @startVars.drawerX
    left = -240 if left < -240
    left = 0 if left > 0
    $('#paper-drawer').css('left': "#{left}px")
    @startVars.left = left

  mainHandleEnd: (event) ->
    if @startVars.left? && @startVars.left isnt -240
      @openDrawer()
    else
      @moveMainFoward()

    @startVars = {}

  events: ->
    super.concat
      'click .toggle-drawer, click #scrim.show': @toggleDrawer
