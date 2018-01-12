note

	description:

		"Given string, iterate over its lines."

	library: "John Resig Shell library"
	author: "Berend de Boer <berend@pobox.com>"
	copyright: "Copyright (c) 2017, Berend de Boer"
	license: "MIT License (see LICENSE)"


class

	JRS_STRING_ITERATOR


inherit

	JRS_LINES_STREAM_ITERATOR


create

	make,
	make_from_string

convert

	make_from_string ({STRING})


feature {NONE} -- Initialisation

	make_from_string (s: STRING)
		local
			my_stream: KL_STRING_INPUT_STREAM
		do
			create my_stream.make (s)
			make (my_stream)
		end



end
