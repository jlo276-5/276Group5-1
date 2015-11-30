# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

##$(document).ready ->
## Main Calendar

$(document).on 'ready page:load', ->
  $('#calendar').fullCalendar({
    header: {
        left: 'prev,next today',
        center: 'title',
        right: 'month,agendaWeek,agendaDay'
    },
    events: '/events.json'
    editable: true
    selectable: true
    selectHelper: true
## Style
    eventColor:'#B22222'
    slotEventOverlap: false
    weekNumbers:true
    businessHours:true
    ## http://stackoverflow.com/questions/15161654/recurring-events-in-fullcalendar via http://js2.coffee
    eventRender: (event) ->
      if event.ranges?
        event.ranges.filter((range) ->
          # test event against all the ranges
          event.start.isBefore(range.end) and event.end.isAfter(range.start)
        ).length > 0
        #if it isn't in one of the ranges, don't render it (by returning false)
      else
        true
  })

  #######################################################
  ## HomePage Calendar
  $(document).on 'ready page:load', ->
  $('#calendar2').fullCalendar({
    header: {
        left: '',
        center: 'title',
        right: ''
    },
    height: 600
## Attributes
    events: '/events.json'
    editable: true
    selectable: true
    selectHelper: true
    fixedWeekCount:false
## Style
    eventColor:'#B22222'
    slotEventOverlap: false
## Hover Show Details
    ## http://stackoverflow.com/questions/15161654/recurring-events-in-fullcalendar via http://js2.coffee
    eventRender: (event, element)->
      element.qtip({
          content:  event.title
      })
      if event.ranges?
        event.ranges.filter((range) ->
          # test event against all the ranges
          event.start.isBefore(range.end) and event.end.isAfter(range.start)
        ).length > 0
        #if it isn't in one of the ranges, don't render it (by returning false)
      else
        true
  })
