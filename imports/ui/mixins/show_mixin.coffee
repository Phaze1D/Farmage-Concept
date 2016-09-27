class ShowMixin extends BlazeComponent

  onCreated: ->
    super
    @toolTitle = new ReactiveDict()
    @toolTitle.set 'shown', false
    @toolTitle.set 'title', ''
    @topShown = false
    @fabHidden = false
    @previous = 0
    @fabTitle = new ReactiveDict()
    @fabTitle.set('class', 'js-edit')
    @fabTitle.set('title', 'edit')

  onRendered: ->
    super
    @tabBar = $(@find '.tab-bar')
    @tabPanel = $(@find '.tab-main-wrapper')
    @fab = $(@find '.show-fab')
    @topT = $(@find '.top h3')

  toolT: ->
    @toolTitle.get('title')

  fabC: ->
    @fabTitle.get('class')

  fabT: ->
    @fabTitle.get('title')

  showFab: (duration) ->
    @fabHidden = false
    @fab.velocity
      p:
        scaleX: 1
        scaleY: 1
      o:
        duration: duration

  hideFab: (duration) ->
    @fabHidden = true
    @fab.velocity
      p:
        scaleX: 0
        scaleY: 0
      o:
        duration: duration


  changeFab: (index) ->
    if index is '0'
      @fabTitle.set('class', 'js-edit')
      @fabTitle.set('title', 'edit')
    else
      @fabTitle.set('class', 'js-add')
      @fabTitle.set('title', 'add')

  onScroll: (event) ->
    topHit = if window.innerWidth > 1024 then 207 else 177

    if event.target.scrollTop < topHit && @fabHidden && @previous > event.target.scrollTop
      @showFab(250)
    else if event.target.scrollTop > 0 && !@fabHidden && @previous < event.target.scrollTop
      @hideFab(250)

    if event.target.scrollTop >= topHit && !@topShown
      @topShown = true
      @tabPanel.css 'padding-top': '48px'
      @tabBar.css
        position: 'fixed'
        top: '64px'
      @tabBar.addClass('bottom-shadow')

    else if event.target.scrollTop < topHit && @topShown
      @topShown = false
      @tabPanel.css 'padding-top': ''
      @tabBar.css
        position: ''
        top: ''
      @tabBar.removeClass('bottom-shadow')

    tpo = topHit + 64 - @topT.position().top
    if event.target.scrollTop >= tpo && !@toolTitle.get('shown')
      @toolTitle.set 'shown', true
      @toolTitle.set 'title', @data().title
    else if event.target.scrollTop < tpo && @toolTitle.get('shown')
      @toolTitle.set 'shown', false
      @toolTitle.set 'title', ''

    @previous = event.target.scrollTop


  onTabClick: (event) ->
    attr = $(event.currentTarget).attr('data-index')
    if @fabHidden
      @changeFab(attr)
    else
      @fab.velocity
        p:
          scaleX: 0
          scaleY: 0
        o:
          duration: 250
          complete: =>
            @changeFab(attr)
      @showFab(250)

  onBackClick: (event) ->
    @hideFab(200)


  events: ->
    super.concat
      'scroll .scroll-section': @onScroll
      'click .show-tab': @onTabClick
      'click .card-shrink-action':@onBackClick


module.exports = ShowMixin
