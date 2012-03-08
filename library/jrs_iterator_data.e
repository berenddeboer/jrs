note

	description:

		"Short description of the class"

	library: "John Resig Shell library"
	author: "Berend de Boer <berend@pobox.com>"
	copyright: "Copyright (c) 2011, Berend de Boer"
	license: "MIT License (see LICENSE)"


class

	JRS_ITERATOR_DATA [G]


create

	make


feature {NONE} -- Initialisation

	make (an_iterator: like iterator)
		do
			iterator := an_iterator
		end


feature -- Access

	iterator: G

end
