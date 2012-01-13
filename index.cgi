#!/usr/bin/env ruby

require 'cgi'

require 'rubygems'
require 'hpricot'

load 'supermarket.rb'
load 'google_static.rb'

def main()
supermarket = SuperMarket::SuperMarketApi.new

puts "<html><head><title>SuperMarket Mashup API example</title>"
puts "<link href=\"styles.css\" rel=\"stylesheet\" type=\"text/css\"></head><body>"

states = Hpricot.XML(supermarket.all_us_states())
state_list = Array.new
(states/"State").each { |state|
	s = (state).innerHTML
	state_list.push(s)
}

puts '<div class="content">'
puts '<div class="left">'

puts '<form name="store" method="POST" action="index.cgi">'

if @cgi.params.empty? || !@cgi.params['flush_values'].empty?
	puts '<h3>Select the state</h3>'
	puts '<select name="state" onchange="this.form.submit()">'
		state_list.each { |s|
			puts "<option value=\"#{s}\">#{s}</option>"
		}
	puts '</select><br />'
	puts '<input type="submit" value="Submit"/>'
else
	selected_state = @cgi.params['state']

	puts "<input type=\"hidden\" name=\"state\" value=\"#{selected_state}\" />"
	puts "<h3>Selected: </h3><br />"
	puts "State: #{selected_state}<br/>"
	
	if @cgi.params['city'].empty?
		cities = Hpricot.XML(supermarket.cities_by_state("#{selected_state}"))
		city_list = Array.new
		(cities/"City").each{ |city|
			c = (city).innerHTML
			city_list.push(c)
		}
		puts '<h3>Select the city</h3>'
		puts '<select name="city" onchange="this.form.submit()">'
			city_list.each { |c|
				puts "<option value=\"#{c}\">#{c}</option>"
			}
		puts '</select><br />'
		puts '<input type="submit" value="Submit"/>'
	else
		selected_city = @cgi.params['city']
		puts "<input type=\"hidden\" name=\"city\" value=\"#{selected_city}\"/>"
		puts "City: #{selected_city} <br />"
		
		if @cgi.params['store'].empty?
			stores = Hpricot.XML(supermarket.stores_by_citystate("#{selected_city}","#{selected_state}"))
			store_list = Array.new

			(stores/"Store").each { |store|
				storeid=(store/"StoreId").innerHTML
				storename=(store/"Storename").innerHTML
				address=(store/"Address").innerHTML
				city=(store/"City").innerHTML
				state=(store/"State").innerHTML
				phone=(store/"Phone").innerHTML
				zip=(store/"Zip").innerHTML
	
				shop = SuperMarket::Shop.new(storeid, storename, address, city, state, phone, zip)
				store_list.push(shop)
			}

			puts '<h3>Select store</h3>'
			puts '<select name="store" onchange="this.form.submit()">'
				store_list.each { |s|
					puts "<option value=\"#{s.id}|#{s.name}|#{s.address}|#{s.phone}|#{s.zip}\">#{s.name}|#{s.address}</option>"
				}
			puts '</select><br />'
			puts '<input type="submit" value="Submit"/>'
		else
			selected_store = @cgi.params['store']
			puts "<input type=\"hidden\" name=\"store\" value=\"#{selected_store}\"/>"
			store_string = selected_store.to_s.split("|").reverse
			storeid 	=store_string.pop
			name 		=store_string.pop
			address 	=store_string.pop
			phone 		=store_string.pop
			zip		=store_string.pop

			map = GoogleStatic::Map.new("#{address},#{selected_city},#{selected_state}")

			puts "Store: <br />"
			puts "Name: #{name} <br />"	
			puts "Address: #{address} <br />"
			puts "Phone: #{phone} <br />"
			puts "Zip: #{zip} <br />"
			puts "Map: <br />"
			puts "<img src=\"#{map.generate_map_url}\" title alt /><br />"
			if !@cgi.params['show_submit'].empty?
				puts '<input type="submit" value="Back"/>'
			end
			
			puts '</div>' # .left
			puts '<div class="right">'
				puts "<input type=\"hidden\" name=\"store_id\" value=\"#{storeid}\"/>"
			if @cgi.params['product_query'].empty?
				puts "<input type=\"hidden\" name=\"show_submit\" value=\"false\"/>"
				puts "Please, input product name you are looking for <br />"
				puts "<input type='text' name='product_query' value='' size='100'/><br />"
				if @cgi.params['show_submit'].empty?
					puts '<input type="submit" value="Submit"/>'
				end
			else
				product_query = @cgi.params['product_query']
				
				product = Hpricot.XML(supermarket.search_foritem("#{storeid}","#{CGI::escape(product_query.to_s)}"))
				product_list = Array.new

				(product/"Product").each { |p|
					id=(p/"ItemID").innerHTML
					name=(p/"Itemname").innerHTML
					description=(p/"ItemDescription").innerHTML
					category=(p/"ItemCategory").innerHTML
					image=(p/"ItemImage").innerHTML
					aisle=(p/"AisleNumber").innerHTML
	
					item = SuperMarket::Product.new(id, name, description, category, image, aisle)
					product_list.push(item)
				}
				
				product_list.each { |product_item|
				puts '<table border="1" class="product">'
					puts "<tr><th class='key'>Product</th><th>#{product_item.name}</th></tr>"
					puts "<tr><td class='key'>ID</td><td>#{product_item.id}</td></td>"
					puts "<tr><td class='key'>Description</td><td>#{product_item.description}</td></td>"
					puts "<tr><td class='key'>Category</td><td>#{product_item.category}</td></td>"
					puts "<tr><td class='key'>Aisle No.</td><td>#{product_item.aisle}</td></td>"
					puts "<tr><td class='key'>Image</td><td><img src=\"#{product_item.image}\" title alt /></td></td>"
				puts '</table>'
				}
				puts "<input type=\"hidden\" name=\"flush_values\" value=\"true\"/>"
				
			end
			puts '</div>' # .right
		end
	end	
end

puts '</form>'
puts '</div>' # .content
puts "</body></html>"

end #main

@cgi = CGI.new()
puts @cgi.header

main
