require 'tk'

root = TkRoot.new()
root.title 'Law Leecher'


text = TkText.new(root, 'wrap' => 'none')
senkrecht = TkScrollbar.new(root)
wagerecht = TkScrollbar.new(root, 'orient'=>'hor')


TkGrid.grid(text, senkrecht)
TkGrid.grid(wagerecht, 'columnspan' => 2, 'ipadx' => '100')


senkrecht.command(proc {|args| text.yview(*args)})
text.yscrollcommand(proc {|first, last| senkrecht.set(first, last)})

wagerecht.command(proc {|args| text.xview(*args)})
text.xscrollcommand(proc {|first, last| wagerecht.set(first, last)})


(1..40).each {|i| text.insert 'end', "#{i}\n"}


button = TkButton.new(root)
button.text = 'mehr'
button.command(proc {text.insert 'end', "\nmehr"})
button.grid

Tk.mainloop