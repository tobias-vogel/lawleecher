class Configuration
  # law types to crawl
  @@types = %w{AVC SYN COD CNS}
  def Configuration.types
    @@types#first
  end

  # year filter to apply (empty string for all years)
  @@year = ''
  #@@year = '2000'
  def Configuration.year
    @@year
  end
  
  # maximum hits per form submit (originally: 99)
  @@numberOfMaxHitsPerPage = 10000
  def Configuration.numberOfMaxHitsPerPage
    @@numberOfMaxHitsPerPage
  end
  
  # csv file column separator
  @@separator = '#'
  def Configuration.separator
    @@separator
  end

  # the text which is put if a key has no value on the website
  @@missingEntry = '[fehlt]'
  def Configuration.missingEntry
    @@missingEntry
  end
  
  # categories to crawl
  @@categories = ['Type', 'ID', 'Fields of activity', 'Legal basis', 'Procedures', 'Type of File', 'Primarily Responsible', 'DurationInformation']
  def Configuration.categories
    @@categories
  end
  
  # default file name of the export
  @@defaultFilename = "#{Dir.pwd}/export.csv"
  def Configuration.defaultFilename
    @@defaultFilename
  end
end