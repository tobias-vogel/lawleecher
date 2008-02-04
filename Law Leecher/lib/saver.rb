class Saver
  def initialize
  end
  
  def save(laws, processStepNames, filename)
    if File.exists? filename
      puts "datei #{filename} existiert bereits, breche ab"
      exit -1
    end
    file = File.new(filename, "w")
    puts "speichere in #{filename}"

    # write header in file
    # Configuration.categories + processStepNames contain all keys of the laws,
    # except for metaDuration
    file.puts((Configuration.categories + processStepNames).join(Configuration.separator))

    #write data in file
    laws.each do |law|

      # row contains all information for the current law (as array to be transformed by Array#join into a string, later)
      row =  Array.new
      
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
      file.puts row.join(Configuration.separator)
    end

    file.close

    
    # do some statistics
    puts "#{laws.size} laws written into #{filename}"

    #puts 'There have been errors during processing.' if thereHaveBeenErrors


    sum = 0
    averageDuration = 0
    laws.each {|i| sum += i['MetaDuration']}
    puts "total duration: #{sum / 60} minutes"
    averageDuration = sum / laws.size unless laws.size == 0
    puts "average duration per law: #{averageDuration} seconds"
  end
end