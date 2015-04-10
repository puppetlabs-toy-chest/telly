require 'rubygems' unless defined?(Gem)


module Telly

  %w( test_rail_teller test_rail version arg_parser ).each do |lib|
    begin
      require "telly/#{lib}"
    rescue LoadError
      require File.expand_path(File.join(File.dirname(__FILE__), 'telly', lib))
    end
  end

end
