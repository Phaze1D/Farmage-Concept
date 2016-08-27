{ ReactiveVar } = require 'meteor/reactive-var'
{ ReactiveDict } = require 'meteor/reactive-dict'

require './PaperDrawerPanel.tpl.jade'
require './PaperDrawer.tpl.jade'
require './PaperDrawerMain.tpl.jade'


class PaperDrawerPanel extends BlazeComponent
  @register "PaperDrawerPanel"

  constructor: (args) ->
    super
    @isWide = new ReactiveVar
    @startVars = {}
    @ticking = false

    @throttle = @throttle.bind(@)
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
    @handleResize(0)
    window.addEventListener 'resize', @throttle


  onDestroyed: ->
    super
    window.removeEventListener 'resize', @throttle


  throttle: (e) ->
    unless @ticking
      window.requestAnimationFrame =>
        @handleResize()
        @ticking = false;
    @ticking = true;


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
    main = document.getElementById('touch-div')
    main.removeEventListener 'touchstart', @mainHandleStart
    main.removeEventListener 'touchmove', @mainHandleMove
    main.removeEventListener 'touchend', @mainHandleEnd

  mainAddEvents: ->
    main = document.getElementById('touch-div')
    main.addEventListener 'touchstart', @mainHandleStart
    main.addEventListener 'touchmove', @mainHandleMove
    main.addEventListener 'touchend', @mainHandleEnd

  moveMainFoward: ->
    drawer = $("#paper-drawer")
    drawer.attr 'opened', 'false'
    drawer.removeClass('move-foward').addClass('move-back')
    $("#paper-drawer-main").removeClass('move-back').addClass('move-foward')
    $('#scrim').removeClass('mshow').addClass('mhide')

  moveDrawerFoward: ->
    drawer = $("#paper-drawer")
    drawer.attr 'opened', 'true'
    drawer.removeClass('move-back').addClass('move-foward')
    $("#paper-drawer-main").removeClass('move-foward').addClass('move-back')
    $('#scrim').addClass('mshow').removeClass('mhide') if @isWide.get()? && !@isWide.get()

  handleResize: (duration = 250) ->
    if window.innerWidth < 1024 && (!@isWide.get()? || @isWide.get())
      $("#paper-drawer").removeClass('elevation-0')
      p =
        left: "0px"
      o =
        duration: duration

      $("#paper-drawer-main").velocity p,o
      @isWide.set false
      @closeDrawer()

    if window.innerWidth >= 1024 && (!@isWide.get()? || !@isWide.get())
      $('#scrim').removeClass('mshow').addClass('mhide')
      $("#paper-drawer").addClass('elevation-0')
      p =
        left: "240px"
      o =
        duration: duration
        easing: 'ease-in-out'

      $("#paper-drawer-main").velocity p, o
      @isWide.set true
      @openDrawer()

  openDrawer: (event) ->
    @moveDrawerFoward()
    p =
      left: "0px"
    o =
      duration: 250
      easing: "ease-in-out"
      complete: =>
        @scrimAddEvents()
        @mainRemoveEvents()

    $("#paper-drawer").velocity p, o

  closeDrawer: (event) ->
    $('#scrim').addClass('mhide')
    p =
      left: "-240px"
    o =
      duration: 250
      easing: "ease-in-out"
      complete: =>
        @scrimRemoveEvents()
        @mainAddEvents()
        @moveMainFoward()

    $("#paper-drawer").velocity p, o

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
      'click .toggle-drawer, click #scrim.mshow': @toggleDrawer
