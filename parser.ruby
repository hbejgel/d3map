require 'geocoder'
require 'open-uri'
require 'json'
require 'csv'


def get_county(row)
  unless row[2].nil?
    if row[2]== "Defunct"
      return["0",0]
    end
    if row[3]
      name = row[2] +", "+ row[3]
    else
      name = row[2]
    end
  else
    partial = row[1].split("* ")
    if partial.length == 1
      name = row[1]
    else
      name = partial[1]
    end
    end
  coords = Geocoder.coordinates(name)
  if coords
    contents = JSON.parse(open("http://data.fcc.gov/api/block/find?latitude=#{coords[0]}&longitude=#{coords[1]}&showall=true&format=json").read)
    county = contents["County"]["name"] if contents 
    fips = contents["County"]["FIPS"].to_i if contents
    return [county,fips]
  end
  return ["0",0]
end

def write_to_csv(counties)
file = "output.csv"
CSV.open(file, "a+:utf-8") do |csv|
  counties.each do |row|
    begin
    csv << row
  rescue Exception => msg  
    puts msg
  end
  end
end
end


Geocoder.configure(:timeout => 2)
file = "institutions.csv"
csv = {}
File.open(file, "r:utf-8") do |open_file|
  csv = CSV.parse(open_file)
end

file_with_counties = []
total = 0
csv.each_with_index do |row, index|    
  begin
    last_index = (csv.length) -1
  unless index == 0     
    puts index
    if row.length == 16 || (row[16]=="0" && row[17]=="0")
      county = get_county(row)
      file_with_counties << (row<<county).flatten
    else
      file_with_counties << row
    end
    if index % 100 == 0
      total += 4
      puts total.to_s + "%"
      write_to_csv(file_with_counties)
      file_with_counties = []
    elsif index == last_index
      puts"Completed"
      write_to_csv(file_with_counties)
      file_with_counties = []
    end
  end
rescue Exception =>e 
  file_with_counties << row
  puts e.backtrace
end
end  







  