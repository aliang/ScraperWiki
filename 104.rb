require 'rubygems'
require 'mechanize'

agent = Mechanize.new
file = agent.get("http://www.fdic.gov/bank/individual/failed/banklist.csv")

# hopefully not too many banks, this is inefficient implementation
lines = file.body.split("\n")

# need to remove underscores
header = lines.delete_at[0].gsub(" ", "_").split(",")
