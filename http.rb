#~ require 'net/http'
#~ response = Net::HTTP.get_response('http://ec.europa.eu/prelex/liste_resultats.cfm?CL=en
#~ ', '/')
#~ puts "Code = #{response.code}"
#~ puts "Message = #{response.message}"
#~ response.each {|key, val| printf "%14s = %40.40s\n", key, val }
#~ p response.body

require 'net/http'
# start query
Net::HTTP.start('ec.europa.eu') do |query|
  # number of hits per page (99 is maximum for form entry, although 10000 seems to work, too)
  numberOfHits = 10000
  
  #for each of the four types (SYN, COD, ...)
  # ["SYN", "COD", ...].do |type|
  type = "COSdingsda"
  puts "querying for type " + type
  
  
  # submit query for the current type
  # TODO: type noch einfügen, momentan fest auf CNS
  response = query.post("/prelex/liste_resultats.cfm?CL=en", "doc_typ=&docdos=dos&requete_id=0&clef1=CNS&doc_ann=&doc_num=&doc_ext=&clef4=&clef2=&clef3=&LNG_TITRE=EN&titre=&titre_boolean=&EVT1=&GROUPE1=&EVT1_DD_1=&EVT1_MM_1=&EVT1_YY_1=&EVT1_DD_2=&EVT1_MM_2=&EVT1_YY_2=&event_boolean=+and+&EVT2=&GROUPE2=&EVT2_DD_1=&EVT2_MM_1=&EVT2_YY_1=&EVT2_DD_2=&EVT2_MM_2=&EVT2_YY_2=&EVT3=&GROUPE3=&EVT3_DD_1=&EVT3_MM_1=&EVT3_YY_1=&EVT3_DD_2=&EVT3_MM_2=&EVT3_YY_2=&TYPE_DOSSIER=&NUM_CELEX_TYPE=&NUM_CELEX_YEAR=&NUM_CELEX_NUM=&BASE_JUR=&DOMAINE1=&domain_boolean=+and+&DOMAINE2=&COLLECT1=&COLLECT1_ROLE=&collect_boolean=+and+&COLLECT2=&COLLECT2_ROLE=&PERSON1=&PERSON1_ROLE=&person_boolean=+and+&PERSON2=&PERSON2_ROLE=&nbr_element=" + numberOfHits.to_s + "&first_element=1&type_affichage=1")
  
  puts response.body.class
  # check, whether all hits are on the page
  # therefore, compare the last number with the max number (e.g. 46/2110)
  # if it's equal, all hits are on this page
  puts highestNumber = response.body[/.{4}PreLex/]
  
  #...
  
  
  # additional check: there must not be these pagination buttons
  # ...
  
  #response.body.scan() do |title|
    #puts title
  #end
  #puts response.class.inspect
  puts "din der scheife"
  f = File.new("y:/law leecher/ruby/response.html", "w")
  f.puts response.body
  f.close
  
  #read out number of results (e.g. 13
  
  #response.body.
  
  
  
  
  
end