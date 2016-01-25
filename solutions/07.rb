class LazyMode

  def initialize
    @new_file
  end

  class Date

    def initialize(string)
      @date = string.split('-')
    end

    def year
      @date[0].to_i
    end

    def month
      @date[1].to_i
    end

    def day
      @date[2].to_i
    end

    def to_s
      ("0" * (4 - year.to_s.length)) << "#{year}-" <<
      ("0" * (2 - month.to_s.length)) << "#{month}-" <<
      ("0" * (2 - day.to_s.length)) << "#{day}"
    end

    def add_day
      if day == 30
        @date[2] = 1.to_s
        add_month
      else
        @date[2] = (day + 1).to_s
      end
    end

    def add_month
      if month == 12
        @date[1] = 1.to_s
        add_year
      else
        @date[1] = (month + 1).to_s
      end
    end

    def add_year
      @date[0] = (year + 1).to_s
    end

  end

  def self.create_file(name, &block)
    @new_file = File.new(name, &block)
    @new_file
  end

  module More

    def body(string = nil)
      string != nil ? @content = string : @content
    end

    def status(status = nil)
      status != nil ? @status = status : @status
    end

    def scheduled(date = nil)
      if date != nil && date.size > 10
        @date = Date.new(date[0...date.index('+') - 1])
      elsif date != nil
        @date = date
      else
        @date
      end
    end

    def date
      scheduled
    end

  end

  class Note

    include More

    def initialize(*args)
      @args = args
      @content = ""
      @status = :topostpone
      @date
      @in_notes = []
    end

    def header
      @args[0]
    end

    def file_name
      @args[1]
    end

    def tags
      @args.last
    end

    def note(title = nil , *args, &var)
      if block_given?
        current_file = @args[1]
        new_note = Note.new(title, current_file, args)
        new_note.instance_exec(&var)
        @in_notes << new_note
      else
        @in_notes
      end
    end

  end

  class File

    def initialize(name, &block)
      @name = name
      @notes = []
      self.instance_eval(&block)
    end

    def note(title, *args, &var)
      current_file = @name
      new_note = Note.new(title, current_file, args)
      new_note.instance_exec(&var) if block_given?
      @notes << new_note
    end

    def name
      @name
    end

    def notes
      @notes
    end

    def daily_agenda(date)
      notes = @notes
      DailyAgendaReturnObject.new(date, notes)
    end

    def weekly_agenda(date)
      notes = @notes
      WeeklyAgendaReturnObject.new(date, notes)
    end

    class DailyAgendaReturnObject

      def initialize(given_date, notes)
        @notes = notes.reject{ |x| x.date.to_s != given_date.to_s }
        #inside_notes(given_date, notes)
        @notes
      end
=begin
      def inside_notes(given_date, notes)
        notes.each do |new_note|
          new_notes = new_note.note.reject{ |x| x.date.to_s !=
                                            given_date.to_s }
        @notes.concat(new_notes)
        end
      end
=end
      def notes
        @notes
      end

      def where
      end

    end

    class WeeklyAgendaReturnObject

      def initialize(given_date, notes)
        @notes = []
      #  7.times do
      #    @notes.concat(notes.reject{ |x| x.date.to_s != given_date.to_s })
      #    given_date.add_day
      #  end
        #inside_notes(given_date, notes)
        @notes
      end
=begin
      def inside_notes(given_date, notes)
        check = given_date
        notes.each do |new_note|
          7.times do
            new_notes = new_note.note.reject{ |x| x.date.to_s !=
                                              check.to_s }
            @notes.concat(new_notes)
            check.add_day
          end
          check = given_date
        end
      end
=end
      def notes
        @notes
      end

      def where
      end

    end

  end

end
