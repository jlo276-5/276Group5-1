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
  })
  
  #######################################################
  ## HomePage Calendar
  $(document).on 'ready page:load', ->
  $('#calendar2').fullCalendar({
    header: {
        left: '',
        center: '',
        right: ''
    },
    height: 350
## Actions
    ##theme:tru
    ##eventClick: (event) ->
    ##  alert event.title
    ##  alert event.title
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
  eventRender: (event, element)-> 
        t = event.start
        element.qtip({
            content: "Title: " + event.title + ' Description: ' + event.description
            
        })
    
  })

