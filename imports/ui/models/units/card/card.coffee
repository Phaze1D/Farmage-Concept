CardEvents = require '../../../mixins/card_events_mixin.coffee'

require './card.jade'

class UnitCard extends BlazeComponent
  @register 'UnitCard'

  mixins: -> [
    CardEvents
  ]

  constructor: (args) ->
    super

  onCreated: ->
    super
    @barSelected = new ReactiveVar
    @barSelected.set info: '$12.98', span: 'Last 5 Days'

  onRendered: ->
    super
    expensesChart = $(@find '.expenses-chart')
    options =
      legend:
        display: false
      title:
        display: false
      maintainAspectRatio: false
      scales:
        xAxes: [
                ticks:
                  fontSize: 10
                gridLines:
                  display: false
               ]

        yAxes: [
                ticks:
                  fontSize: 10
                gridLines:
                  drawBorder: false
                ]

    data =

      labels: ["Nov 30", "Nov 31", "Sep 01", "Sep 02", "Sep 03"]
      datasets: [
                  fill: false
                  data: [65, 59, 80, 81, 56]
                ]

    expensesLine = new Chart(expensesChart,
      {
        type: 'line'
        data: data
        options: options
      }
    )


  isTracking: ->
    return "on" if @data().unit.tracking
    return "off"

  tabs: ->
    tabs = []
    if @data().unit.tracking
      tabs.push "Events"
      @barSelected.set info: @data().unit.amount, span: 'Active'

    tabs.push "Expenses"
    tabs

  mainInfo: ->
    @barSelected.get()

  mEvents: ->
    events = []
    for i in [0..3]
      events.push {
        amount: Math.floor(Math.random() * 101) - 50;
      }
    events


  onBarClick: (event) ->
    title = $(event.currentTarget).attr('data-title')
    if title is 'Events'
      @barSelected.set info: @data().unit.amount, span: 'Active'
    else
      @barSelected.set info: '$12.98', span: 'Last 5 Days'



  events: ->
    super.concat
      'click .js-card-bar': @onBarClick
