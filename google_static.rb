#!/usr/bin/env ruby
require 'cgi'

module GoogleStatic

	class Map
		attr		:baseurl
		attr		:apiendpoint
		attr		:sensor
		attr		:address
		attr_accessor	:size
		attr_accessor	:zoom

		def initialize(address)
			@baseurl	='http://maps.googleapis.com'
			@apiendpoint	='maps/api/staticmap?'
			@sensor		='false'
			@address	=encode(address)
			@size		='512x512'
			@zoom		='14'
		end

		def generate_map_url()
			map_url = "#{@baseurl}/#{@apiendpoint}/center=#{@address}&markers=#{@address}&zoom=#{@zoom}&size=#{@size}&sensor=#{@sensor}"
			return map_url
		end
		
		def encode(string)
			return !string.empty? ? CGI::escape(string) : ''
		end

	end # Map
end # GoogleStatic
