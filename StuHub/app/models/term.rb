class Term < ActiveRecord::Base
  belongs_to :institution
  has_many :departments, dependent: :destroy
  has_many :courses, through: :departments

  validates :name, length: {minimum: 1}
  validates :year, numericality: {integer_only: true, minimum: 1900, maximum: 2100}
  validates :term_reference, length: {minimum: 1}
  validates :institution_id, :enrollment_start_date, :start_date, :end_date, :exams_end_date, presence: true
  validates :data_url, length: {minimum: 11}, if: "data_mode == 1"

  def term_name
    return "#{name} #{year}"
  end

  def term_name_long
    return "#{name} #{year} (#{term_reference})"
  end

  def update_from_database
    if data_mode == 1
      uri = URI.parse(database_url)
      Net::HTTP.start(uri.host, uri.port) do |http|
        data = http.get(uri.path)
        temp = Tempfile.open("db-#{institution.id}-#{term_reference}.xlsx")
        begin
          temp.binmode
          temp.write(data.body)
          temp.flush

          workbook = Dullard::Workbook.new temp
          workbook.sheets[0].rows.each_with_index do |row, index|
            if index > 5
              department = departments.find_by(name: row[2])
              if department.nil?
                department = Department.new(name: row[2])
                departments << department
              end

              course = department.courses.find_by(number: row[3])
              if course.nil?
                course = Course.new(number: row[3], name: row[6])
                department.courses << course
                numberAdded += 1
              end

              department.save
            end
          end

          touch :data_last_updated
          self.update_attribute(:updating, false)
        ensure
          temp.close
          temp.unlink
        end
      end
    end
  end
end
