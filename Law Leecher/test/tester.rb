require 'core'
require 'g_u_i.rb'

core = Core.new
core.addGuiPointer(GUI.new(core))
fetcher = Fetcher.new(core)

lawsToDebug = []

results, processStepNames = fetcher.retrieveLawContents(lawsToDebug)
Saver.new(core).save(results, processStepNames, "c:\\export.csv")