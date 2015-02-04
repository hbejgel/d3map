require 'csv'

file = "output.csv"
csv = {}
File.open(file, "r:utf-8") do |open_file|
  csv = CSV.parse(open_file)
end
counties = {}
states = {}
count = 0
csv.each do |output|
  if output[8] && output[3] && output[-1] && output[-2] && output[-1]
   count += 1
   coi = output[8]
   county = output[-2]
   fips = output[-1]
   state = output[3]
   if !counties[fips]
     counties[fips] = []
     counties[fips][0] = 0
     counties[fips][1] = 0
     counties[fips][2] = 0
     counties[fips][3] = county
     counties[fips][4] = fips
   end
   if !states[state]
     states[state] = []
     states[state][0] = 0
     states[state][1] = 0
     states[state][2] = 0
     states[state][3] = state
   end
   
   counties[fips][0] += 1
   states[state][0] += 1
   if coi == "1"
     counties[fips][1] += 1
     states[state][1] += 1
   end
   counties[fips][2] = ((counties[fips][1].to_f/counties[fips][0])*100).round(2) 
   states[state][2] = ((states[state][1].to_f/states[state][0])*100).round(2) 
  end
end

CSV.open("counties_info.csv", "w:utf-8") do |csv|
  csv << ["Percentage","County","Fips"]
  counties.each do |key, value|
    csv << value[2..4]
  end
end
CSV.open("states_info.csv", "w:utf-8") do |csv|
  csv << ["Percentage","State"]
  states.each do |key, value|
    csv << value[2..3]
  end
end
