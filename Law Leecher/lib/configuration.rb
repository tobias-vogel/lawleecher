class Configuration
  # law types to crawl
  @@types = %w{AVC SYN COD CNS}
  def Configuration.types
    @@types[0]
  end
  
  # year filter to apply (empty string for all years)
  @@year = ''
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
  
  # categories to crawl
  @@categories = ['Type', 'Fields of activity', 'Legal basis', 'Procedures', 'Type of File', 'Primarily Responsible']
  def Configuration.categories
    @@categories
  end
  
  # default file name of the export
  @@defaultFilename = 'export.csv'
  def Configuration.defaultFilename
    @@defaultFilename
  end
end