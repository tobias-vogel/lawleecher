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

require 'fetcher.rb'
require 'saver.rb'

class Core

  # Core is a singleton
  # this avoids having to provide the pointer to the core everywhere
  private_class_method :new
  @@singleton = nil

  def Core.createInstance
    @@singleton = new unless @@singleton
    @@singleton
  end





  def initialize
    #    @theFetcher = Fetcher.new#(self) #brauch ich nicht
    #    @theSaver = Saver.new(self)

    # this list contains all keys for the process steps found
    #    @processStepNames = []

    # name of the export file
    #    @filename = Configuration.filename

    # the law information (array of hash arrays)
    #    @laws = []
  end

  #  def filename
  #    @filename
  #  end

  #  def filename=(filename)
  #    @filename = filename
  #  end

  #  def addGuiPointer(theGui)
  #    @theGui = theGui
  #  end

  def startProcess
    lawIDs = Fetcher.retrieveLawIDs()

    @@numberOfLaws = lawIDs.size

    laws, timelineTitles, firstboxKeys = Fetcher.retrieveLawContents(lawIDs)

    @@numberOfResults = laws.size
    
    Saver.save laws, timelineTitles, firstboxKeys


    #    if errors
    #      info['status'] << ' There have been errors.' if info.has_key? 'status'
    #    end

    #    callback({'status' =>
  end



  
  # callback to the gui and/or the terminal
  def callback bunchOfInformation
    puts bunchOfInformation['status'] if bunchOfInformation.has_key?('status')
    GUI.createInstance.updateWidgets(bunchOfInformation) if Configuration.guiEnabled
  end


  def numberOfLaws
    @@numberOfLaws
  end

  def numberOfResults
    @@numberOfResults
  end

  #  def readyToStart?(overWritingPermitted)
  #    if @theSaver.fileExists? @filename and !overWritingPermitted
  #      return false
  #    else
  #      return true
  #    end
  #  end
end