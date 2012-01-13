#!/usr/bin/env ruby

# Module
# 	SuperMarket
#
# Description
# 	Realises calls to API of the SuperMarketApi.com service
#
# Example
#
# supermarket = SuperMarketApi.new
# puts supermarket.search_by_productname('Parsley')
# puts supermarket.search_by_itemid('123')
# puts supermarket.all_us_states()
# puts supermarket.cities_by_state('CO')
# puts supermarket.get_groceries('Apple')
# puts supermarket.return_storesbyname('Safeway')
# puts supermarket.search_foritem('123456','Apple')
# puts supermarket.stores_by_citystate('Washington','CO')
# puts supermarket.stores_by_zip('95130')

require 'net/http'
require 'cgi'

load "config.rb"

module SuperMarket

class SuperMarketApi

	attr :access_key
	attr :base_url

	def initialize()
		@access_key	=SuperMarketApiConfig::KEY
		@base_url	='www.supermarketapi.com'
	end

	def show_key()
		puts @access_key
	end

	def request(request_url)
		response = nil
		if ( request_url.nil? || request_url.empty?)
			raise 'Error: Request URL is empty!'
		else
			response = Net::HTTP.get("#{@base_url}","#{request_url}")
		end

		if response
			return response
		else
			raise "Unable to create request for #{request_url}"
		end
	end

	def generate_request_url(method, param=nil, param_extra=nil)
		base_url_string = "/api.asmx/#{method}?APIKEY=#{@access_key}"

		if (param)
			param_string = param_extra ? "#{param}""#{param_extra}" : "#{param}"
			return "#{base_url_string}#{param_string}"
		else
			return "#{base_url_string}"
		end
	end

	def generate_param(key,value)
		k = key
		v = value
		return v ? "&#{k}=#{CGI.escape(v)}" : ''
	end

	def search_by_productname(itemname=nil)
		method		='SearchByProductName'
		param_key	='ItemName'
		param_value	=itemname
		param		=nil

		if ( !param_value.nil? || !param_value.empty?)
			param = generate_param(param_key, param_value)
		end

		# Example: http://www.SupermarketAPI.com/api.asmx/SearchByProductName?APIKEY=APIKEY&ItemName=Parsley
		
		request_url = generate_request_url(method, param, nil)
		return request(request_url)
	end

	def search_by_itemid(itemid)
		method		='SearchByItemID'
		param_key	='ItemId'
		param_value	=itemid
		param		=nil

		if ( !param_value.nil? || !param_value.empty?)
			param = generate_param(param_key, param_value)
		end

		# Example: http://www.SupermarketAPI.com/api.asmx/SearchByItemID?APIKEY=APIKEY&ItemId=12345
		request_url = generate_request_url(method, param, nil)
		return request(request_url)
	end
	
	def all_us_states()
		method		='AllUSStates'

		# Example: http://www.SupermarketAPI.com/api.asmx/AllUSStates
		request_url = generate_request_url(method, nil, nil)
		return request(request_url)
	end

	def cities_by_state(state)
		method		='CitiesByState'
		param_key	='SelectedState'
		param_value	=state
		param		=nil

		if ( !param_value.nil? || !param_value.empty?)
			param = generate_param(param_key, param_value)
		end

		# Example: http://www.SupermarketAPI.com/api.asmx/CitiesByState?APIKEY=APIKEY&SelectedState=CA	
		request_url = generate_request_url(method, param, nil)
		return request(request_url)
	end

	def get_groceries(query)
		method		='GetGroceries'
		param_key	='SearchText'
		param_value	=query
		param		=nil

		if ( !param_value.nil? || !param_value.empty?)
			param = generate_param(param_key, param_value)
		end

		# Example: http://www.SupermarketAPI.com/api.asmx/GetGroceries?APIKEY=APIKEY&SearchText=Apple
		request_url = generate_request_url(method, param, nil)
		return request(request_url)
	end

	def return_storesbyname(storename)
		method		='ReturnStoresByName'
		param_key	='StoreName'
		param_value	=storename
		param		=nil

		if ( !param_value.nil? || !param_value.empty?)
			param = generate_param(param_key, param_value)
		end

		# Example: http://www.SupermarketAPI.com/api.asmx/ReturnStoresByName?APIKEY=APIKEY&StoreName=Safeway
		request_url = generate_request_url(method, param, nil)
		return request(request_url)
	end

	def search_foritem(storename, itemname)
		method		='SearchForItem'
		param1_key	='StoreId'
		param1_value	=storename
		param1		=nil

		param2_key	='ItemName'
		param2_value	=itemname
		param2		=nil

		if ( !param1_value.nil? || !param1_value.empty?)
			param1 = generate_param(param1_key, param1_value)
		end
		if ( !param2_value.nil? || !param2_value.empty?)
			param2 = generate_param(param2_key, param2_value)
		end

		# Example: http://www.SupermarketAPI.com/api.asmx/SearchForItem?APIKEY=APIKEY&StoreId=123456&ItemName=Apple
		request_url = generate_request_url(method, param1, param2)
		return request(request_url)
	end

	def stores_by_citystate(city,state)
		method		='StoresByCityState'
		param1_key	='SelectedCity'
		param1_value	=city
		param1		=nil

		param2_key	='SelectedState'
		param2_value	=state
		param2		=nil

		if ( !param1_value.nil? || !param1_value.empty?)
			param1 = generate_param(param1_key, param1_value)
		end
		if ( !param2_value.nil? || !param2_value.empty?)
			param2 = generate_param(param2_key, param2_value)
		end

		# Example: http://www.SupermarketAPI.com/api.asmx/StoresByCityState?APIKEY=APIKEY&SelectedCity=San Francisco&SelectedState=CA
		request_url = generate_request_url(method, param1, param2)
		return request(request_url)
	end

	def stores_by_zip(zipcode)
		method		='StoresByZip'
		param_key	='ZipCode'
		param_value	=zipcode
		param		=nil

		if ( !param_value.nil? || !param_value.empty?)
			param = generate_param(param_key, param_value)
		end

		# Example: http://www.SupermarketAPI.com/api.asmx/StoresByZip?APIKEY=APIKEY&ZipCode=95130
		request_url = generate_request_url(method, param, nil)
		return request(request_url)
	end
end # class SuperMarketApi

# Query for Shop by given city and state
class Shop
	attr_accessor :id
	attr_accessor :name
	attr_accessor :address
	attr_accessor :city
	attr_accessor :state
	attr_accessor :phone
	attr_accessor :zip

	def initialize(id, name, address, city, state, phone =nil, zip =nil)
		@id		= id
		@name		= name
		@address	= address
		@city		= city
		@state		= state
		@phone		= phone
		@zip		= zip
	end

end # class shop

# Query for product list in specific shop by given shop id and product name
class Product
	attr_accessor :id
	attr_accessor :name
	attr_accessor :description
	attr_accessor :category
	attr_accessor :image
	attr_accessor :aisle

	def initialize(id, name, description, category, image, aisle)
		@id		= id
		@name		= name
		@description	= description
		@category	= category
		@image		= image
		@aisle		= aisle
	end
	
end # class Product

end # module SuperMarket

