require './card.jade'

class UnitCard extends BlazeComponent
  @register 'UnitCard'

  constructor: (args) ->
    super

  onCreated: ->
    super
    @barSelected = new ReactiveVar('Expenses')


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
      @barSelected.set 'Events'

    tabs.push "Expenses"
    tabs

  getInfo: (label) ->
    if label is 'Events'
      ret =
        info: @data().unit.amount
        label: 'Active'
    else
      ret =
        info: "$21.23"
        label: 'Last 5 Days'

  mEvents: ->
    events = []
    for i in [0..3]
      events.push {
        amount: Math.floor(Math.random() * 101) - 50;
      }
    events

  onBarClick: (event) ->
    index = $(event.currentTarget).attr('data-index')
    $(@find '.total-info .wrapper').velocity
      p:
        translateX: "#{-100*index}%"
      o:
        duration: 250
        easing: 'ease-in-out'



  events: ->
    super.concat
      'click .js-card-bar': @onBarClick
