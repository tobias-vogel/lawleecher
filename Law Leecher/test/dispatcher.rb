class Dispatcher
end

puts "huhu, da bin ich"

thread = Thread.new do
  sleep 0.1
  puts "ich bin der thread"
end
puts "thread erstellt"

thread.join

puts "fertig"