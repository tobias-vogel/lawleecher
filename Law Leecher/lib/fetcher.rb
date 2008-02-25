require 'net/http'
require 'set'
require 'configuration.rb'
require 'date/format'
#require 'win32/sound'

class Fetcher
  
  def initialize(theCore)
    @theCore = theCore
  end
  
  def informUser(bunchOfInformation)
    @theCore.callback bunchOfInformation
  end
  
  def retrieveLawIDs
    #array containing all law ids
    lawIDs = Array.new
    
    Configuration.types.each do |type|
      puts "looking for #{type} laws..."
      # start query for current type
      response = Net::HTTP.start('ec.europa.eu').post('/prelex/liste_resultats.cfm?CL=en', "doc_typ=&docdos=dos&requete_id=0&clef1=#{type}&doc_ann=&doc_num=&doc_ext=&clef4=&clef2=#{Configuration.year}&clef3=&LNG_TITRE=EN&titre=&titre_boolean=&EVT1=&GROUPE1=&EVT1_DD_1=&EVT1_MM_1=&EVT1_YY_1=&EVT1_DD_2=&EVT1_MM_2=&EVT1_YY_2=&event_boolean=+and+&EVT2=&GROUPE2=&EVT2_DD_1=&EVT2_MM_1=&EVT2_YY_1=&EVT2_DD_2=&EVT2_MM_2=&EVT2_YY_2=&EVT3=&GROUPE3=&EVT3_DD_1=&EVT3_MM_1=&EVT3_YY_1=&EVT3_DD_2=&EVT3_MM_2=&EVT3_YY_2=&TYPE_DOSSIER=&NUM_CELEX_TYPE=&NUM_CELEX_YEAR=&NUM_CELEX_NUM=&BASE_JUR=&DOMAINE1=&domain_boolean=+and+&DOMAINE2=&COLLECT1=&COLLECT1_ROLE=&collect_boolean=+and+&COLLECT2=&COLLECT2_ROLE=&PERSON1=&PERSON1_ROLE=&person_boolean=+and+&PERSON2=&PERSON2_ROLE=&nbr_element=#{Configuration.numberOfMaxHitsPerPage.to_s}&first_element=1&type_affichage=1")

      content = response.body


      # check, whether all hits are on the page
      # there are two ways to check it, we use both for safety reasons

      # first, compare the last number with the max number (e.g. 46/2110)
      # if it's equal, all hits are on this page, which is good, otherwise: bad

      lastEntryOnPage = content[/\d{1,5}\/\d{1,5}(?=<\/div>\s*<\/TD>\s*<\/TR>\s*<TR bgcolor=\"#(ffffcc|ffffff)\">\s*<TD colspan=\"2\" VALIGN=\"top\">\s*<FONT CLASS=\"texte\">.*<\/FONT>\s*<\/TD>\s*<\/TR>\s*<\/table>\s*<center>\s*<TABLE border=0 cellpadding=0 cellspacing=0>\s*<tr align=\"center\">\s*<\/tr>\s*<\/table>\s*<\/center>\s*<!-- BOTTOM NAVIGATION BAR)/]

      lastEntry, maxEntries = lastEntryOnPage.split("/", 2)

      raise 'Not all laws on page. (last entry != number of entries)' unless lastEntry == maxEntries


      # second, the pagination buttons must not be present (at least no "page 2" button)
      raise 'There are pagination buttons, not all laws would be retrieved.' unless nil === content[/<td align="center"><font size="-2" face="arial, helvetica">2<\/font><br\/>/]


      #puts "#{maxEntries} laws found for #{type}"


      #fetch out ids for each single law as array and append it to the current set of ids
      #the uniq! removes double ids (<a href="id">id</a>)
      lawIDsFromCurrentType = content.scan(/\d{1,6}(?=" title="Click here to reach the detail page of this file">)/)
      lawIDsFromCurrentType.uniq! # to eliminate the twin of each law id (which is inevitably included)
      lawIDsFromCurrentType.delete 219546 # this law is is an empty entry
      lawIDs += lawIDsFromCurrentType
      
      informUser({'status' => "#{maxEntries} laws found for #{type}"})
      
    end # of current type

    #now, all law IDs are contained in the array

    #assure that there are no doublicated ids in the array (which should not be the case)
    numberOfLaws = lawIDs.size
    lawIDs.uniq!

    raise 'There were laws which occured on different pages.' if lawIDs.size != numberOfLaws

    #puts "#{numberOfLaws} laws found in total"
    
    informUser({'status' => "#{numberOfLaws} laws found in total"})
    
    return lawIDs
  end
  
  
  
  
  
  
  
  
  
  
  
  
  def retrieveLawContents(lawIDs)
    # array containing all law information
    results = Array.new

    # counter for the current law (basically for informing the user)
    currentLawCount = 1
    
    # flag signalling whether there occured errors during processing
    thereHaveBeenErrors = false
    
    # set of process step names (will be collected to be used for the csv file columns)
    processStepNames = Set.new
    
    # number of retries, if remote host closed connection error occured
    # then, the current lawID is appended to lawIDs and to avoid, retriesLeft is
    # decremented before the end of lawIDs.each
    # probably, lawIDs.each will only be iterated 2 times at most
    #retriesLeft = 5
    
    # for each lawID, submit HTTP GET request for fetching out the information of interest  
    lawIDs.each do |lawID|
#lawID = 105604
      #puts ""
    
      #puts "vorne"

      begin # start try block

        # save this to calculate the average duration
        metaStartTime = Time.now

        #puts "retrieving law ##{lawID} (#{currentLawCount}/#{lawIDs.size})"
        informUser({'status' => "retrieving law ##{lawID}",
                    'progressBarText' => "#{currentLawCount}/#{lawIDs.size}",
                    'progressBarIncrement' => 1.0 / lawIDs.size})
        
        response = fetch("http://ec.europa.eu/prelex/detail_dossier_real.cfm?CL=en&DosId=#{lawID}")
        content = response.body

        # prepare array containing all information for the current law
        arrayEntry = Hash.new

        # since ruby 1.8.6 cannot handle positive look-behinds, the crawling is two-stepped


        # find out the value for "fields of activity"
        begin
          fieldsOfActivity = content[/Fields of activity:<\/font>\s*<\/center>\s*<\/td>\s*<td BGCOLOR="#EEEEEE">\s*<font face="Arial,Helvetica" size=-2>\s*.*?(?=<\/tr>)/m]
          fieldsOfActivity.gsub!(/Fields of activity:<\/font>\s*<\/center>\s*<\/td>\s*<td BGCOLOR="#EEEEEE">\s*<font face="Arial,Helvetica" size=-2>/, '')
          fieldsOfActivity = clean(fieldsOfActivity)
          raise if fieldsOfActivity.empty?
        rescue
          #this law does not have "fields of activity" data
          fieldsOfActivity = '[fehlt]'
        end
        arrayEntry['Fields of activity'] = fieldsOfActivity




        # find out the value for "legal basis"
        begin
          legalBasis = content[/Legal basis:\s*<\/font>\s*<\/center>\s*<\/td>\s*<td BGCOLOR="#FFFFFF">\s*<font face="Arial,Helvetica" size=-2>.*?(?=<\/tr>)/m]
          legalBasis.gsub!(/Legal basis:\s*<\/font>\s*<\/center>\s*<\/td>\s*<td BGCOLOR="#FFFFFF">\s*<font face="Arial,Helvetica" size=-2>/, '')
          legalBasis = clean(legalBasis)
          raise if legalBasis.empty?
        rescue
          # this law does not have "legal basis" data
          legalBasis = '[fehlt]'
        end
        arrayEntry['Legal basis'] = legalBasis




        # find out the value for "procedures"
        begin
          procedures = content[/Procedures:<\/font>\s*<\/center>\s*<\/td>\s*<td BGCOLOR="#EEEEEE">\s*<font face="Arial,Helvetica" size=-2>.*?(?=<\/tr>)/m]
          procedures.gsub!(/Procedures:<\/font>\s*<\/center>\s*<\/td>\s*<td BGCOLOR="#EEEEEE">\s*<font face="Arial,Helvetica" size=-2>/, '')
          # convert all \t resp. \r\n into blanks
          procedures = clean(procedures)
          # if "procedures" contains a value for commission and council, remove the commission value
          procedures.gsub!(/.*Commission ?: ?.*?(?=Council ?: ?)/, '') if procedures[/.*Commission.*Council.*/] != nil
          raise if procedures.empty?
        rescue
          # this law does not have "procedures" data
          procedures = '[fehlt]'
        end
        arrayEntry['Procedures'] = procedures




        # find out the value for "type of file"
        begin
          typeOfFile = content[/Type of file:<\/font>\s*<\/center>\s*<\/td>\s*<td BGCOLOR="#FFFFFF">\s*<font face="Arial,Helvetica" size=-2>.*?(?=<\/tr>)/m]
          typeOfFile.gsub!(/Type of file:<\/font>\s*<\/center>\s*<\/td>\s*<td BGCOLOR="#FFFFFF">\s*<font face="Arial,Helvetica" size=-2>/, '')
          # convert all \t resp. \r\n into blanks
          typeOfFile = clean(typeOfFile)
          #if "type of file" contains a value for commission and council, remove the commission value
          typeOfFile.gsub!(/.*Commission ?: ?.*?(?=Council ?: ?)/, '') if typeOfFile[/.*Commission.*Council.*/] != nil
          raise if typeOfFile.empty?
        rescue
          # this law does not have "type of file" data
          typeOfFile = '[fehlt]'
        end
        arrayEntry['Type of File'] = typeOfFile




        # find out the value for "primarily responsible"
        begin
          primarilyResponsible = content[/Primarily responsible<\/font><\/font><\/td>\s*<td VALIGN=TOP><font face="Arial"><font size=-2>.*?(?=<\/tr>)/m]
          primarilyResponsible.gsub!(/Primarily responsible<\/font><\/font><\/td>\s*<td VALIGN=TOP><font face="Arial"><font size=-2>/, '')
          # convert all \t resp. \r\n into blanks
          primarilyResponsible = clean(primarilyResponsible)
          raise if primarilyResponsible.empty?
        rescue
          # this law does not have "primarily responsible" data
          primarilyResponsible = '[fehlt]'
        end
        arrayEntry['Primarily Responsible'] = primarilyResponsible




        # find out the law type (has been forgotten since only law IDs were saved)
        begin
          type = content[/<font face="Arial">\s*<font size=-1>(\d{4}\/)?\d{4}\/(AVC|COD|SYN|CNS)(?=<\/font>\s*<\/font>)/]
          type.gsub!(/<font face="Arial">\s*<font size=-1>(\d{4}\/)?\d{4}\//, '')
          raise if type.empty?
        rescue
          # this law does not have "type" data
          type = '[fehlt]'
        end
        arrayEntry['Type'] = type




        # find out the process duration information
        # create a hash with a time object as key and the name of the process step as value
        # then it will be automatically sorted by time and we can give out the values one after another
        begin
          #puts content[40000..50000]
          processSteps = content[/<strong>&nbsp;&nbsp;Events:<\/strong><br><br>\s*<table.*?(?=<\/table>\s*<p><u><font face="arial"><font size=-2>Activities of the institutions:)/m]
          processSteps.gsub!(/<strong>&nbsp;&nbsp;Events:<\/strong><br><br>\s*<table border="0" cellpadding="0" cellspacing="1">\s*<tr>\s*<td>\s*<div align="left">\s*<span class="exemple">\s*<a href="#\d{5,6}" style="color: Black;">\s*/, '')
          processSteps = processSteps.split(/\s*<\/span>\s*<\/div>\s*<\/td>\s*<\/tr>\s*<tr>\s*<td>\s*<div align="left">\s*<span class="exemple">\s*<a href="#\d{5,6}" style="color: Black;">\s*/)
          processSteps.last.gsub!(/\s*<\/span>\s*<\/div>\s*<\/td>\s*<\/tr>\s*/, '')
          # necessary if there is only one process step, because then, the split above doesn't remove whitespaces
          #processSteps.last.gsub!(/\s*/, '') if processSteps.size == 1
          #processSteps.last.strip! if processSteps.size == 1

          # iterate over processSteps, do 3 things:
          # first, add the process step name to the global list of process steps
          # second, transform date into a time object to calculate with it
          # third, build up Hash (step name => timestamp resp. difference)
          #stepTimeHash = {}

          # create the variable here to have a scope over the next iterator
          @timeOfFirstStep = nil
          
          
          # defines the offset of the year (since ruby only supports timestamps beginning with          
          # 01.01.1970) which is only valid for (and affects only) the current law
          yearOffset = 0

          # container for the largest single duration (= the duration of the whole law)
          # is overwritten in each process step and thus, contains the maximum duration
          # since the dates are ordered chronological on the page
          lastDuration = 0

          # states, whether the process step "Adoption by Commission" has been
          # found in this law already
          # if not, the appropriate hash entry has to be created and set to "[fehlt]"
          adoptionByCommissionFoundForThisLaw = false
          
          processSteps.each do |step|
            
            stepName, timeStamp = step.split(/<\/a>\s*<br>&nbsp;&nbsp;/)
            
#            if stepName == 'AdoptionbyCommission'
#              #Win32::Sound.beep(100, 2000)
#              puts 'AdoptionbyCommission gefunden'
#            end
            
            #puts stepName + " => " + timeStamp

            # first (add to global list)
#            if stepName == "Commission position on EP amendments on 1st reading"
#              puts "komisches verhalten erreicht"
#              puts "processstepnamessize = " + processStepNames.size.to_s
#            end

            # prevent overwriting process step names of the same name which occured earlier in this law
            # therefore: extend a step name (e.g. "abc") by "A" (=> "abc A"), then "B" (=> "abc B") and so on
            # 
            # so: check, whether step name already exists in any level of extension (even without extension)
            # if not: do nothing special and go on
            # if yes: check, which is the highest level
            #   if it's the step name itself, add " A" to it
            #   if there are already extensions, do a .next! to proceed to the next level
            highestLevelOfCurrentStepNameExtension = (arrayEntry.keys.grep(/#{stepName}( \w?)?/)).sort.max
            if highestLevelOfCurrentStepNameExtension != nil
              if highestLevelOfCurrentStepNameExtension == stepName
                stepName += ' A'
              else 
                stepName.next!
              end
            end
#             unless highestLevelOfCurrentStepNameExtension == nil 
#            if arrayEntry.has_key? stepName
#              if arrayEntry.has_key? "#{stepName} A"
#                if arrayEntry.has_key? "#{stepName} B"
#                  if arrayEntry.has_key? "#{stepName} C"
#                    if arrayEntry.has_key? "#{stepName} D"
#                      if arrayEntry.has_key? "#{stepName} E"
#                        if arrayEntry.has_key? "#{stepName} F"
#                          if arrayEntry.has_key? "#{stepName} G"
#                            if arrayEntry.has_key? "#{stepName} H"
#                              if arrayEntry.has_key? "#{stepName} I"
#                                if arrayEntry.has_key? "#{stepName} J"
#                                  if arrayEntry.has_key? "#{stepName} K"
#                                    if arrayEntry.has_key? "#{stepName} L"
#                                      if arrayEntry.has_key? "#{stepName} M"
#                                        if arrayEntry.has_key? "#{stepName} N"
#                                          if arrayEntry.has_key? "#{stepName} O"
#                                            if arrayEntry.has_key? "#{stepName} P"
#                                              if arrayEntry.has_key? "#{stepName} Q"
#                                                if arrayEntry.has_key? "#{stepName} R"
#                                                  if arrayEntry.has_key? "#{stepName} S"
#                                                    if arrayEntry.has_key? "#{stepName} T"
#                                                      if arrayEntry.has_key? "#{stepName} U"
#                                                        if arrayEntry.has_key? "#{stepName} V"
#                                                          if arrayEntry.has_key? "#{stepName} W"
#                                                            if arrayEntry.has_key? "#{stepName} X"
#                                                              if arrayEntry.has_key? "#{stepName} Y"
#                                                                stepName = "#{stepName} Z"
#                                                              else stepName = "#{stepName} Y" end
#                                                            else stepName = "#{stepName} X" end
#                                                          else stepName = "#{stepName} W" end
#                                                        else stepName = "#{stepName} V" end
#                                                      else stepName = "#{stepName} U" end
#                                                    else stepName = "#{stepName} T" end
#                                                  else stepName = "#{stepName} S" end
#                                                else stepName = "#{stepName} R" end
#                                              else stepName = "#{stepName} Q" end
#                                            else stepName = "#{stepName} P" end
#                                          else stepName = "#{stepName} O" end
#                                        else stepName = "#{stepName} N" end
#                                      else stepName = "#{stepName} M" end
#                                    else stepName = "#{stepName} L" end
#                                  else stepName = "#{stepName} K" end
#                                else stepName = "#{stepName} J" end
#                              else stepName = "#{stepName} I" end
#                            else stepName = "#{stepName} H" end
#                          else stepName = "#{stepName} G" end
#                        else stepName = "#{stepName} F" end
#                      else stepName = "#{stepName} E" end
#                    else stepName = "#{stepName} D" end
#                  else stepName = "#{stepName} C" end
#                else stepName = "#{stepName} B" end
#              else stepName = "#{stepName} A" end
#            end
            
            processStepNames << stepName
#            puts "processstepnamessize = " + processStepNames.size.to_s
#            puts processStepNames.include?("Commission position on EP amendments on 1st reading")
#            
            
            
            # save the signature timestamp additionally
            if stepName == 'Signature by EP and Council'
              processStepNames << 'Date of Signature by EP and Council'
              arrayEntry['Date of Signature by EP and Council'] = timeStamp
            end
            
            # if "Adoption by Commission" has been found, the key hasn't to be
            # set to "[fehlt]" in the end
            if stepName == 'Adoption by Commission'
              adoptionByCommissionFoundForThisLaw = true
            end
            
            
            #second (parse date)
            parsedDate = Date._parse timeStamp
            
            # if year is critical or (is it not, but) offset has been used in an
            # earlier iteration within this law
            if parsedDate[:year] < 1970 or yearOffset != 0
              yearOffset = 10 # shift law 10 years into the future
            end
            
            time = Time.utc parsedDate[:year] + yearOffset, parsedDate[:mon], parsedDate[:mday]

            timeStampOrDuration = timeStamp

            if @timeOfFirstStep == nil
              @timeOfFirstStep = time
            else
              #calculate the difference between first and current timeStamp
              #seconds are returned, not milliseconds (!)
              duration = ((time - @timeOfFirstStep) / 60 / 60 / 24).floor
              timeStampOrDuration = duration
              lastDuration = duration
            end

            #third (add duration)
            arrayEntry[stepName] = timeStampOrDuration
          end
          
          #puts lastDuration
          arrayEntry['DurationInformation'] = lastDuration

          #if there was no "Adoption by Commission" process step,
          #it has to be marked that way
          arrayEntry['Adoption by Commission'] = '[fehlt]' unless adoptionByCommissionFoundForThisLaw
          
          
#stepTimeHash.each {|i| puts i}
        rescue StandardError => ex
          puts 'Something went wrong during calculation of process step duration'
          puts ex.message
          puts ex.backtrace
        end



        metaEndTime = Time.now
        arrayEntry['MetaDuration'] = metaEndTime - metaStartTime
        
        arrayEntry['ID'] = lawID

        #add all fetched information (which is stored in arrayEntry) in the results array, finally
        results << arrayEntry

        currentLawCount += 1
        

      rescue Exception => ex
        
#        if ex.message == 'An existing connection was forcibly closed by the remote host.' or
#           ex.message == 'end of file reached' 
        if ex.class == Errno::ECONNRESET or ex.class == Timeout::Error or ex.class == EOFError  
          puts "Zeitüberschreitung bei Gesetz ##{lawID}. Starte dieses Gesetz nochmal von vorne."
          retry
        else
          puts "Es gab einen Fehler mit Gesetz ##{lawID}. Dieses Gesetz wird ignoriert."
          puts ex.message
          puts ex.class
          puts ex.backtrace
          thereHaveBeenErrors = true
        end
      end #of exception handling
#        arrayEntry.each {|i, j| puts "#{i} => #{j}"; puts}
    end
    
    return results, processStepNames.to_a, thereHaveBeenErrors
  end

  

  
private
  # fetches HTTP requests which use redirects
  def fetch(uri_str, limit = 10)
    # You should choose better exception.
    raise ArgumentError, 'HTTP redirect too deep' if limit == 0

#    begin
      response = Net::HTTP.get_response(URI.parse(uri_str))
      case response
          when Net::HTTPSuccess then response
          when Net::HTTPRedirection then fetch(response['location'], limit - 1)
      else
          response.error!
      end
#    rescue Exception => ex
#      puts ex
#      puts ex.class
#      puts ex.message
#      puts ex.backtrace
#    end
  end
  
  
  
  
  # removes whitespaces and HTML tags from a given string
  # maintains single word spacing blanks
  def clean(string)
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
end