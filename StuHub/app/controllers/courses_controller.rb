class CoursesController < ApplicationController
  require 'rest-client'
  require 'date'

  SFU_CO_API = "http://www.sfu.ca/bin/wcm/course-outlines"

  def index
    if Year.count == 0 or (Time.now-(Year.order('updated_at').last.updated_at)) > 1.month
      request_years = JSON.parse(RestClient.get SFU_CO_API)
      request_years.each do |y|
        year_obj = Year.find_by(number: y["text"])
        if !year_obj
          year_obj = Year.new
          year_obj.number = y["text"]
          year_obj.save
        else
          year_obj.touch
        end
      end
    end

    @years = Year.order('number ASC').all
    @terms = []
    @departments = []
  end

  def get_terms
    year = Year.find(params[:year_id])
    terms = Term.where(year_id: year.id)

    if terms.count == 0 or (Time.now-(terms.order('updated_at').last.updated_at)) > 1.month
      request_terms = JSON.parse(RestClient.get "#{SFU_CO_API}?#{year.number}")
      request_terms.each do |t|
        # term_obj = Term.find_by(name: t["text"], year_id: year.id)
        term_obj = year.terms.find_by(name: t["text"])
        if !term_obj
          term_obj = Term.new
          term_obj.name = t["text"]
          year.terms << term_obj
        else
          term_obj.touch
        end
      end
      year.save
    end

    @terms = Term.where(year_id: year.id)
    @departments = []
  end

  def get_departments
    year = Year.find(params[:year_id])
    term = Term.find(params[:term_id])
    departments = Department.where(term_id: term.id)

    if departments.count == 0 or (Time.now-(departments.order('updated_at').last.updated_at)) > 1.month
      request_departments = JSON.parse(RestClient.get "#{SFU_CO_API}?#{year.number}/#{term.name}")
      request_departments.each do |d|
        # department_obj = Department.find_by(name: d["text"], term_id: term.id)
        department_obj = term.departments.find_by(name: d["text"])
        if !department_obj
          department_obj = Department.new
          department_obj.name = d["text"]
          term.departments << department_obj
        else
          department_obj.touch
        end
      end
      term.save
    end

    @departments = Department.where(term_id: term.id)
  end

  def get_courses
    year = Year.find(params[:year_id])
    term = Term.find(params[:term_id])
    department = Department.find(params[:department_id])
    courses = Course.where(department_id: department.id)

    if courses.count == 0 or (Time.now-(courses.order('updated_at').last.updated_at)) > 2.weeks
      begin
        request_courses = JSON.parse(RestClient.get "#{SFU_CO_API}?#{year.number}/#{term.name}/#{department.name}")
      rescue => e
        puts e.response
        @courses = []
        return
      end
      request_courses.each do |c|
        # course_obj = Course.find_by(number: c["text"], department_id: department.id)
        course_obj = department.courses.find_by(number: c["text"])
        if !course_obj
          course_obj = Course.new
          course_obj.number = c["text"]
          department.courses << course_obj
        else
          course_obj.touch
        end # !course_obj

        sections_fetch_error_count = 0

        begin
          request_sections = JSON.parse(RestClient.get "#{SFU_CO_API}?#{year.number}/#{term.name}/#{department.name}/#{course_obj.number}")
        rescue => e
          puts e.response # Redo.
          if sections_fetch_error_count < 2
            sections_fetch_error_count += 1
            redo
          else
            next
          end
        end
        request_sections.each do |s|
          # associated_class_obj = AssociatedClass.find_by(number: s["associatedClass"], course_id: course_obj.id)
          associated_class_obj = course_obj.associated_classes.find_by(number: s["associatedClass"])
          if !associated_class_obj
            associated_class_obj = AssociatedClass.new
            associated_class_obj.number = s["associatedClass"]
            course_obj.associated_classes << associated_class_obj
          end # !associated_class_obj

          # section_obj = Section.find_by(key: s["text"], associated_class_id: associated_class_obj.id)
          section_obj = associated_class_obj.sections.find_by(key: s["text"])
          if !section_obj
            section_obj = Section.new
            section_obj.key = s["text"]
            section_obj.code = s["sectionCode"]
            associated_class_obj.sections << section_obj
          end # !section_obj

          section_fetch_error_count = 0

          begin
            request_section = JSON.parse(RestClient.get ("#{SFU_CO_API}?#{year.number}/#{term.name}/#{department.name}/#{course_obj.number}/#{section_obj.key}".downcase))
          rescue => e
            puts e.response
            if section_fetch_error_count < 2
              section_fetch_error_count += 1
              redo
            else
              next
            end
          end
          section_obj.unique_number = request_section["info"]["classNumber"]
          if course_obj.name.blank?
            course_obj.name = request_section["info"]["title"]
            course_obj.save
          end # course_obj.name.blank?

          if request_section["courseSchedule"]
            request_section["courseSchedule"].each_with_index do |sched, index|
              next if (sched["startDate"].blank? or sched["startTime"].blank? or sched["days"].blank?)

              sectiontime_obj = section_obj.section_times[index]
              if !sectiontime_obj
                sectiontime_obj = SectionTime.new
                section_obj.section_times << sectiontime_obj
              else
                sectiontime_obj.touch
              end # !sectiontime_obj

              sectiontime_obj.start_date = Date.parse(sched["startDate"])
              sectiontime_obj.start_time = Time.parse(sched["startTime"])
              sectiontime_obj.end_date = Date.parse(sched["endDate"])
              sectiontime_obj.end_time = Time.parse(sched["endTime"])
              sectiontime_obj.days = sched["days"]
              sectiontime_obj.building = sched["buildingCode"]
              sectiontime_obj.room = sched["roomNumber"]
              sectiontime_obj.campus = sched["campus"]
              sectiontime_obj.save
            end # request_section["courseSchedule"].each_with_index

            while section_obj.section_times.length > request_section["courseSchedule"].length do
              section_obj.section_times.last.destroy
            end
          end # request_section["courseSchedule"]

          if request_section["examSchedule"]
            request_section["examSchedule"].each_with_index do |exam, index|
              next if (exam["startDate"].blank? or exam["startTime"].blank?)

              exam_obj = section_obj.exams[index]
              if !exam_obj
                exam_obj = Exam.new
                section_obj.exams << exam_obj
              else
                exam_obj.touch
              end # !exam_obj

              time_start = Time.parse(exam["startTime"])
              time_end = Time.parse(exam["endTime"])

              exam_obj.exam_start = DateTime.parse(exam["startDate"]).change({hour: time_start.hour, min: time_start.min})
              exam_obj.exam_end = DateTime.parse(exam["endDate"]).change({hour: time_end.hour, min: time_end.min})
              exam_obj.building = exam["buildingCode"]
              exam_obj.room = exam["roomNumber"]
              exam_obj.campus = exam["campus"]
              exam_obj.save
            end # request_section["examSchedule"].each_with_index

            while section_obj.exams.length > request_section["examSchedule"].length do
              section_obj.exams.last.destroy
            end
          end # request_section["examSchedule"]

          if request_section["instructor"]
            request_section["instructor"].each_with_index do |instr, index|
              next if (instr["firstName"].blank? or instr["lastName"].blank?)

              instructor_obj = section_obj.instructors[index]
              if !instructor_obj
                instructor_obj = Instructor.new
                section_obj.instructors << instructor_obj
              else
                instructor_obj.touch
              end # !instructor_obj

              instructor_obj.first_name = instr["firstName"]
              instructor_obj.last_name = instr["lastName"]
              instructor_obj.email = instr["email"]
              instructor_obj.office = instr["office"]
              instructor_obj.office_hours = instr["officeHours"]
              instructor_obj.phone = instr["phone"]
              instructor_obj.website = instr["profileUrl"]
              instructor_obj.save
            end # request_section["instructors"].each_with_index

            while section_obj.instructors.length > request_section["instructor"].length do
              section_obj.instructors.last.destroy
            end
          end # request_section["instructors"]

          section_obj.save
          associated_class_obj.save
        end # request_sections.each
        course_obj.save
      end # request_courses.each do
      department.save
    end # courses.count == 0 or (Time.now-(courses.order('updated_at').last.updated_at)) > 1.day

    @courses = Course.where(department_id: department.id).order('number ASC')
  end

  def show
    @course = Course.find(params[:id])
  end
end
