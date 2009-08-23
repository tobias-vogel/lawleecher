# TODO lizenz einfügen
class ParserThread
  def initialize lawID, lock, results
#    print "parser thread gestartet mit law ##{lawID}\n"
    @lawID = lawID
    @lock = lock
    @results = results
  end

  def retrieveAndParseALaw

    processStepNames = []

    begin # start try block

      # save this to calculate the average duration
      metaStartTime = Time.now

#      informUser({'status' => "Analysiere Gesetz ##{@lawID}",
  #        'progressBarText' => "#{currentLawCount}/#{lawIDs.size}",
#          'progressBarIncrement' => 1.0 / lawIDs.size})

      response = fetch("http://ec.europa.eu/prelex/detail_dossier_real.cfm?CL=en&DosId=#{@lawID}")
      content = response.body

      # prepare array containing all information for the current law
      arrayEntry = Hash.new



      # check, whether some specific errors occured
      if !content[/<H1>Database Error<\/H1>/].nil? then
        puts 'This law produced a data base error and thus, is ommitted.'
        next
      end

      if !content[/<H1>Unexpected Error<\/H1>/].nil? then
        puts 'This law produced an "unexpected error" and thus, is ommitted.'
        next
      end







      # the preamble has no key words, so it will be extracted first as whole (for safety) and then is divided into the three parts
      preamble = content[/<table BORDER=\"0\" WIDTH=\"100%\" bgcolor=\"#C0C0FF\">\s*<tr>\s*<td>\s*<table CELLPADDING=2 WIDTH=\"100%\" Border=\"0\">\s*<tr>\s*<td ALIGN=LEFT VALIGN=TOP WIDTH=\"50%\">\s*<b><font face=\"Arial\"><font size=-1>.*?<\/font><\/font><\/b>\s*<\/td>\s*<td ALIGN=LEFT VALIGN=TOP WIDTH=\"50%\">\s*<b><font face=\"Arial\"><font size=-1>.*?<\/font><\/font><\/b>\s*<\/td>\s*<td ALIGN=RIGHT VALIGN=TOP>\s*<\/td>\s*<\/tr>\s*<tr>\s*<td ALIGN=LEFT VALIGN=TOP COLSPAN=\"3\" WIDTH=\"100%\">\s*<font face="Arial"><font size=-2>.*?<\/font><\/font>\s*<\/td>\s*<\/tr>/m]


      # since ruby 1.8.6 cannot handle positive look-behinds, the crawling is two-stepped

      # find out the value for the upper left identifier
      begin
        upperLeftIdentifier = preamble[/<table BORDER=\"0\" WIDTH=\"100%\" bgcolor=\"#C0C0FF\">\s*<tr>\s*<td>\s*<table CELLPADDING=2 WIDTH=\"100%\" Border=\"0\">\s*<tr>\s*<td ALIGN=LEFT VALIGN=TOP WIDTH=\"50%\">\s*<b><font face=\"Arial\"><font size=-1>.*?(?=<\/font><\/font><\/b>\s*<\/td>)/m]
        upperLeftIdentifier.gsub!(/<table BORDER=\"0\" WIDTH=\"100%\" bgcolor=\"#C0C0FF\">\s*<tr>\s*<td>\s*<table CELLPADDING=2 WIDTH=\"100%\" Border=\"0\">\s*<tr>\s*<td ALIGN=LEFT VALIGN=TOP WIDTH=\"50%\">\s*<b><font face=\"Arial\"><font size=-1>/m, '')
        upperLeftIdentifier = clean(upperLeftIdentifier)
        raise if upperLeftIdentifier.empty?
      rescue
        #this law does not have data for the upper left identifier
        upperLeftIdentifier = Configuration.missingEntry
      end
      arrayEntry['Upper left identifier'] = upperLeftIdentifier






      # find out the value for the upper center identifier
      begin
        upperCenterIdentifier = preamble[/<\/font><\/font><\/b>\s*<\/td>\s*<td ALIGN=LEFT VALIGN=TOP WIDTH=\"50%\">\s*<b><font face=\"Arial\"><font size=-1>.*?(?=<\/font><\/font><\/b>\s*<\/td>\s*<td ALIGN=RIGHT VALIGN=TOP>\s*<\/td>\s*<\/tr>\s*<tr>\s*<td ALIGN=LEFT VALIGN=TOP COLSPAN=\"3\" WIDTH=\"100%\">\s*<font face="Arial"><font size=-2>)/m]
        upperCenterIdentifier.gsub!(/<\/font><\/font><\/b>\s*<\/td>\s*<td ALIGN=LEFT VALIGN=TOP WIDTH=\"50%\">\s*<b><font face=\"Arial\"><font size=-1>/m, '')
        upperCenterIdentifier = clean(upperCenterIdentifier)
        raise if upperCenterIdentifier.empty?
      rescue
        #this law does not have data for the upper center identifier
        upperCenterIdentifier = Configuration.missingEntry
      end
      arrayEntry['Upper center identifier'] = upperCenterIdentifier







      # find out the value for the short description
      begin
        shortDescription = preamble[/<\/font><\/font><\/b>\s*<\/td>\s*<td ALIGN=RIGHT VALIGN=TOP>\s*<\/td>\s*<\/tr>\s*<tr>\s*<td ALIGN=LEFT VALIGN=TOP COLSPAN=\"3\" WIDTH=\"100%\">\s*<font face="Arial"><font size=-2>.*?(?=<\/font><\/font>\s*<\/td>\s*<\/tr>)/m]
        shortDescription.gsub!(/<\/font><\/font><\/b>\s*<\/td>\s*<td ALIGN=RIGHT VALIGN=TOP>\s*<\/td>\s*<\/tr>\s*<tr>\s*<td ALIGN=LEFT VALIGN=TOP COLSPAN=\"3\" WIDTH=\"100%\">\s*<font face="Arial"><font size=-2>/m, '')
        shortDescription= clean(shortDescription)
        raise if shortDescription.empty?
      rescue
        #this law does not have data for the short description
        shortDescription = Configuration.missingEntry
      end
      arrayEntry['Short description'] = shortDescription






      # find out the value for "fields of activity"
      begin
        fieldsOfActivity = content[/Fields of activity:<\/font>\s*<\/center>\s*<\/td>\s*<td BGCOLOR="#EEEEEE">\s*<font face="Arial,Helvetica" size=-2>\s*.*?(?=<\/tr>)/m]
        fieldsOfActivity.gsub!(/Fields of activity:<\/font>\s*<\/center>\s*<\/td>\s*<td BGCOLOR="#EEEEEE">\s*<font face="Arial,Helvetica" size=-2>/, '')
        fieldsOfActivity = clean(fieldsOfActivity)
        raise if fieldsOfActivity.empty?
      rescue
        #this law does not have "fields of activity" data
        fieldsOfActivity = Configuration.missingEntry
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
        legalBasis = Configuration.missingEntry
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
        procedures = Configuration.missingEntry
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
        typeOfFile = Configuration.missingEntry
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
        primarilyResponsible = Configuration.missingEntry
      end
      arrayEntry['Primarily Responsible'] = primarilyResponsible




      # find out the law type
      begin
        type = content[/<font face="Arial">\s*<font size=-1>(\d{4}\/)?\d{4}\/(AVC|COD|SYN|CNS)(?=<\/font>\s*<\/font>)/]
        type.gsub!(/<font face="Arial">\s*<font size=-1>(\d{4}\/)?\d{4}\//, '')
        raise if type.empty?
      rescue
        # this law does not have "type" data
        type = Configuration.missingEntry
      end
      arrayEntry['Type'] = type


      # this law seems to be empty, if the following entries are empty (upper left identifier is given, nevertheless)
      if fieldsOfActivity == Configuration.missingEntry and
          legalBasis == Configuration.missingEntry and
          procedures == Configuration.missingEntry and
          typeOfFile == Configuration.missingEntry and
          primarilyResponsible == Configuration.missingEntry and
          upperCenterIdentifier == Configuration.missingEntry and
          shortDescription == Configuration.missingEntry
        raise Exception.new('empty law')
      end


      # find out the process duration information
      # create a hash with a time object as key and the name of the process step as value
      # then it will be automatically sorted by time and we can give out the values one after another
      begin
        processSteps = content[/<strong>&nbsp;&nbsp;Events:<\/strong><br><br>\s*<table.*?(?=<\/table>)/m]
        processSteps.gsub!(/<strong>&nbsp;&nbsp;Events:<\/strong><br><br>\s*<table border="0" cellpadding="0" cellspacing="1">\s*<tr>\s*<td>\s*<div align="left">\s*<span class="exemple">\s*<a href="#\d{5,6}" style="color: Black;">\s*/, '')
        processSteps = processSteps.split(/\s*<\/span>\s*<\/div>\s*<\/td>\s*<\/tr>\s*<tr>\s*<td>\s*<div align="left">\s*<span class="exemple">\s*<a href="#\d{5,6}" style="color: Black;">\s*/)
        processSteps.last.gsub!(/\s*<\/span>\s*<\/div>\s*<\/td>\s*<\/tr>\s*/, '')

        # iterate over processSteps, do 3 things:
        # first, add the process step name to the global list of process steps
        # second, transform date into a time object to calculate with it
        # third, build up Hash (step name => timestamp resp. difference)

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
        # if not, the appropriate hash entry has to be created and set to Configuration.missingEntry
        adoptionByCommissionFoundForThisLaw = false

        processSteps.each do |step|

          stepName, timeStamp = step.split(/<\/a>\s*<br>&nbsp;&nbsp;/)


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
              stepName = highestLevelOfCurrentStepNameExtension.next
            end
          end

          processStepNames << stepName


          # save the signature timestamp additionally
          if stepName == 'Signature by EP and Council'
            processStepNames << 'Date of Signature by EP and Council'
            arrayEntry['Date of Signature by EP and Council'] = timeStamp
          end

          # if "Adoption by Commission" has been found, the key hasn't to be
          # set to Configuration.missingEntry in the end
          if stepName == 'Adoption by Commission'
            adoptionByCommissionFoundForThisLaw = true
          end


          # second (parse date)
          parsedDate = Date._parse timeStamp

          # this occurs only with law #115427
          parsedDate[:year] = 1986 if parsedDate[:year] == 986


          # this occurs only with law #148799
          parsedDate[:year] = 1982 if parsedDate[:year] == 1820


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

        arrayEntry['DurationInformation'] = lastDuration

        #if there was no "Adoption by Commission" process step,
        #it has to be marked that way
        arrayEntry['Adoption by Commission'] = Configuration.missingEntry unless adoptionByCommissionFoundForThisLaw



      rescue StandardError => ex
        puts 'Something went wrong during calculation of process step duration'
        puts ex.message
        puts ex.backtrace
        thereHaveBeenErrors = true
      end



      metaEndTime = Time.now
      arrayEntry['MetaDuration'] = metaEndTime - metaStartTime

      arrayEntry['ID'] = @lawID


      @lock.synchronize {
        #add all fetched information (which is stored in arrayEntry) in the results array, finally
        @results << arrayEntry

#        currentLawCount += 1
      }

    rescue Exception => ex

      if ex.class == Errno::ECONNRESET or ex.class == Timeout::Error or ex.class == EOFError
        puts "Zeitüberschreitung bei Gesetz ##{@lawID}. Starte dieses Gesetz nochmal von vorne."
        retry
      elsif ex.message == 'empty law'
        puts "Gesetz #{@lawID} scheint leer zu sein. Dieses Gesetz wird ignoriert."
      else
        puts "Es gab einen echten Fehler mit Gesetz ##{@lawID}. Dieses Gesetz wird ignoriert."
        puts ex.message
        puts ex.class
        puts ex.backtrace
        thereHaveBeenErrors = true
      end
    end #of exception handling
  end



  private

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


  
  # fetches HTTP requests which use redirects
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

end