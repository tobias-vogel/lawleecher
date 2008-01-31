require 'gtk2'


def callback(widget)
    puts widget.label
end

button1 = Gtk::Button.new("Button 1")
button2 = Gtk::Button.new("Button 2")
exitButton = Gtk::Button.new("Exit")
window = Gtk::Window.new
box = Gtk::HBox.new(false, 0)


# Connects

button1.signal_connect("clicked") do |w|
    callback(w)
end


button2.signal_connect("clicked") do |w|
    callback(w)
end



window.signal_connect("delete_event") {
    Gtk.main_quit
}


exitButton.signal_connect("clicked") {
    Gtk.main_quit
}


window.border_width = 10
window.title = 'fenstertitel'



# Packen

# box.add(button1)
# box.add(button2)

box.pack_start(button1, true, false, 1)
box.pack_start(button2, true, true, 1)
box.pack_start(exitButton, false, true, 1)

window.add(box)



window.show_all

Gtk.main