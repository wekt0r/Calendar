# First-use instructions - how to open from this file 
# 1. Download shoes gui from shoesrb.com
# 2. Open calendar.rb by shoes launcher

require 'date'
require 'yaml'
require_relative 'calendarnotes.rb'
require_relative 'calendarshow.rb'

class Config

  attr_accessor :note_view
  attr_accessor :default_view_mode
  attr_accessor :color 
  attr_accessor :font_color  

  def initialize(dvm, nv, list_of_color_and_font)
    @default_view_mode = dvm
    @note_view = nv
    @color = list_of_color_and_font[0]
    @font_color = list_of_color_and_font[1]
  end

end  

class Program
  def initialize
    stl = ShowTimeline.new
    snl = ShowNoteline.new
    co = CollectOld.new
    sc = SwitchCyclic.new
    
    #Creating needed files if they don't exist

    if not File.exists? ('calendar_example.ca')
      File.open('calendar_example.ca', 'w') {|f| f.write(YAML.dump(Timeline.new()))}
    end

    if not File.exists? ('config.ca')
      File.open('config.ca', 'w') {|f| f.write(YAML.dump(Config.new("upcoming_week_to_s","first10_to_s",["#666", "#FFF"])))}
    end

    if not File.exists? ('notes_example.ca')
      File.open('notes_example.ca', 'w') {|f| f.write(YAML.dump(Noteline.new()))}
    end

    #-------------------------------------------------------------
    #Whole app below

    Shoes.app(title: "My calendar", width: 600, height: 900, resizable: false) do
      @con = YAML.load_file('config.ca')
      background (@con.color).."#FFF"                          

      #date
      caption("Hello, today is " + Date.today.to_s,
            top:    0.2,
            align:  "center",
            font:   "Avenir",
            stroke: @con.font_color)
      #-------------------------------------------------------------
      #BUTTONS
      #-------------------------------------------------------------
      #adding new event

      flow width: 0.25, height: 0.1 do
      	button 'New event', width: 1.0, height: 1.0 do
              Shoes.app(title: "New note", width: 400, height: 300, resizable: false) do
                @con = YAML.load_file('config.ca')
                background (@con.color)
                  caption("Create new note",
                  top:    30,
                  align:  "center",
                  font:   "Avenir",
                  stroke: @con.font_color)

                  @content = edit_box :width => 400, :height => 100, :top => 60

                  

                  flow width: 100, top: 180 do
                    @date = list_box :items => ["Date"] + (Date.today .. (Date.today + 60)).map {|d| d.to_s}
                  end
                  flow width: 70, top: 180 do
                    @timehour = list_box :items => ["Hour"]+(0..23).map {|t| t.to_s}
                  end
                  flow width: 70, top: 180 do
                    @timemin = list_box :items => ["Minute"]+(0..59).map {|t| t.to_s}
                  end
                  flow width: 50, top: 180 do
                    @interval = list_box :items => ["Interval (cyclic only)", "Every day", "Every week", "Every month"]
                  end
                  para("\n")
                  flow width: 200, top: 210 do
                    @type = list_box :items => ["To-do note", "Note with date", "Cyclic note"]
                  end
                  flow width: 100, top: 210 do
                    button 'Save', width: 100, height: 50 do
                      if @type.text == "To-do note"
                        @notetemp = YAML.load_file('notes_example.ca')
                        @notetemp.add_event(BlankNote.new(@content.text))
                        File.open('notes_example.ca', 'w') {|f| f.write(YAML.dump(@notetemp))}
                        alert ("Your note has been saved!")
                      elsif @date.text != "Date" and @timehour.text != "Hour" and @timemin.text != "Minute"
                          if @type.text == "Note with date"
                            @time_fixed = Integer(@timehour.text) + Integer(@timemin.text)/100.0
                            @caltemp = YAML.load_file('calendar_example.ca')
                            @caltemp.add_event(DateNote.new(@content.text, DateTime.parse(@date.text), @time_fixed))
                            File.open('calendar_example.ca', 'w') {|f| f.write(YAML.dump(@caltemp))}
                            alert ("Your note has been saved!")
                          end
                          if @type.text == "Cyclic note"
                            if @interval.text != "Interval (cyclic only)"
                              @time_fixed = Integer(@timehour.text) + Integer(@timemin.text)/100.0
                              @repeat_map = {"Every day" => 1, "Every week" => 7, "Every month" => 31}
                              @caltemp = YAML.load_file('calendar_example.ca')
                              @caltemp.add_event(CyclicNote.new(@content.text, DateTime.parse(@date.text), @time_fixed, @repeat_map[@interval.text]))
                              File.open('calendar_example.ca', 'w') {|f| f.write(YAML.dump(@caltemp))}
                              alert ("Your note has been saved!")
                            else
                              alert("Choose interval!") 
                            end
                          end
                        else alert("You didn't choose date and/or hour!")
                      end
                    end
                  end
                  flow width: 100, top: 210 do
                    button 'Close', width: 100, height: 50 do
                      self.close()
                    end
                  end
              end
        end
      end
      #-------------------------------------------------------------
      #deleting note

      flow width: 0.25, height: 0.1 do
        button 'Delete note', width: 1.0, height: 1.0 do
          Shoes.app(title: "Delete note", width: 400, height: 300, resizable: false) do
            @con = YAML.load_file('config.ca')
            background (@con.color)
            @notetemp = YAML.load_file('notes_example.ca')
            @caltemp = YAML.load_file('calendar_example.ca')
            
            caption("Delete note",
            top:    30,
            align:  "center",
            font:   "Avenir",
            stroke: @con.font_color)

            flow width: 200, top: 70 do
              @type = list_box :items => ["To-do note", "Note with date", "Cyclic note"]
            end
            @to_delete = flow width: 200, top: 70 do 
              @all_notes = list_box :items => snl.list_all(@notetemp) 
            end

            @type.change do
              if @type.text == "To-do note"
              then 
                @to_delete.clear do 
                  flow width: 200 do 
                    @all_notes = list_box :items => snl.list_all(@notetemp)
                  end  
                end
              else
                @to_delete.clear do
                  flow width: 200 do 
                    @all_notes = list_box :items => stl.list_all(@caltemp)
                   end
                end

              end
            end
            para ("")
            flow width: 200, top: 100 do
              button 'Delete', width: 200, height: 50 do
                if @type.text == "To-do note"
                then
                  @notetemp.delete_event(@all_notes.text)
                  File.open('notes_example.ca', 'w') {|f| f.write(YAML.dump(@notetemp))}
                  alert ("Your note has been deleted!")
                else
                    @date = @all_notes.text[0..9]
                    @text_splitted = @all_notes.text.split(":")
                    @hour = Integer(@text_splitted[1])
                    @minute = Integer(@text_splitted[2])
                    @time_fixed = @hour + @minute/100.0
                    @caltemp.delete_event(DateTime.parse(@date), @time_fixed, @text_splitted[3..@text_splitted.length].join) #this fancy instruction is for situation when ":" is inside of note
                    File.open('calendar_example.ca', 'w') {|f| f.write(YAML.dump(@caltemp))}
                    alert ("Your note has been deleted!")
                end
              end
            end
            
            flow width: 200, top: 100 do
              button 'Close', width: 200, height: 50 do
                self.close()
              end
            end
          end
        end
      end

      #-------------------------------------------------------------
      #upcoming events

      flow width: 0.25, height: 0.1 do
        button 'All upcoming events', width: 1.0, height: 1.0 do
          alert (stl.timeline_to_s(@cal))
        end
      end

      #-------------------------------------------------------------
      #settings

      flow width: 0.25, height: 0.1 do
        button 'Settings', width: 1.0, height: 1.0 do
          Shoes.app(title: "Settings", width: 400, height: 200, resizable: false) do
            @con = YAML.load_file('config.ca')
            background (@con.color)
            
            flow width: 200, height: 50 do
              para ("Style:")
            end
            flow width: 200, height: 50 do
              @style_to_change = list_box :items => ["Default", "Red and white", "Light blue"]
            end
            flow width: 200, height: 50 do
              para ("View:")
            end
            flow width: 200, height: 50 do
              @default_view_mode = list_box :items => ["Day", "Week", "Month"]
            end
            flow width: 200, height: 50 do
              para ("Notes:")
            end
            flow width: 200, height: 50 do
              @note_view = list_box :items => ["10", "All"]
            end

            flow width: 200, height: 50 do
              button 'Save', width: 1.0, height: 1.0 do
                @style_map = {"Default" => ["#666", "#FFF"], "Red and white" => ["#A00", "#000"], "Light blue" => ["#05A", "#FFF"] }
                @dvm_map = {"Week" => "upcoming_week_to_s", "Day" => "today_to_s", "Month" => "upcoming_month_to_s"}
                @nv_map = {"10" => "first10_to_s", "All" => "to_s"}
                @contemp = Config.new(@dvm_map[@default_view_mode.text], @nv_map[@note_view.text], @style_map[@style_to_change.text])
                File.open('config.ca', 'w') {|f| f.write(YAML.dump(@contemp))}
                alert ("Changes have been saved - restart program to see them")
              end
            end
            flow width: 200, height: 50 do
              button 'Discard', width: 1.0, height: 1.0 do
                self.close()
              end
            end

          end
        end
      end
      #-------------------------------------------------------------
      #whole calendar
      @con = YAML.load_file('config.ca')
      @note = YAML.load_file('notes_example.ca')
      @cal = YAML.load_file('calendar_example.ca')
      caption("To-do list\n", align:  "center", font:   "Avenir", stroke: @con.font_color)
      @todo = para(snl.send(@con.note_view, @note), align: "left", font: "Avenir", stroke: @con.font_color)
      caption("\nUpcoming events\n", align:  "center", font:   "Avenir", stroke: @con.font_color)
      @events = para(stl.send(@con.default_view_mode, @cal), align: "left", font: "Avenir", stroke: @con.font_color)

      #-------------------------------------------------------------
      #timer

      # it turned out that using "thread.new do every(5) do ... end" or 
      # "thread.new do while(true) do ... end" makes program visibly slower 
      every(5) do
        #@con = YAML.load_file('config.ca')
        @note = YAML.load_file('notes_example.ca')
        @cal = YAML.load_file('calendar_example.ca')
        sc.switch_old_cyclic(@cal)
        co.collect_old(@cal)
        if @todo.text != snl.send(@con.note_view, @note)
          @todo.replace snl.send(@con.note_view, @note)
        end
        if @events.text != stl.send(@con.default_view_mode, @cal)
          @events.replace stl.send(@con.default_view_mode, @cal)
        end
        File.open('calendar_example.ca', 'w') {|f| f.write(YAML.dump(@cal))}  #saving file is to collect_old notes and switch_old_cyclic

        if @cal.timeline[Date.today] != nil
          if @cal.timeline[Date.today][Time.now.hour + Time.now.min/100.0] != nil
            alert (@cal.timeline[Date.today][Time.now.hour + Time.now.min/100.0].map {|event| event.to_s}.join(" and ") + " -- do it right now!")
          end
        end
      end 

    end
  end
end

x = Program.new
