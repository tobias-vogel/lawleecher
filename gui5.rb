require 'gtk2'

#widgets
window = Gtk::Window.new
text = Gtk::TextView.new
adj = Gtk::Adjustment.new(10, 1, 1000, 1, 5, 10 )
vscroller = Gtk::VScrollbar.new(adj)
table = Gtk::Table.new(2, 2, false)
button = Gtk::Button.new('button')

#connections
window.signal_connect("delete_event") {Gtk::main_quit}
button.signal_connect("clicked") {puts text.buffer.text}


#attributes
#table.set_column_spacing(1, 100)
vscroller.set_update_policy(Gtk::UPDATE_CONTINUOUS)
vscroller.adjustment.value= 10

window.set_resizable false
#window.set_default_size 600, 600
window.set_width_request 500
window.set_height_request 500


puts text.buffer


#packing

#table.attach_defaults(text, 0, 1, 0, 1)
table.attach(text, 0, 1, 0, 1, Gtk::FILL, Gtk::FILL, 1, 1)
table.attach_defaults(vscroller, 1, 2, 0, 1)
table.attach_defaults(button, 0, 2, 1, 2)
window.add(table)


#rest
window.show_all
Gtk.main