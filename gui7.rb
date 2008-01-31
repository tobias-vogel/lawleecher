require 'gtk2'

fs = Gtk::FileSelection.new("Please select a file for editing.")

fs.ok_button.signal_connect("clicked") do
  puts "Selected filename: #{fs.filename}"
end

fs.cancel_button.signal_connect("clicked") do
  Gtk.main_quit
end

fs.show_all

Gtk.main