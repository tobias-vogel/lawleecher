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

  
  def save(laws, processStepNames, filename)
    informUser({'status' => "Speichere in #{filename}..."})
    
    file = File.new(filename, "w")

    # write header in file
    # Configuration.categories + processStepNames contain all keys of the laws,
    # except for metaDuration
    file.puts((Configuration.categories + processStepNames).join(Configuration.separator))

    #write data in file
    laws.each do |law|

      # row contains all information for the current law (as array to be transformed by Array#join into a string, later)
      row = Array.new
      
      # first, save category data, since it is present at all laws
      Configuration.categories.each do |category|
        # category contains the current key like "legal bais" or "primarily responsible"
        row << law[category]
      end

      # second, save duration data
      processStepNames.sort.each do |processStepName|
        if law.key?(processStepName)
          row << law.values_at(processStepName)
        else
          row << ''
        end
      end

      # finally, join all elements together to form a string representation of
      # all the current law's contents which can be saved in the file
      line = row.join(Configuration.separator)

      # hack to replace each occurence of Ã© by é
      for i in 0..line.length - 1
        if line[i] == 195 and line[i + 1] == 169
          line[i] = 233 # = é
          line[i + 1] = '' # remove the following byte...
          i += 1 # ... and therefore, skip the following iteration step 
        end
      end

      file.puts line
    end

    file.close

    
    # do some statistics
    puts "#{laws.size} laws written into #{filename}"

    #puts 'There have been errors during processing.' if thereHaveBeenErrors


    sum = 0
    averageDuration = 0
    laws.each {|i| sum += i['MetaDuration']}
    #puts "total duration: #{sum / 60} minutes"
    averageDuration = sum / laws.size unless laws.size == 0
    #puts "average duration per law: #{averageDuration} seconds"
    return ({'status' => "Fertig. Gesamtdauer #{(sum / 60).round} Minuten, durchschnittlich pro Gesetz #{"%.2f"%averageDuration} Sekunden"})
  end
end