require 'tk'
 root = TkRoot.new
 button = TkButton.new(root) {
 text "Hello, World!"
 command proc {puts "Ich sage Hello!" }
 }
 button.pack
 Tk.mainloop
