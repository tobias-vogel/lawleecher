require 'tk'


root = TkRoot.new() { title "(Sc)rolling, (sc)rolling), (sc)rolling..." }



# bar = TkScrollbar.new(root).pack('side'=>'right', 'fill'=>'y')
# list = TkListbox.new(root).pack('side'=>'left', 'fill'=>'both', 'expand'=>true)
# (0..20).each { |i|
#   list.insert('end', i)
# }


br = ["one", "and", "one"].collect { |c|
  TkButton.new(root, "text"=>c)
}
TkGrid.grid(br[0], br[1], br[2], "columnspan"=>2 )

TkButton.new(root, "text"=>"is").grid("columnspan"=>3, "sticky"=>"ew")
TkButton.new(root, "text"=>"two").grid("row"=>1, "column"=>3, "columnspan"=>3)













Tk.mainloop











exit
button = TkButton.new(root){text ",l,l"}.pack




bar2 = TkScrollbar.new(root).pack('side'=>'right', 'fill'=>'y')
bar3 = TkScrollbar.new(root, 'orient'=>'hor').pack('side'=>'bottom', 'fill'=>'x')

text = TkText.new(root, 'wrap'=>'none').pack('side'=>'left','fill'=>'both', 'expand'=>true)


bar2.command(proc { |args|#
  text.yview(*args)
})

text.yscrollcommand(proc { |first, last|
  bar2.set(first, last)
  puts first
  puts last
})


bar3.command(proc { |args|
  text.xview(*args)
})
text.xscrollcommand(proc { |first, last|
  bar3.set(first, last)
})



text.insert 'end', "adashdjkasdjaslhdjklashjkhjkashjk dhasjkhdjkashd jaskdhjkashd jkasldhasjkldhasjkl hdasjkhdasjk hdasjkhdjkashdjkashdjk ashjkdhasjkdhasjk hasjkhdasjkdhasjkh dasjkhdasjkhd jkash djkas\nhdjk asdhasjk dhasjkdhasjkdjkas"



# bar.command(proc { |args|
#   list.yview(*args)
# })
#
# list.yscrollcommand(proc { |first, last|
#   bar.set(first, last)
#   puts first
#   puts last
# })





Tk.mainloop

exit

# list_w = TkListbox.new(frame, 'selectmode' => 'single')
# 
# scroll_bar = TkScrollbar.new(frame,
#                   'command' => proc { |*args| list_w.yview *args })
# 
# scroll_bar.pack('side' => 'left', 'fill' => 'y')
# 
# list_w.yscrollcommand(proc { |first,last|
#                              scroll_bar.set(first,last) })
# 
# 
# exit




root = TkRoot.new
 button = TkButton.new(root) {
 text "Hello, World!"
 command proc {puts "Ich sage Hello!" }
 }
 button.pack

#  label = TkLabel.new(root) {
#  text "abcdefghijklabcdefghijkl\nabcdefghijkl abcdefghijkl abcdefghijkl abcdefghijkl\nabcdefghijkl abcdefghijkl abcdefghijkl abcdefghijkl\nabcdefghijkl abcdefghijkl abcdefghijkl abcdefghijkl\nabcdefghijkl abcdefghijkl abcdefghijkl abcdefghijkl\nabcdefghijkl abcdefghijkl abcdefghijkl abcdefghijkl\nabcdefghijkl abcdefghijkl abcdefghijkl abcdefghijkl\nabcdefghijkl abcdefghijkl abcdefghijkl abcdefghijkl\nabcdefghijkl abcdefghijkl abcdefghijkl abcdefghijkl\nabcdefghijkl abcdefghijkl abcdefghijkl abcdefghijkl\nabcdefghijkl abcdefghijkl abcdefghijkl abcdefghijkl\nabcdefghijkl abcdefghijkl abcdefghijkl abcdefghijkl\nabcdefghijkl abcdefghijkl abcdefghijkl abcdefghijkl\nabcdefghijkl abcdefghijkl abcdefghijkl abcdefghijkl\nabcdefghijkl abcdefghijkl abcdefghijkl abcdefghijkl\nabcdefghijkl abcdefghijkl abcdefghijkl abcdefghijkl\nabcdefghijkl abcdefghijkl abcdefghijkl abcdefghijkl\nabcdefghijkl abcdefghijkl abcdefghijkl abcdefghijkl\nabcdefghijkl abcdefghijkl abcdefghijkl abcdefghijkl\nabcdefghijkl abcdefghijkl abcdefghijkl abcdefghijkl\nabcdefghijkl abcdefghijkl abcdefghijkl abcdefghijkl\nabcdefghijkl abcdefghijkl abcdefghijkl abcdefghijkl\nabcdefghijkl abcdefghijkl abcdefghijkl abcdefghijkl\nabcdefghijkl abcdefghijkl abcdefghijkl abcdefghijkl\nabcdefghijkl abcdefghijkl abcdefghijkl abcdefghijkl\nabcdefghijkl abcdefghijkl abcdefghijkl abcdefghijkl\nabcdefghijkl abcdefghijkl abcdefghijkl abcdefghijkl\nabcdefghijkl abcdefghijkl abcdefghijkl abcdefghijkl\nabcdefghijkl abcdefghijkl abcdefghijkl abcdefghijkl\nabcdefghijkl abcdefghijkl abcdefghijkl abcdefghijkl\nabcdefghijkl abcdefghijkl abcdefghijkl abcdefghijkl\nabcdefghijkl abcdefghijkl abcdefghijkl abcdefghijkl\nabcdefghijkl abcdefghijkl abcdefghijkl abcdefghijkl\nabcdefghijkl abcdefghijkl abcdefghijkl abcdefghijkl\nabcdefghijkl abcdefghijkl abcdefghijkl abcdefghijkl\nabcdefghijkl abcdefghijkl abcdefghijkl abcdefghijkl\nabcdefghijkl abcdefghijkl abcdefghijkl abcdefghijkl\nabcdefghijkl abcdefghijkl abcdefghijkl abcdefghijkl\nabcdefghijkl abcdefghijkl abcdefghijkl abcdefghijkl\nabcdefghijkl abcdefghijkl abcdefghijkl abcdefghijkl\n"
#  }
#  label.pack('side' => 'left', 'padx' => 50, 'pady' => 50)

  textding = TkText.new(root).pack('side' => 'left')
  scrollbar = TkScrollbar.new(root).pack('side' => 'right', 'fill' => 'y')

  scrollbar.command {|args| label.view args}

 #~ listbox = TkListbox.new(root) {
   #~ selectmode 'single'
   #~ pack 'side' => 'left'
#~ }


textding.yscrollcommand {|first, last| scrolbar.set(first,last)}


textding << "kkk"


Tk.mainloop