require "csv"
require "sunlight"

class EventManager
  INVALID_ZIPCODE = "00000"
  INVALID_PHONE_NUMBER = "0000000000"
  Sunlight::Base.api_key = "e179a6973728c4dd3fb1204283aaccb5"

  def initialize(filename)
    puts "EventManager Initialized."
    @file = CSV.open(filename, {:headers => true, :header_converters => :symbol})
  end

  def print_names
    @file.each do |line|
      puts "#{line[:first_name]} #{line[:last_name]}"
    end
  end

  def print_numbers
    @file.each do |line|
      puts clean_number(line[:homephone])
    end
  end

  def print_zipcodes
    @file.each do |line|
      puts clean_zipcode(line[:zipcode])
    end
  end

  def rep_lookup
    20.times do
      line = @file.readline

      legislators = Sunlight::Legislator.all_in_zipcode(clean_zipcode(line[:zipcode]))
      names = legislators.collect do |leg|
        first_name = leg.firstname
        first_initial = first_name[0]
        last_name = leg.lastname
        first_initial + ". " + last_name
      end

      puts "#{line[:last_name]}, #{line[:first_name]}, #{line[:zipcode]}, #{names.join(", ")}"
    end
  end

  def clean_number(number)
    #number.gsub(/[^\d]/, '')
    number = number.delete('.()  -')
    if number.length == 11 && number[0] == "1" 
      number = number[1..-1]
    elsif number.length != 10
      number = INVALID_PHONE_NUMBER
    end
    return number 
  end

  def clean_zipcode(zipcode)
    if zipcode.nil?
      zipcode = INVALID_ZIPCODE
    elsif zipcode.length < 5
      diff = 5 - zipcode.length
      diff.times do |n|
        zipcode = zipcode.insert(n, '0')
      end
    end
    return zipcode
  end

  def output_data(filename)
    output = CSV.open(filename, "w")
    @file.each do |line|
      if @file.lineno == 2
        output << line.headers
      end
      line[:homephone] = clean_number(line[:homephone])
      line[:zipcode] = clean_zipcode(line[:zipcode])
      output << line
    end
  end

end

manager = EventManager.new("event_attendees.csv")
#manager.output_data("event_attendees_clean.csv")
manager.rep_lookup
