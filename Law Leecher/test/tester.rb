require 'core'
require 'g_u_i.rb'

class Tester
  def initialize
    a = Fetcher.new.retrieveLawIDs
    if a.size >= 4586 
      puts "success"
    else
      puts "fail"
    end
  end
end


core = Core.new
core.addGuiPointer(GUI.new(core))
fetcher = Fetcher.new(core)

results, processStepNames, thereHaveBeenErrors = fetcher.retrieveLawContents([192222])
Saver.new(core).save(results, ["aaa", "bbb"], "c:\\export.csv")



#puts results.inspect
exit