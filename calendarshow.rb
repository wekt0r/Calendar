require 'date'
require_relative 'calendarnotes.rb'

class ShowNoteline
	def initialize
	end
	def to_s(nl)
		nl.events.map {|event| event.to_s}.join(" - ")
	end
	
	def list_all(nl)
		nl.events.map {|event| event.to_s }
	end 

	def firstn_to_s(n,nl)
		if nl.events.length > n
		then nl.events.take(n).map {|event| event.to_s if event.to_s != nil }.join(" - ") + " - ..."
		else self.to_s(nl)
		end
	end
	
	def first10_to_s(nl)
		self.firstn_to_s(10,nl)
	end
end

class ShowTimeline
	def initialize
	end
	def hour_to_s(hour)
		minutes = (100*(hour - Integer(hour))).round
		hours = Integer(hour)
		if minutes >= 10
		"#{hours.to_s}:#{minutes.to_s}"
		else
		"#{hours.to_s}:0#{minutes.to_s}"
		end
	end
	def dateTime_to_s(datetime)
		datetime.to_s[0..9]
	end

	def list_all(tl)
		list = []
		tl.timeline.values.each do |hour_hash|
			if hour_hash.respond_to?:values
				hour_hash.values.each  do |event_array|
					if event_array.respond_to?:map
						list += event_array.map {|event| "#{self.dateTime_to_s(event.date)}: #{self.hour_to_s(event.hour)}:#{event.to_s}"}
					end
				end
			end
		end
		list
	end

	def day_to_s(day, indent_hour = "", indent_event = "")
		output = "\n"
		if day.respond_to?:keys
			day.keys.sort.each do |hour|
				if day[hour].respond_to?:map
					output += "#{indent_hour}#{self.hour_to_s(hour)}\n"
					output += day[hour].map {|event| "#{indent_event}#{event.to_s}\n"}.join
				end
			end
		end
		output
	end

	def timeline_to_s(tl, indent_date = "")
		tl.timeline.keys.sort.map {|date| "#{indent_date}#{self.dateTime_to_s(date)}#{self.day_to_s(tl.timeline[date], "\t", "\t\t")}" if tl.timeline[date].respond_to?:keys }.join
	end

	def upcoming_ndays_to_s(n, tl)
		(Date.today..(Date.today+n)).map {|date| "#{date.to_s}#{self.day_to_s(tl.timeline[date], "\t", "\t\t")}"}.join
	end
	def upcoming_month_to_s(tl)
		self.upcoming_ndays_to_s(30,tl)		
	end
	def upcoming_week_to_s(tl)
		self.upcoming_ndays_to_s(6,tl)		
	end
	def today_to_s(tl)
		date = Date.today
		"#{date.to_s}#{self.day_to_s(tl.timeline[date], "\t", "\t\t")}" if tl.timeline[date] != nil 
	end

end
