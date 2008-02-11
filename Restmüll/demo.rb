def exportieren
    20.times {puts "exportieren..."}
end


require 'tk'
#require 'rubyscript2exe'

mainWindow = TkRoot.new do
    title 'Law Leecher'
end

label = TkLabel.new(mainWindow) do
    text 'Hello, World!'
    pack {padx 15 ; pady 15; side 'left'}
end

button = TkButton.new(mainWindow) do
    text "Export starten"
    command proc {exportieren}
end
button.pack

mainWindow.bind('ButtonRelease-1') {
    puts "losgelassen"
}

# button.bind('ButtonClick-1') {
#     exportieren
# }

puts 'nanu'
#exit if RUBYSCRIPT2EXE.is_compiling?
Tk.mainloop