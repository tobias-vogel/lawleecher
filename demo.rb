require 'tk'
require 'rubyscript2exe'
root = TkRoot.new { title "Ex1" }
TkLabel.new(root) do
  text 'Hello, World!'
  pack { padx 15 ; pady 15; side 'left' }
end
puts 'nanu'
exit if RUBYSCRIPT2EXE.is_compiling?
Tk.mainloop