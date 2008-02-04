require 'g_u_i.rb'
require 'core.rb'


theCore = Core.new
gui = GUI.new(theCore)
theCore.addGuiPointer gui

gui.run