# the programm returns wrong or no information, if
# - the website was changed
# - there are more than 10000 laws per type
# - there are laws which started before 1.1.1960 or which end after 23.12.2069
#   or which end after 23.12.2059 if they started between 1.1.1960 1.1.1070
# - entries contain a # in the text

require 'g_u_i.rb'
require 'core.rb'


theCore = Core.new
gui = GUI.new(theCore)
theCore.addGuiPointer gui

gui.run