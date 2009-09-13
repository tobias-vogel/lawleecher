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

  def convertUTF8ToANSI(string, law)
    begin
      Iconv.new('iso-8859-1', 'utf-8').iconv(string)  
    rescue Iconv::IllegalSequence => is
      puts "law ##{law}: Unicode character conversion error: #{is.message}"
      puts "Writing it inconverted"
      return string
    end
  end
  
  def save(laws, timelineTitles, firstboxKeys, filename)
    informUser({'status' => "Speichere in #{filename}..."})


    p "konvertierungstest"
    laws.each { |law| convertUTF8ToANSI(law.inspect, law[Configuration::ID])}



    begin
      file = File.new(filename, 'w')

      # basically, two things are done here:
      # first, the title line is composed of several array (fixed parts, variable ones)
      # second, a really big table is created where all laws and all their information are stored
      # each row is a hash
      # this table is then serialized in the file
      # one table row contains one law, basically flattening its contents
      reallyBigTable = []
      
      #      p Configuration.fixedCategories

      # write header in file
      #       Configuration.categories + processStepNames contain all keys of the laws,
      #       except for metaDuration


      # first, write all categories which are always available (but might be empty)
      headerRow = {}
      Configuration.fixedCategories.each {|category| headerRow[category] = category}

      # second, add all the timelineTitles (each twice, one with date, another with decision)
      timelineTitles.each { |title|
        headerRow[title + '.date'] = title + '.date'
        headerRow[title + '.decision'] = title + '.decision'
      }

      # third, add all the firstboxKeys
      firstboxKeys.each { |key| headerRow['firstbox.' + key] = 'fistbox.' + key}

      
      reallyBigTable << headerRow




      #      headerline = headerFields.join(Configuration.columnSeparator)
      #      file.puts convertUTF8ToANSI(((Configuration.categories + processStepNames.sort).join(Configuration.columnSeparator)))
      #      file.puts convertUTF8ToANSI(headerline)
      # write data in file

      # now, create a line in this really big table for each law

      laws.each { |law|

        # the row, which will be successively filled
        row = {}

        # first, save fixed category data, since it is reliably present at all laws (but maybe with empty strings)
        Configuration.fixedCategories.each { |category|
          
          # category contains the current key like "legal basis" or "primarily responsible"
          row[category] = law[category]
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
        timelineOfTheCurrentLaw = law['timeline'].each { |step|
          row[step['titleOfStep'] + '.date'] = step['timestamp']
          row[step['titleOfStep'] + '.decision'] = step['decision']
        }
=begin
        timelineTitles.each { |timelineTitle|

          # if the current law has this step (title) in the timeline, add its date and decision
          # else: add two empty strings

          stepTitleFoundAtIndex = -1

          timelineOfTheCurrentLaw.each_with_index { |step, index| stepTitleFoundAtIndex = index if step['titleOfStep'] == timelineTitle }
          #          if 0 < timelineOfTheCurrentLaw.count { |step| step['titleOfStep'] == timelineTitle}
          if stepTitleFoundAtIndex >= 0
            # this law uses this step, thus: take the data
            row << timelineOfTheCurrentLaw[stepTitleFoundAtIndex]['timestamp']
            row << timelineOfTheCurrentLaw[stepTitleFoundAtIndex]['decision']
          else
            # this law doesn't use this step, thus: insert two empty strings
            row << '' # for date
            row << '' # for decision
          end
        }
=end

        # third, save all firstbox data
        firstboxKeys.each { |key|
          row['firstbox.' + key] = law[Configuration::FIRSTBOX][key]

          }

        reallyBigTable << row

      }


      # now, save all the stuff
      #
      reallyBigTable.each { |row|
        line = []
        headerRow.each_key { |key|
          line << row[key]
        }
        line = line.join Configuration.columnSeparator
        file.puts convertUTF8ToANSI(line)
      }
      # finally, join all elements together to form a string representation of
      # all the current law's contents which can be saved in the file
      #        line = line.join(Configuration.columnSeparator)
      #        file.puts convertUTF8ToANSI(line)


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