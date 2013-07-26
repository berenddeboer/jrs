note

	description:

		"Set of strings and conversion from commonly used arguments to it"

	library: "John Resig Shell library"
	author: "Berend de Boer <berend@pobox.com>"
	copyright: "Copyright (c) 2012, Berend de Boer"
	license: "MIT License (see LICENSE)"


class

	JRS_STRING_SET


inherit

	DS_HASH_SET [READABLE_STRING_GENERAL]


create

	make,
	make_equal,
	make_default,
	make_from_string,
	make_from_array


convert

	make_from_string ({READABLE_STRING_GENERAL}),
	make_from_array ({ARRAY [STRING]})


feature {NONE} -- Initialisation

	make_from_string (s: READABLE_STRING_GENERAL)
		do
			make (1)
			put (s)
		end

	make_from_array (ar: ARRAY [STRING])
		local
			i: INTEGER
		do
			make (ar.count)
			from
				i := ar.lower
			until
				i > ar.upper
			loop
				put (ar.item (i))
				i := i + 1
			variant
				ar.upper - i + 1
			end
		end

end
