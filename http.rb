require 'net/http'

################################################################################
# declaration of some important parameters of the program
################################################################################

#types = ["CNS", "COD", "SYN", "AVC"]
types = ["AVC"]
numberOfMaxHitsPerPage = 10000 #max on the web front is 99


################################################################################
# helper function which gets redirection requests up to 10 steps deep
################################################################################
require 'uri'

def fetch(uri_str, limit = 10)
    # You should choose better exception.
    raise ArgumentError, 'HTTP redirect too deep' if limit == 0

    response = Net::HTTP.get_response(URI.parse(uri_str))
    case response
        when Net::HTTPSuccess then response
        when Net::HTTPRedirection then fetch(response['location'], limit - 1)
    else
        response.error!
    end
end



#removes whitespaces and HTML tags from a given string
#maintains single word spacing blanks
def removeDust(string)

    #convert &nbsp; into blanks
    string.gsub!(/&nbsp;/, ' ')

    #remove whitespaces
    string.gsub!(/\r/, '')
    string.gsub!(/\n/, '')
    string.gsub!(/\t/, '')

    #convert multiple blanks into single blanks
    string.gsub!(/\ +/, ' ')

    #remove HTML tags, if there are any
    string.gsub!(/<.+?>/, '') unless ((string =~ /<.+?>/) == nil)

    return string
end





################################################################################
# program
################################################################################

results = Array.new

types.each do |type|

    puts "retrieving " + type + "..."

    # start query for current type
    # todo: key => value, damit mans besser lesen kann
    response = Net::HTTP.start('ec.europa.eu').post("/prelex/liste_resultats.cfm?CL=en", "doc_typ=&docdos=dos&requete_id=0&clef1=" + type + "&doc_ann=&doc_num=&doc_ext=&clef4=&clef2=2000&clef3=&LNG_TITRE=EN&titre=&titre_boolean=&EVT1=&GROUPE1=&EVT1_DD_1=&EVT1_MM_1=&EVT1_YY_1=&EVT1_DD_2=&EVT1_MM_2=&EVT1_YY_2=&event_boolean=+and+&EVT2=&GROUPE2=&EVT2_DD_1=&EVT2_MM_1=&EVT2_YY_1=&EVT2_DD_2=&EVT2_MM_2=&EVT2_YY_2=&EVT3=&GROUPE3=&EVT3_DD_1=&EVT3_MM_1=&EVT3_YY_1=&EVT3_DD_2=&EVT3_MM_2=&EVT3_YY_2=&TYPE_DOSSIER=&NUM_CELEX_TYPE=&NUM_CELEX_YEAR=&NUM_CELEX_NUM=&BASE_JUR=&DOMAINE1=&domain_boolean=+and+&DOMAINE2=&COLLECT1=&COLLECT1_ROLE=&collect_boolean=+and+&COLLECT2=&COLLECT2_ROLE=&PERSON1=&PERSON1_ROLE=&person_boolean=+and+&PERSON2=&PERSON2_ROLE=&nbr_element=" + numberOfMaxHitsPerPage.to_s + "&first_element=1&type_affichage=1")

    content = response.body


    # check, whether all hits are on the page
    # there are two ways to check it, we use both for safety reasons

    # first, compare the last number with the max number (e.g. 46/2110)
    # if it's equal, all hits are on this page, which is good
    lastEntryOnPage = content[/\d{1,5}\/\d{1,5}(?=<\/div>\n\t\t<\/TD>\n\t<\/TR>\n\t\n\t\t<TR bgcolor=\"#ffffcc\">\n        \t<TD colspan=\"2\" VALIGN=\"top\">\n        \t<FONT CLASS=\"texte\"> Proposal for a COUNCIL DECISION on the accession of the European Community to Regulation 109 of the United Nations Economic Commission for Europe concerning the approval for the production of retreaded pneumatic tyres for commercial vehicles and their trailers<\/FONT>\n        \t<\/TD>\n\t\t<\/TR>\n\t\n\n\n<\/table>\n\n\n\n<center>\n<TABLE border=0 cellpadding=0 cellspacing=0>\n<tr align=\"center\">\n\t\n\n\n\t\n\t\n<\/tr>\n<\/table>\n<\/center>\n\n\n\r\n\r\n\r\n\r\n\r\n\r\n\t\t\t\t\r\n\t\t\t\t<!-- BOTTOM NAVIGATION BAR)/]

    lastEntry, maxEntries = lastEntryOnPage.split("/", 2)

    puts "ALARM" unless lastEntry == maxEntries

    puts maxEntries + " entries found"


    # second, the pagination buttons must not be present (at least no "page 2" button)
    puts "ALARM" unless nil === content[/<td align="center"><font size="-2" face="arial, helvetica">2<\/font><br\/>/]



    # fetch out links for each single law
    lawIDs = (content.scan /\d{1,6}(?=" title="Click here to reach the detail page of this file">)/).uniq
    puts lawIDs


    # for each lawID, submit HTTP GET request for fetching out the information of interest
    lawIDs.each do |lawID|
        puts "retrieving law ##{lawID}"
        response = fetch("http://ec.europa.eu/prelex/detail_dossier_real.cfm?CL=en&DosId=#{lawID}")
        content = response.body

        # prepare array containing all information for the current law
        arrayEntry = Hash.new

        # since ruby 1.8.6 cannot handle positive look-behinds, the crawling is two-stepped


        # TODO: warum ist der erste anders als die anderen?

        # find out the value for "fields of activity"
        fieldsOfActivity = content[/Fields of activity:<\/font>\s*<\/center>\s*<\/td>\s*<td BGCOLOR="#EEEEEE">\s*<font face="Arial,Helvetica" size=-2>\s*.*?(?=<\/tr>)/m]
        fieldsOfActivity.gsub!(/Fields of activity:<\/font>\s*<\/center>\s*<\/td>\s*<td BGCOLOR="#EEEEEE">\s*<font face="Arial,Helvetica" size=-2>\s*(?=.*)/m, '')
        fieldsOfActivity.gsub!(/<br>\s*<\/font>\s*<\/td>/, '')
        fieldsOfActivity = removeDust(fieldsOfActivity)
        arrayEntry["Fields of activity"] = fieldsOfActivity


        # find out the value for "legal basis"
        legalBasis = content[/Legal basis:\s*<\/font>\s*<\/center>\s*<\/td>\s*<td BGCOLOR="#FFFFFF">\s*<font face="Arial,Helvetica" size=-2>.*?(?=<\/tr>)/m]
        legalBasis.gsub!(/Legal basis:\s*<\/font>\s*<\/center>\s*<\/td>\s*<td BGCOLOR="#FFFFFF">\s*<font face="Arial,Helvetica" size=-2>(?=.*)/m, '')
        legalBasis = removeDust(legalBasis)
        arrayEntry["Legal basis"] = legalBasis


        # find out the value for "procedures"
        procedures = content[/Procedures:<\/font>\s*<\/center>\s*<\/td>\s*<td BGCOLOR="#EEEEEE">\s*<font face="Arial,Helvetica" size=-2>.*?(?=<\/tr>)/m]
        procedures.gsub!(/Procedures:<\/font>\s*<\/center>\s*<\/td>\s*<td BGCOLOR="#EEEEEE">\s*<font face="Arial,Helvetica" size=-2>(?=.*?<\/tr>)/m, '')
        # convert all \t resp. \r\n into blanks
        procedures = removeDust(procedures)
        arrayEntry["Procedures"] = procedures


        # find out the value for "type of file"
        typeOfFile = content[/Type of file:<\/font>\s*<\/center>\s*<\/td>\s*<td BGCOLOR="#FFFFFF">\s*<font face="Arial,Helvetica" size=-2>.*?(?=<\/tr>)/m]
        typeOfFile.gsub!(/Type of file:<\/font>\s*<\/center>\s*<\/td>\s*<td BGCOLOR="#FFFFFF">\s*<font face="Arial,Helvetica" size=-2>(?=.*?<\/tr>)/m, '')
        # convert all \t resp. \r\n into blanks
        typeOfFile = removeDust(typeOfFile)
        arrayEntry["Type of File"] = typeOfFile


        # find out the value for "primarily responsible"
        primarilyResponsible = content[/Primarily responsible<\/font><\/font><\/td>\s*<td VALIGN=TOP><font face="Arial"><font size=-2>.*?(?=<\/tr>)/m]
        primarilyResponsible.gsub!(/Primarily responsible<\/font><\/font><\/td>\s*<td VALIGN=TOP><font face="Arial"><font size=-2>(?=.*?<\/tr>)/, '')
        # convert all \t resp. \r\n into blanks
        primarilyResponsible = removeDust(primarilyResponsible)
        arrayEntry["Primarily Responsible"] = primarilyResponsible



#        arrayEntry.each {|i, j| puts "#{i} => #{j}"; puts}

        #add the law, processed above
        results << arrayEntry

    end



results[0].each {|i, j| puts "#{i} => #{j}"; puts}

separator = '#'
categories = ['Fields of activity', 'Legal basis', 'Procedures', 'Type of File', 'Primarily Responsible']
fileName = 'export.csv'

file = File.new(fileName, "w")

#write header in file
file.puts categories.join(separator)

#write data in file
results.each do |law|
    temp = Array.new
    categories.each do |category|
        temp << law[category]
    end

    file.puts temp.join(separator)
end

#file.puts law.values.join(separator)}


puts "#{results.size} laws written into #{fileName}"
exit 0








  #response.body.scan() do |title|
    #puts title
  #end
  #puts response.class.inspect
#   puts "din der scheife"
  f = File.new("response.html", "w")
  f.puts response.body
  f.close


#   g = File.new("response.html", "r")
#   15.times do |i|
#     puts g.gets
#   end
  #read out number of results (e.g. 13

  #response.body.
end


