require 'fetcher.rb'
require 'saver.rb'

class Core
  
  def initialize
    @theFetcher = Fetcher.new(self)
    @theSaver = Saver.new(self)
    
    # this list contains all keys for the process steps found
    @processStepNames = []
    
    # name of the export file
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

  def startProcess
    lawIDs = @theFetcher.retrieveLawIDs()
    
    @laws, @processStepNames, errors = @theFetcher.retrieveLawContents(lawIDs)
    
    info = @theSaver.save @laws, @processStepNames, @filename    
    
    if errors
      info['status'] << ' There have been errors.' if info.has_key? 'status'
    end
    
    callback(info)
    
  end
  
  # callback to the gui
  def callback(bunchOfInformation)
    puts bunchOfInformation['status'] if bunchOfInformation.has_key?('status')
    @theGui.updateWidgets(bunchOfInformation)    
  end
  
  def readyToStart?(overWritingPermitted)
    if @theSaver.fileExists? @filename and !overWritingPermitted
      return false
    else
      return true
    end
  end
end