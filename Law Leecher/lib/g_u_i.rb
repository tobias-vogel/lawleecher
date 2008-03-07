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

require 'gtk2'

class GUI
  def initialize(theCore)
    @theCore = theCore
    
    window = Gtk::Window.new("Law Leecher #{Configuration.version}")
    window.set_border_width 10
    window.set_default_size 1, 1
    window.set_resizable false


    table = Gtk::Table.new(5, 6, false)
    table.set_column_spacings 30
    table.set_row_spacings 5



    fileChooserTextLabel = Gtk::Label.new('Dateiname')
    fileNameEntry = Gtk::Entry.new()
    fileNameEntry.set_text @theCore.filename
    fileNameEntry.set_size_request 400, 20
    fileChooserButton = Gtk::Button.new('Durchsuchen...')


    overWriteButton = Gtk::ToggleButton.new()
    overWriteButtonLabel = Gtk::Label.new('Vorhandene Datei ggfs. überschreiben')
    

    startButton = Gtk::Button.new('Start')



    @progressBar = Gtk::ProgressBar.new
    @progressBar.text = ''




    @statusLabel = Gtk::Label.new
    @statusLabel.justify= Gtk::JUSTIFY_LEFT






    #signals ###################################################################

    window.signal_connect('delete_event') {
      Gtk::main_quit
      exit!
    }


    fileChooserButton.signal_connect('clicked') {
        fileChooser = Gtk::FileSelection.new('Export speichern unter...')
        fileChooser.show_all
        fileChooser.ok_button.signal_connect('clicked') do
            @theCore.filename= fileNameEntry.text = fileChooser.filename
            
            fileChooser.destroy
        end

        fileChooser.cancel_button.signal_connect('clicked') do
            fileChooser.destroy
        end
    }

    fileNameEntry.signal_connect('key_release_event') {
      puts @theCore.filename= fileNameEntry.text
    }
    
    
    startButton.signal_connect('clicked') {
      if @theCore.readyToStart?(overWriteButton.active?)
        updateWidgets({'progressBarText' => '', 'status' => ''})
        @progressBar.set_fraction 0
        startButton.set_sensitive false
        fileChooserButton.set_sensitive false
        fileNameEntry.set_sensitive false
        overWriteButton.set_sensitive false
        while Gtk.events_pending?
          Gtk.main_iteration
        end
        @theCore.startProcess
        startButton.set_sensitive true
        fileChooserButton.set_sensitive true
        fileNameEntry.set_sensitive true
        overWriteButton.set_sensitive true
      else
        dialog = Gtk::MessageDialog.new(window,
                                        Gtk::Dialog::DESTROY_WITH_PARENT,
                                        Gtk::MessageDialog::ERROR,
                                        Gtk::MessageDialog::BUTTONS_CLOSE,
                                        "Die Datei #{fileNameEntry.text} existiert bereits und das Häkchen zum Überschreiben ist nicht gesetzt.")
        dialog.run
        dialog.destroy
      end
    }







    #pack ######################################################################

    window.add(table)

    table.attach(fileChooserTextLabel, 0, 1, 0, 1, 0, 0, 0, 0)
    table.attach(fileNameEntry, 1, 5, 0, 1, 0, 0, 0, 0)
    table.attach(fileChooserButton, 5, 6, 0, 1, 0, 0, 0, 0)

    table.attach(overWriteButton, 1, 2, 1, 2, 0, 0, 0, 0)
    table.attach(overWriteButtonLabel, 1, 4, 1, 2, 0, 0, 0, 0)
    
    table.attach(startButton, 0, 1, 2, 3, Gtk::FILL, 0, 0, 0)
    table.attach(@progressBar, 1, 6, 2, 3, Gtk::FILL, 0, 0, 0)

    table.attach(@statusLabel, 0, 6, 3, 4, 0, 0, 0, 0)

    window.show_all
  end
  
  
  def run
    Gtk.main
  end
  
  def updateWidgets(info)
    @progressBar.text = info['progressBarText'] if info.has_key? 'progressBarText'
    @progressBar.set_fraction([@progressBar.fraction + info['progressBarIncrement'], 1].min) if info.has_key? 'progressBarIncrement'
    @statusLabel.text = info['status'] if info.has_key? 'status'

    while Gtk.events_pending?
      Gtk.main_iteration
    end
  end
end