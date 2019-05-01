class Event < ActiveRecord::Base
    attr_accessible :title, :starttime, :endtime, :description, :allday

    has_many :event_responses
   has_many :users, :through => :event_responses


    def overlaps?(other)
        self.starttime <= other.endtime && other.starttime <= self.endtime
    end

    def self.import(file)
        spreadsheet = open_spreadsheet(file)
        header = spreadsheet.row(1)
        valid_keys = ["title", "description", "allday"]

        # debugger
        @errors = []

        (2..spreadsheet.last_row).each do |i|
            row = Hash[[header, spreadsheet.row(i)].transpose]

            row.each {|key, value| (row[key] = value.strip()) if value.kind_of? String }

            # debugger

            start_datetime = row["starttime"].to_datetime
            end_datetime = row["endtime"].to_datetime

            if (start_datetime > end_datetime)
                @errors << "#{row['title']} has start time greater than end time"
                next
            end

            event = Event.find_by_id(row["id"]) || Event.new
            event.attributes = row.to_hash.slice(*valid_keys)

            event.starttime = start_datetime

            event.endtime = end_datetime
            if event.endtime <= Time.zone.now
                event.completed = true
            else
                event.completed = false
            end
            event.save!

            if row["users#rsvp"].present?
                user_responses = row["users#rsvp"].split(";")
                user_responses.each do |user_response|
                    ur_arr = user_response.split("#")
                    username = ur_arr[0]
                    rsvp = ur_arr[1]

                    user = User.where(:username => username).first
                    ev = EventResponse.new
                    ev.user_id = user.id
                    ev.event_id = event.id
                    ev.rsvp = rsvp

                    if ev.rsvp == 'yes' && user.events.present?
                        user.events.each do |user_event|
                            if event.overlaps?(user_event)
                                user.events.update_all(:rsvp => "no")
                                ev.rsvp = 'yes'
                                break
                            end
                        end
                    end
                    ev.save
                end
            end

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
