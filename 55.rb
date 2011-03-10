require 'rubygems'
require 'mechanize'
require 'nokogiri'

agent = Mechanize.new

start_page = agent.get("http://www.knesset.gov.il/mk/eng/mkindex_current_eng.asp?view=0")

start_page.search("a.EngDataText").each do |link|
  result = {}
  
  result['url'] = "http://www.knesset.gov.il/mk/eng/" + link['href']
  
  # print page easier to work with
  page = agent.get(result['url'].sub("mk_eng", "mk_print_eng"))
  
  page.search("span.Title2").each do |span|
    # grab all the elements until the next span.Title2
    
  end
end