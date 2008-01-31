require 'gtk2'


window = Gtk::Window.new
table = Gtk::Table.new(2, 4, false)



startButton = Gtk::Button.new('Start')

fileChooserTextLabel = Gtk::Label.new
fileChooserButton = Gtk::Button.new('Durchsuchen...')

progressTextLabel = Gtk::Label.new
progressBar = Gtk::ProgressBar.new

statusTextLabel = Gtk::Label.new
statusLabel = Gtk::Label.new


window.signal_connect('delete_event') {Gtk::main_quit}
window.set_default_size 600, 600







fileChooserButton.signal_connect('clicked') {
  fileChooser = Gtk::FileSelection.new('Export speichern unter...')
  fileChooser.show_all

  fileChooser.ok_button.signal_connect('clicked') do
  puts "Selected filename: #{fileChooser.filename}"
  #destroy
end

fileChooser.cancel_button.signal_connect('clicked') do
  #Gtk.main_quit
  fileChooser.destroy
end

}






startButton.signal_connect('clicked') {
  progressBar.set_fraction [1, progressBar.fraction + 0.1].min
  #progressbar.pulse_step
}





# if dialog.run == Gtk::Dialog::RESPONSE_ACCEPT
#   puts "filename = #{dialog.filename}"
# end
# dialog.destroy









statusTextLabel.text = 'Status'

statusLabel.text = 'noch nichts'

progressTextLabel.text = 'Fortschritt'
#progressTextLabel.set_size_request

progressBar.text = "jkjk"
progressBar.set_size_request 100, 20

window.set_border_width 10

table.set_column_spacings 30
table.set_size_request 300, 300


window.add(table)
table.attach(startButton, 0, 2, 0, 1, Gtk::FILL, 0, 0, 0)

table.attach(fileChooserTextLabel
table.attach(fileChooserButton

table.attach(progressTextLabel, 0, 1, 2, 3, 0, 0, 0, 0)
table.attach(progressBar, 1, 2, 2, 3, 0, 0, 0, 0)

table.attach(statusTextLabel, 0, 1, 1, 2, 0, 0, 0, 0)
table.attach(statusLabel, 1, 2, 1, 2, 0, 0, 0, 0)



window.show_all

Gtk.main