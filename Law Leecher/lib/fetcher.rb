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

require 'net/http'
require 'set'
require 'configuration.rb'
require 'date/format'
require 'monitor'
require 'parser_thread.rb'

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
    
    http = Net::HTTP.start('ec.europa.eu')
    
    # we will retrieve a 25 MB HTML file, which might take longer
    http.read_timeout = 300
    http.open_timeout = 300

    informUser({'status' => 'Frage alle Gesetze an. Das kann durchaus mal zwei Minuten oder mehr dauern.'})
    response = http.post('/prelex/liste_resultats.cfm?CL=en', "doc_typ=&docdos=dos&requete_id=0&clef1=&doc_ann=&doc_num=&doc_ext=&clef4=&clef2=#{Configuration.year}&clef3=&LNG_TITRE=EN&titre=&titre_boolean=&EVT1=&GROUPE1=&EVT1_DD_1=&EVT1_MM_1=&EVT1_YY_1=&EVT1_DD_2=&EVT1_MM_2=&EVT1_YY_2=&event_boolean=+and+&EVT2=&GROUPE2=&EVT2_DD_1=&EVT2_MM_1=&EVT2_YY_1=&EVT2_DD_2=&EVT2_MM_2=&EVT2_YY_2=&EVT3=&GROUPE3=&EVT3_DD_1=&EVT3_MM_1=&EVT3_YY_1=&EVT3_DD_2=&EVT3_MM_2=&EVT3_YY_2=&TYPE_DOSSIER=&NUM_CELEX_TYPE=&NUM_CELEX_YEAR=&NUM_CELEX_NUM=&BASE_JUR=&DOMAINE1=&domain_boolean=+and+&DOMAINE2=&COLLECT1=&COLLECT1_ROLE=&collect_boolean=+and+&COLLECT2=&COLLECT2_ROLE=&PERSON1=&PERSON1_ROLE=&person_boolean=+and+&PERSON2=&PERSON2_ROLE=&nbr_element=#{Configuration.numberOfMaxHitsPerPage.to_s}&first_element=1&type_affichage=1")
    content = response.body


    # check, whether all hits are on the page
    # there are two ways to check it, we use both for safety reasons

    # first, compare the last number with the max number (e.g. 46/2110)
    # if it's equal, all hits are on this page, which is good, otherwise: bad

    lastEntryOnPage = content[/\d{1,5}\/\d{1,5}(?=<\/div>\s*<\/TD>\s*<\/TR>\s*<TR bgcolor=\"#(ffffcc|ffffff)\">\s*<TD colspan=\"2\" VALIGN=\"top\">\s*<FONT CLASS=\"texte\">.*<\/FONT>\s*<\/TD>\s*<\/TR>\s*<\/table>\s*<center>\s*<TABLE border=0 cellpadding=0 cellspacing=0>\s*<tr align=\"center\">\s*<\/tr>\s*<\/table>\s*<\/center>\s*<!-- BOTTOM NAVIGATION BAR)/]

    lastEntry, maxEntries = lastEntryOnPage.split('/', 2)

    raise 'Not all laws on page. (last entry != number of entries)' unless lastEntry == maxEntries


    # second, the pagination buttons must not be present (at least no "page 2" button)
    raise 'There are pagination buttons, not all laws would be retrieved.' unless nil === content[/<td align="center"><font size="-2" face="arial, helvetica">2<\/font><br\/>/]


    #fetch out ids for each single law as array and append it to the current set of ids
    #the uniq! removes double ids (<a href="id">id</a>)
    lawIDs = content.scan(/\d{1,6}(?=" title="Click here to reach the detail page of this file">)/)
    lawIDs.uniq! # to eliminate the twin of each law id (which is inevitably included)
    lawIDs.delete 219546 # this law is is an empty entry

    informUser({'status' => "#{maxEntries} Gesetze gefunden"})
      

    return lawIDs
  end
  
  
  
  
  
  
  
  
  
  
  
  
  def retrieveLawContents(lawIDs)
    lawIDs = lawIDs[0..0]#99]
    lawIDs = [187990]
    lawIDs = [100979]
    lawIDs = [161462, 153545, 152718, 150322, 150061, 147499, 146939, 146977]
    
    # array containing all law information
    results = Array.new

    # counter for the current law (basically for informing the user)
    #    currentLawCount = 1
    
    # flag signalling whether there occured errors during processing
    thereHaveBeenErrors = false
    
    # set of process step names (will be collected to be used for the csv file columns)
    processStepNames = Set.new
    
    # the mutex which is needed to synchronicly save the dataset of details a parsed law into the result set
    lock = Monitor.new

    # the array in which the threads (references) are stored
    threads = []

    #    puts "ich selbst bin thread:" + Thread.list.inspect

    # large array which will contain all the parsed law details
    results = []

    vorher = Time.now

    #    erstesMal = true
    #    lieblingsthread = nil

    while !lawIDs.empty?
      puts "aktuelle threads (#{threads.size} stück):"
      threads.each_index { |index| puts "thread #{index}: status=#{threads[index].status}, alive=#{threads[index].alive?}" }
      #print "laufende threads: #{Thread.list.size} von #{Configuration.numberOfParserThreads}\n"

      # iterate over the list of threads and remove those, who have finished
      threads.map! { |thread|
        if !thread.alive?
          # if thread is finished (= !alive), save the result and replace this thread entry with nil (to delete it, later)
          results << thread.value
          nil
        else
          # if the thread has not finished yet, replace the entry with itself (no change)
          thread
        end
      }.compact!

      
      # don't trust Thread.list.size (formerly used in:  if (Thread.list.size - 1 < Configuration.numberOfParserThreads)
      # instead: iterate over the threads array and check, whether all are still alive
      # and purge all dead threads
      # afterwards, the number of still living threads makes up the number of actually alive threads
      #wichtig!?      #threads.map! {|thread| thread if thread.alive?}.compact!



      #      p "#{threads.size} threads laut threads.size"

      if (threads.size < Configuration.numberOfParserThreads)
        # start a new thread
        #        puts "starting a new thread because only #{Thread.list.size - 1} of #{Configuration.numberOfParserThreads} slots are used"
        theLawToProcess = lawIDs.shift
        #        threads << Thread.new(theLawToProcess) { |lawID|
        #          parserThread = ParserThread.new lawID, lock, results
        #          parserThread.retrieveAndParseALaw
        #        }

        #        puts "hurra, kann einen neuen thread starten!!!!!11"
        threads << Thread.new {
#          p theLawToProcess
          parserThread = ParserThread.new
          parserThread.retrieveAndParseALaw theLawToProcess

          #  2+2
          #
          #
          #
          #
          #sleep rand * 10; 2+2
        }
      else
        # do not create a new thread now, instead wait a bit
        #        puts "currently, all slots are full"
        #          puts Thread.list.inspect
        #    puts currentthreadcount if Thread.list.size == 1
        #Thread.pass
        #          puts ergebnis.inspect
        #        puts Thread.list.inspect
        sleep 0.5
        # TODO muss lieber sleep 0.1 sein
      end
      #      if erstesMal
      #        lieblingsthread = threads[0]
      #      end
      #      erstesMal = false;

      #      p "#{threads.size} threads gibt es laut threads.size"
      #      1000000.times do
      #        p lieblingsthread.alive?
      #      end

    end

    #    threads.each {|thread| print "#{thread.alive?} "}

#    puts results.inspect

    puts "no more laws left, waiting for threads to finish"
    threads.each {|thread|
      #      p "im threadjoin allgemein"
      #      p thread.alive?
      #p thread.value
      thread.join
      #      p thread.alive?
      #      p thread.value
      
    }

    p "nicht zu jedem gesetz ist was zurückgekommen" unless results.size == lawIDs.size

    nachher = Time.now

    puts "Dauer bei #{Configuration.numberOfParserThreads} threads: #{nachher - vorher}"

    return results, processStepNames.to_a, thereHaveBeenErrors
  end
end