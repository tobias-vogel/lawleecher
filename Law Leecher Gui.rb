require 'gtk2'
require 'core.rb'

def rechnelange (widget)
puts "rechnelange"
#puts widget.class
10000.times {|i| widget.set_fraction (100/10000*i)
}
end

#widgets #######################################################################

window = Gtk::Window.new('Law Leecher')
window.set_border_width 10
#window.set_size_request 100, 100
window.set_default_size 200, 100
window.set_resizable false


table = Gtk::Table.new(5, 6, false)
table.set_column_spacings 30
table.set_row_spacings 5
#table.set_size_request 300, 300



welcomeLabel = Gtk::Label.new('Exportprogramm, unten auf "Start" klicken')

fileChooserTextLabel = Gtk::Label.new('Dateiname')
fileNameEntry = Gtk::Entry.new
fileChooserButton = Gtk::Button.new('Durchsuchen...')



startButton = Gtk::Button.new('Start')



progressTextLabel = Gtk::Label.new('Fortschritt')

progressBar = Gtk::ProgressBar.new
progressBar.text = "jkjk"



statusTextLabel = Gtk::Label.new('Status')

statusLabel = Gtk::Label.new
statusLabel.text = 'noch nichts'






#signals #######################################################################

window.signal_connect('delete_event') {Gtk::main_quit}


fileChooserButton.signal_connect('clicked') {
    fileChooser = Gtk::FileSelection.new('Export speichern unter...')
    fileChooser.show_all
    fileChooser.ok_button.signal_connect('clicked') do
        fileNameEntry.text = fileChooser.filename
        fileChooser.destroy
    end

    fileChooser.cancel_button.signal_connect('clicked') do
        fileChooser.destroy
    end
}

startButton.signal_connect('clicked') {

  10000.times {
    progressBar.set_fraction(progressBar.fraction + 0.0001)
    100000.times {1}
    while Gtk.events_pending?
      Gtk.main_iteration
    end
  }
  #5.times {progressBar.set_fraction [1, progressBar.fraction + 0.1].min}
  #rechnelange *progressBar
}







#pack ##########################################################################

window.add(table)

table.attach(welcomeLabel, 0, 6, 0, 1, 0, 0, 0, 0)

table.attach(fileChooserTextLabel, 0, 2, 1, 2, 0, 0, 0, 0)
table.attach(fileNameEntry, 2, 4, 1, 2, 0, 0, 0, 0)
table.attach(fileChooserButton, 4, 6, 1, 2, 0, 0, 0, 0)

table.attach(startButton, 2, 6, 2, 3, Gtk::FILL, 0, 0, 0)

table.attach(progressTextLabel, 0, 2, 3, 4, 0, 0, 0, 0)
table.attach(progressBar, 2, 6, 3, 4, Gtk::FILL, 0, 0, 0)

table.attach(statusTextLabel, 0, 2, 4, 5, 0, 0, 0, 0)
table.attach(statusLabel, 2, 6, 4, 5, 0, 0, 0, 0)


window.show_all

Gtk.main