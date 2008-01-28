require 'net/http'

################################################################################
# declaration of some important parameters of the program
################################################################################

types = ["CNS", "COD", "SYN", "AVC"]
types = ["AVC"]

#year, empty string for "all years"
year = '1998'

numberOfMaxHitsPerPage = 10000 #max on the web front is 99

separator = '#' #separator for attributes in file

#things to crawl out of web page, array order determines the order in the file
categories = ['Fields of activity', 'Legal basis', 'Procedures', 'Type of File', 'Primarily Responsible']

fileName = 'export.csv'



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

    #remove HTML tags, if there are any
    string.gsub!(/<.+?>/, '') unless ((string =~ /<.+?>/) == nil)

    #convert &nbsp; into blanks
    string.gsub!(/&nbsp;/, ' ')

    #remove whitespaces
    string.gsub!(/\r/, '')
    string.gsub!(/\n/, '')
    string.gsub!(/\t/, '')

    #remove blanks at end
    string.strip!

    #convert multiple blanks into single blanks
    string.gsub!(/\ +/, ' ')

    return string
end





################################################################################
# program
################################################################################
# algorithm:
# first, find all law ids to have a maximum number for the progress bar
# second, crawl each page
# third, write all to file

################################################################################
# STEP 1: find all law ids
################################################################################

#array containing all law ids
lawIDs = Array.new

types.each do |type|

    puts "looking for #{type} laws..."
    # start query for current type
    # todo: key => value, damit mans besser lesen kann
    response = Net::HTTP.start('ec.europa.eu').post('/prelex/liste_resultats.cfm?CL=en', "doc_typ=&docdos=dos&requete_id=0&clef1=#{type}&doc_ann=&doc_num=&doc_ext=&clef4=&clef2=#{year}&clef3=&LNG_TITRE=EN&titre=&titre_boolean=&EVT1=&GROUPE1=&EVT1_DD_1=&EVT1_MM_1=&EVT1_YY_1=&EVT1_DD_2=&EVT1_MM_2=&EVT1_YY_2=&event_boolean=+and+&EVT2=&GROUPE2=&EVT2_DD_1=&EVT2_MM_1=&EVT2_YY_1=&EVT2_DD_2=&EVT2_MM_2=&EVT2_YY_2=&EVT3=&GROUPE3=&EVT3_DD_1=&EVT3_MM_1=&EVT3_YY_1=&EVT3_DD_2=&EVT3_MM_2=&EVT3_YY_2=&TYPE_DOSSIER=&NUM_CELEX_TYPE=&NUM_CELEX_YEAR=&NUM_CELEX_NUM=&BASE_JUR=&DOMAINE1=&domain_boolean=+and+&DOMAINE2=&COLLECT1=&COLLECT1_ROLE=&collect_boolean=+and+&COLLECT2=&COLLECT2_ROLE=&PERSON1=&PERSON1_ROLE=&person_boolean=+and+&PERSON2=&PERSON2_ROLE=&nbr_element=#{numberOfMaxHitsPerPage.to_s}&first_element=1&type_affichage=1")

    content = response.body


#puts content[content.size-2500..content.size-700]

    # check, whether all hits are on the page
    # there are two ways to check it, we use both for safety reasons

    # first, compare the last number with the max number (e.g. 46/2110)
    # if it's equal, all hits are on this page, which is good

    lastEntryOnPage = content[/\d{1,5}\/\d{1,5}(?=<\/div>\s*<\/TD>\s*<\/TR>\s*<TR bgcolor=\"#(ffffcc|ffffff)\">\s*<TD colspan=\"2\" VALIGN=\"top\">\s*<FONT CLASS=\"texte\">.*<\/FONT>\s*<\/TD>\s*<\/TR>\s*<\/table>\s*<center>\s*<TABLE border=0 cellpadding=0 cellspacing=0>\s*<tr align=\"center\">\s*<\/tr>\s*<\/table>\s*<\/center>\s*<!-- BOTTOM NAVIGATION BAR)/]

#exit 0
    lastEntry, maxEntries = lastEntryOnPage.split("/", 2)

    #TODO:EXCEOTION werfen
    puts "ALARM" unless lastEntry == maxEntries


    # second, the pagination buttons must not be present (at least no "page 2" button)
    #TODO:EXCEOTION werfen
    puts "ALARM" unless nil === content[/<td align="center"><font size="-2" face="arial, helvetica">2<\/font><br\/>/]


    puts "#{maxEntries} laws found for #{type}"


    #fetch out ids for each single law as array and append it to the current set of ids
    #the uniq! removes double ids (<a href="id">id</a>)
    lawIDs += (content.scan /\d{1,6}(?=" title="Click here to reach the detail page of this file">)/).uniq!

end

#now, all law IDs are contained in the array

#assure that there are no doublicated ids in the array (which should not be the case)
numberOfLaws = lawIDs.size
lawIDs.uniq!

#TODO: excepotion
puts "ALARM, es gab id-dopplungen" if lawIDs.size != numberOfLaws

puts "#{numberOfLaws} laws found in total"


################################################################################
# STEP 2: crawl each page
################################################################################

#array containing all law information
results = Array.new


# for each lawID, submit HTTP GET request for fetching out the information of interest
currentLaw = 1
lawIDs.each do |lawID|

    startTime = Time.now

    puts "retrieving law ##{lawID} (#{currentLaw}/#{numberOfLaws})"
    response = fetch("http://ec.europa.eu/prelex/detail_dossier_real.cfm?CL=en&DosId=#{lawID}")
    content = response.body

    # prepare array containing all information for the current law
    arrayEntry = Hash.new

    # since ruby 1.8.6 cannot handle positive look-behinds, the crawling is two-stepped


    # TODO: warum ist der erste anders als die anderen?

    # find out the value for "fields of activity"
    fieldsOfActivity = content[/Fields of activity:<\/font>\s*<\/center>\s*<\/td>\s*<td BGCOLOR="#EEEEEE">\s*<font face="Arial,Helvetica" size=-2>\s*.*?(?=<\/tr>)/m]
    fieldsOfActivity.gsub!(/Fields of activity:<\/font>\s*<\/center>\s*<\/td>\s*<td BGCOLOR="#EEEEEE">\s*<font face="Arial,Helvetica" size=-2>/, '')
    #fieldsOfActivity.gsub!(/<br>\s*<\/font>\s*<\/td>/, '')
    fieldsOfActivity = removeDust(fieldsOfActivity)
    arrayEntry['Fields of activity'] = fieldsOfActivity


    # find out the value for "legal basis"
    legalBasis = content[/Legal basis:\s*<\/font>\s*<\/center>\s*<\/td>\s*<td BGCOLOR="#FFFFFF">\s*<font face="Arial,Helvetica" size=-2>.*?(?=<\/tr>)/m]
    legalBasis.gsub!(/Legal basis:\s*<\/font>\s*<\/center>\s*<\/td>\s*<td BGCOLOR="#FFFFFF">\s*<font face="Arial,Helvetica" size=-2>/, '')
    legalBasis = removeDust(legalBasis)
    arrayEntry['Legal basis'] = legalBasis


    # find out the value for "procedures"
    procedures = content[/Procedures:<\/font>\s*<\/center>\s*<\/td>\s*<td BGCOLOR="#EEEEEE">\s*<font face="Arial,Helvetica" size=-2>.*?(?=<\/tr>)/m]
    procedures.gsub!(/Procedures:<\/font>\s*<\/center>\s*<\/td>\s*<td BGCOLOR="#EEEEEE">\s*<font face="Arial,Helvetica" size=-2>/, '')
    # convert all \t resp. \r\n into blanks
    procedures = removeDust(procedures)
    arrayEntry['Procedures'] = procedures


    # find out the value for "type of file"
    typeOfFile = content[/Type of file:<\/font>\s*<\/center>\s*<\/td>\s*<td BGCOLOR="#FFFFFF">\s*<font face="Arial,Helvetica" size=-2>.*?(?=<\/tr>)/m]
    typeOfFile.gsub!(/Type of file:<\/font>\s*<\/center>\s*<\/td>\s*<td BGCOLOR="#FFFFFF">\s*<font face="Arial,Helvetica" size=-2>/, '')
    # convert all \t resp. \r\n into blanks
    typeOfFile = removeDust(typeOfFile)
    arrayEntry['Type of File'] = typeOfFile


    # find out the value for "primarily responsible"
    primarilyResponsible = content[/Primarily responsible<\/font><\/font><\/td>\s*<td VALIGN=TOP><font face="Arial"><font size=-2>.*?(?=<\/tr>)/m]
    # primarily responsible may be empty
    if primarilyResponsible == nil
        primarilyResponsible == ''
    else
        primarilyResponsible.gsub!(/Primarily responsible<\/font><\/font><\/td>\s*<td VALIGN=TOP><font face="Arial"><font size=-2>/, '')
        # convert all \t resp. \r\n into blanks
        primarilyResponsible = removeDust(primarilyResponsible)
    end
    arrayEntry['Primarily Responsible'] = primarilyResponsible


    endTime = Time.now

    arrayEntry['Duration'] = endTime - startTime


#        arrayEntry.each {|i, j| puts "#{i} => #{j}"; puts}

    #add the law processed above
    results << arrayEntry

    currentLaw += 1

end

#results[0].each {|i, j| puts "#{i} => #{j}"; puts}


################################################################################
# STEP 3: write all to file
################################################################################

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



puts "#{results.size} laws written into #{fileName}"



sum = 0
results.each {|i| sum += i['Duration']}
puts "total duration: #{sum / 60} minutes"
averageDuration = sum / results.size
puts "average duration per law: #{averageDuration} seconds"


exit 0

f = File.new("response.html", "w")
f.puts response.body
f.close