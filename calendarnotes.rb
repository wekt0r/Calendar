require 'date'

class BlankNote
	
	attr_reader :content

	def initialize(c)
		@content = c
	end
	def to_s
		@content
	end
end

class DateNote < BlankNote
	
	attr_reader :date
	attr_reader :hour

	def initialize(c, d, h)
		super(c)
		@date = d
		@hour = h
	end
end

class CyclicNote < DateNote
	
	attr_reader :repeat
	
	def initialize(c, d, h, r)
		super(c,d,h)
		@repeat = r
	end
	def to_s
		string = @content + " every " + @repeat.to_s + " day(s)"
	end
	def switch
		@date += @repeat if Date.today > self.date 
	end 
end

class Noteline
	
	attr_reader :events

	def initialize(*events)
		@events = events
	end
	def add_event(event)
		@events << event
	end
	def delete_event(event_to_del)
		i = 0
		@events.each do |event|
			break if event.to_s ==  event_to_del
			i += 1
		end
		@events.delete_at(i)
	end
end

class Timeline
	
	attr_reader :timeline

	def initialize(*events)
		@timeline = Hash.new
		events.each do |event|
			self.add_event(event)
		end
	end
	def add_event(event)
		@timeline[event.date] ||= Hash.new
		@timeline[event.date][event.hour] ||= []
		@timeline[event.date][event.hour] << event
	end

	def delete_event(date, hour, event_to_del)
		i = 0
		@timeline[date][hour].each do |event|
			break if event.to_s == event_to_del
			i += 1
		end
		@timeline[date][hour].delete_at(i)
		if @timeline[date][hour] == []
			@timeline[date][hour] = nil
			@timeline[date] = nil if @timeline[date] == {}
		end
	end
end

class CollectOld
	def initialize
	end
	def collect_old(tl)
		tl.timeline.each {|date, _| tl.timeline.delete(date) if date < Date.today }
	end
end
 
class SwitchCyclic
	def initialize
	end
	def switch_cyclic_from_date(date,tl)
		tl.timeline[date].each do |_, events| 
			events.each do |event|
				if event.kind_of? CyclicNote
					event.switch
					tl.add_event(event)
				end 
			end	
		end
	end
	def switch_old_cyclic(tl)
		tl.timeline.each {|date, _| self.switch_cyclic_from_date(date, tl) if date < Date.today }
	end

end