require 'gtk2'

window = Gtk::Window.new
window.title = "Table"
window.signal_connect("delete_event") do
    Gtk.main_quit
    false
end
window.border_width = 20

# Erstellt eine 2x2-Tabelle.
table = Gtk::Table.new(2, 2, true)
window.add(table)

[1, 2].each do |i|
    button = Gtk::Button.new("button #{i}")
    button.signal_connect("clicked") do
        puts "Hello again - button #{i} was pressed"
    end
    # Fügt Button 1 in das obere linke Feld der Tabelle ein und
    # Button 2 in das obere rechte Feld.
    table.attach_defaults(button, i - 1, i, 0, 1)
end

button = Gtk::Button.new("Quit")
button.signal_connect("clicked") do
    Gtk::main_quit
end

# Fügt den Beenden-Button in die beiden unteren Felder der Tabelle ein.
table.attach_defaults(button, 0, 2, 1, 2)

window.show_all
Gtk.main