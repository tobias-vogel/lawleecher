################################################################################
# This program/software is provided under the BSD license. (3-clause BSD)      #
# You may modify the program and distribute it, but you have to name the       #
# original author:                                                             #
# Tobias Vogel (tobias@vogel.name)                                             #
################################################################################

require 'core'
require 'g_u_i.rb'

core = Core.new
core.addGuiPointer(GUI.new(core))
fetcher = Fetcher.new(core)

lawsToDebug = [129988]

results, processStepNames = fetcher.retrieveLawContents(lawsToDebug)

#10000.times {results << results.first}

Saver.new(core).save(results, processStepNames, "c:\\export.csv")