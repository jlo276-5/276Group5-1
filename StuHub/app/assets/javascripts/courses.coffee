# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# http://stackoverflow.com/questions/19909394/rails-dynamic-select-collection-select

$(document).on 'change', '.year_select', -> # load a year
  # window.location = '#' # Append Hash to save request.
  $('.term_select').val('0') # deselect any term
  $('.department_select').val('0') # deselect any department
  $('.department_select').prop('disabled', true) # disable departments
  $('#course_list').empty() # clear course list
  if $('.year_select option:selected').val() != ""
    $('.year_select').prop('disabled', true) # disable year select while loading
    $.ajax
      url: '/courses/get_terms'
      type: 'GET',
      dataType: 'script'
      data:
        year_id: $('.year_select option:selected').val()
  else
    $('.term_select').prop('disabled', true) # disable terms


$(document).on 'change', '.term_select', -> # load a term
  # window.location = '#' # Append Hash to save request.
  $('.department_select').val('0') # deselect any department
  $('#course_list').empty() # clear course list
  if $('.term_select option:selected').val() != "" and $('.term_select option:selected').val() != "0"
    $('.year_select').prop('disabled', true) # disable year select while loading
    $('.term_select').prop('disabled', true) # disable term select while loading
    $.ajax
      url: '/courses/get_departments'
      type: 'GET',
      dataType: 'script'
      data:
        year_id: $('.year_select option:selected').val()
        term_id: $('.term_select option:selected').val()
  else
    $('.department_select').prop('disabled', true) # disable deparments

$(document).on 'change', '.department_select', -> # load a department
  # window.location = '#' # Append Hash to save request.
  $('#course_list').empty() # clear course list
  if $('.department_select option:selected').val() != "" and $('.department_select option:selected').val() != "0"
    $('.year_select').prop('disabled', true) # disable year select while loading
    $('.term_select').prop('disabled', true) # disable term select while loading
    $('.department_select').prop('disabled', true) # disable department select while loading
    $.ajax
      url: '/courses/get_courses'
      type: 'GET',
      dataType: 'script'
      data:
        year_id: $('.year_select option:selected').val()
        term_id: $('.term_select option:selected').val()
        department_id: $('.department_select option:selected').val()
