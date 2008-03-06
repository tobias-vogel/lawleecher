# If you installed the wxruby gem, uncomment the following two lines:
  require 'rubygems'
  gem 'wxruby' # or the name of the gem you installed
 #require "wxruby" # wxruby 0.6.0
 # OR
 require "wx" # wxruby2
 include Wx

 class MinimalApp < App
    def on_init
         Frame.new(nil, -1, "The Bare Minimum").show()
    end
 end

 MinimalApp.new.main_loop