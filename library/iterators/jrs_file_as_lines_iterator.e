note

	description:

		"Turn file into lines."

	library: "John Resig Shell library"
	author: "Berend de Boer <berend@pobox.com>"
	copyright: "Copyright (c) 2015, Berend de Boer"
	license: "MIT License (see LICENSE)"


class

	JRS_FILE_AS_LINES_ITERATOR


inherit

	JRS_TRANSFORMING_ITERATOR [STDC_TEXT_FILE, READABLE_STRING_GENERAL]
		redefine
			start,
			forth
		end

	JRS_LINES_ITERATOR


create

	make


feature -- Access

	last_item: READABLE_STRING_GENERAL
		do
			Result := wrapped_iterator.last_item.last_string
		end


feature -- Movement

	start
		do
			precursor
			read_line_from_file
		end

	forth
		do
			read_line_from_file
		end


feature {NONE} -- Implementation

	read_line_from_file
		do
			if not wrapped_iterator.after then
				if not wrapped_iterator.last_item.end_of_input then
					wrapped_iterator.last_item.read_line
				end
				if wrapped_iterator.last_item.end_of_input then
					wrapped_iterator.forth
					if not wrapped_iterator.after then
						wrapped_iterator.last_item.read_line
					end
				end
			end
		end


end
