require 'fetcher.rb'
require 'saver.rb'

class Core
  
  def initialize
    @theFetcher = Fetcher.new
    @theSaver = Saver.new
    
    # this list contains all keys for the process steps found
    @processStepNames = []
    
    # name of the export file
    #TODO ist das auch der pfad?
    @filename = Configuration.defaultFilename
    
    # the law information (array of hash arrays)
    @laws = Array.new
  end
  
  def filename
    @filename
  end
  
  def filename=(filename)
    @filename = filename
  end

  def addGuiPointer(theGui)
    @theGui = theGui
  end

  def informUser(message)
    @theGui.printAndRefresh message
  end
  
  def startProcess
    lawIDs = @theFetcher.retrieveLawIDs()  #TODO hier callback dazufügen {@theGui.informUser}
    
    @laws, @processStepNames, errors = @theFetcher.retrieveLawContents(lawIDs)
    
    if errors
      @theGui.warn 'There have been errors.'
    end
    
    @theSaver.save @laws, @processStepNames, @filename
  end
end