# Copyright (c) 2008, Tobias Vogel (tobias@vogel.name) (the "author" in the following)
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * The name of the author must not be used to endorse or promote products
#       derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY
# EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

require 'iconv'

class Saver
  
  def initialize(theCore)
    @theCore = theCore
  end
  
  
  def fileExists?(filename)
    File.exists? filename
  end
  
  
  def informUser(bunchOfInformation)
    @theCore.callback bunchOfInformation
  end

  def convertUTF8ToANSI(string)
    begin
      Iconv.new('iso-8859-1', 'utf-8').iconv(string)  
    rescue Iconv::IllegalSequence => is
      puts "Unicode character conversion error: #{is.message}"
      puts "Writing it inconverted"
      return string
    end
  end
  
  def save(laws, timelineTitles, filename)
    informUser({'status' => "Speichere in #{filename}..."})
    
    begin
      file = File.new(filename, 'w')

#      p Configuration.fixedCategories

      # write header in file
      #       Configuration.categories + processStepNames contain all keys of the laws,
      #       except for metaDuration

      # first, write all categories which are always available (but might be empty)
      headerFields = Configuration.fixedCategories

      # second, add all the timelineTitles (each twice, one with date, another with decision)
      timelineTitles.each { |title| headerFields.concat [title + '.date', title + '.decision']}

      headerline = headerFields.join(Configuration.separator)
#      file.puts convertUTF8ToANSI(((Configuration.categories + processStepNames.sort).join(Configuration.separator)))
      file.puts convertUTF8ToANSI(headerline)

      # write data in file
      laws.each do |law|

        # row contains all information for the current law (as array to be transformed by Array#join into a string, later)
        line = []

        # first, save fixed category data, since it is present at all laws
        Configuration.fixedCategories.each { |category|
          # category contains the current key like "legal basis" or "primarily responsible"
          line << law[category]
        }

#        # second, save duration data
#        processStepNames.sort.each do |processStepName|
#          if law.key?(processStepName)
#            line << law.values_at(processStepName)[0]
#          else
#            line << ''
#          end
#        end

        # second, save all timeline data
        timelineTitles.each { |timelineTitle|
          timelineOfTheCurrentLaw = law['timeline']

          # if the current law has this step (title) in the timeline, add its date and decision
          # else: add two empty strings

          stepTitleFoundAtIndex = -1

          timelineOfTheCurrentLaw.each_with_index { |step, index| stepTitleFoundAtIndex = index if step['titleOfStep'] == timelineTitle }
#          if 0 < timelineOfTheCurrentLaw.count { |step| step['titleOfStep'] == timelineTitle}
          if stepTitleFoundAtIndex >= 0
            # this law uses this step, thus: take the data
            line << timelineOfTheCurrentLaw[stepTitleFoundAtIndex]['timestamp']
            line << timelineOfTheCurrentLaw[stepTitleFoundAtIndex]['decision']
          else
            # this law doesn't use this step, thus: insert two empty strings
            line << '' # for date
            line << '' # for decision
          end
        }


        # finally, join all elements together to form a string representation of
        # all the current law's contents which can be saved in the file
        line = line.join(Configuration.separator)
        file.puts convertUTF8ToANSI(line)
      end

      file.close


      # do some statistics
#      puts "#{laws.size} Gesetz(e) wurden in #{filename} geschrieben."



#      sum = 0
#      averageDuration = 0
#      laws.each {|i| sum += i['MetaDuration']}
#      averageDuration = sum / laws.size unless laws.size == 0
#      return ({'status' => "Fertig. Gesamtdauer #{(sum / 60).round} Minuten, durchschnittlich #{"%.2f"%averageDuration} Sekunden pro Gesetz"})
    end
  
  rescue Exception => ex
    return ({'status' => "Datei #{filename} konnte nicht geöffnet werden. Wird sie von einem anderen Programm benutzt?"})
  end
end