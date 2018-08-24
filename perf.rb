require "bundler/setup"
require "currency_coder"
require "benchmark/ips"
require "rblineprof"

cc = CurrencyCoder.new

names = %w(osamu mayoto kurotaki putchom antipop jitsuzon)

Benchmark.ips do |x|
  x.report('original') { names.each { |name| cc.as_currency_code(name) } }
  x.report('improve')  { names.each { |name| cc.as_currency_code2(name) } }
  x.compare!
end

GC.start

name = "osamu"
profile = lineprof(/./) do
  1000.times do
    cc.as_currency_code(name)
    cc.as_currency_code2(name)
  end
end

file = profile.keys.first
file = '/home/sei/src/github.com/pepabo/currency_coder/lib/currency_coder.rb'

File.readlines(file).each_with_index do |line, num|
  wall, cpu, calls, allocations = profile[file][num + 1]

  if wall&.>(0) || cpu&.>(0) || calls&.>(0)
    printf(
      "% 5.1fms + % 6.1fms (% 4d) | %s",
      cpu / 1000.0,
      (wall - cpu) / 1000.0,
      calls,
      line
    )
  else
    printf "                          | %s", line
  end
end
