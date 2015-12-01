# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

## Main Calendar
$(document).on 'ready page:load', ->
  # $('#calendar').fullCalendar({
  #   header: {
  #       left: 'prev,next today',
  #       center: 'title',
  #       right: 'month,agendaWeek,agendaDay'
  #   },
  #   events: '/events.json'
  #   editable: false
  #   selectable: false
  #   selectHelper: false
  #   eventColor:'#B22222'
  #   slotEventOverlap: false
  #   weekNumbers:true
  #   businessHours:true
  #   eventRender: (event) ->
  #     renderEvent(event);
  #   # eventDrop: (event, dayDelta, minuteDelta, allDay, revertFunc) ->
  #   #   updateEvent(event);
  #   # eventResize: (event, dayDelta, minuteDelta, revertFunc) ->
  #   #   updateEvent(event);
  # })

  $('#user_calendar').fullCalendar({
    header: {
        left: 'prev,next today',
        center: 'title',
        right: 'month,agendaWeek,agendaDay'
    },
    height: 650
    events: '/events/user_events.json?user_id=' + $('#user_calendar').data('user-id')
    editable: false
    selectable: false
    selectHelper: false
    eventColor:'#B22222'
    slotEventOverlap: false
    weekNumbers:true
    businessHours:true
    eventRender: (event) ->
      renderEvent(event);
  })

  $('#home_calendar').fullCalendar({
    header: {
        left: '',
        center: '',
        right: ''
    },
    height: 650
    events: '/events.json'
    editable: false
    selectable: false
    selectHelper: false
    fixedWeekCount:false
    eventColor:'#B22222'
    slotEventOverlap: false
    businessHours:true
    eventRender: (event, element)->
      element.qtip({
          content:  event.title
      })
      renderEvent(event);
    # eventDrop: (event, dayDelta, minuteDelta, allDay, revertFunc) ->
    #   updateEvent(event);
    # eventResize: (event, dayDelta, minuteDelta, revertFunc) ->
    #   updateEvent(event);
  })

## http://stackoverflow.com/questions/15161654/recurring-events-in-fullcalendar via http://js2.coffee
renderEvent = (event) ->
  if event.ranges?
    event.ranges.filter((range) ->
      # test event against all the ranges
      event.start.isBefore(range.end) and event.end.isAfter(range.start)
    ).length > 0
    #if it isn't in one of the ranges, don't render it (by returning false)
  else
    true

# updateEvent = (event) ->
#   $.ajax
#     url: "/events/" + event.id,
#     type: "PUT",
#     dataType: "json",
#     data:
#       event:
#         title: event.title,
#         start_time: "" + new Date(event.start).toUTCString(),
#         end_time: "" + new Date(event.end).toUTCString(),
#         description: event.description
