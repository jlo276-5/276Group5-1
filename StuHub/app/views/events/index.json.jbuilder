json.array!(@events) do |event|
  json.extract! event, :id, :title, :description
  json.start event.start_time
  json.end event.end_time
  json.url event_url(event, format: :html)
end

json.array!(@schedule) do |schedule_item|
  json.id "st_#{schedule_item.id}"
  start_time = schedule_item.start_time.in_time_zone
  end_time = schedule_item.end_time.in_time_zone
  json.start start_time.strftime("%H:%M")
  json.end end_time.strftime("%H:%M")
  json.title "#{schedule_item.section.code} - #{schedule_item.section.course.course_number} - #{schedule_item.building}#{schedule_item.room}"
  json.ranges [{start: schedule_item.start_date.strftime("%Y/%m/%d"), end: schedule_item.end_date.strftime("%Y/%m/%d")}]
  json.dow schedule_item.day_array
  json.editable false
end

json.array!(@exams) do |exam|
  json.id "e_#{exam.id}"
  json.start exam.exam_start
  json.end exam.exam_end
  json.title "EXAM #{exam.section.course.course_number} - #{exam.section.key}#{exam.room.blank? ? "" : " - #{exam.building}#{exam.room}"}"
  json.editable false
end
