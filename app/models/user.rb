class User < ActiveRecord::Base
  attr_accessible :username, :email, :phone

  has_many :event_responses
 has_many :events, :through => :event_responses

  def self.import(file)
      spreadsheet = open_spreadsheet(file)
      header = spreadsheet.row(1)
      valid_keys = ["username", "email","phone"]

      (2..spreadsheet.last_row).each do |i|
          row = Hash[[header, spreadsheet.row(i)].transpose]

          row.each {|key, value| (row[key] = value.strip()) if value.kind_of? String }

          user = User.find_by_id(row["id"]) || User.new
          user.attributes = row.to_hash.slice(*valid_keys)
          user.save!
      end
  end

  def self.open_spreadsheet(file)
      case File.extname(file.original_filename)
          when ".csv" then Roo::Csv.new(file.path, nil, :ignore)
          when ".xls" then Roo::Excel.new(file.path, nil, :ignore)
          when ".xlsx" then Roo::Excelx.new(file.path, nil, :ignore)
      else raise "Unknown file type: #{file.original_filename}"
      end
  end

end
