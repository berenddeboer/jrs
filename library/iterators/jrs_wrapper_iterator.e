note

	description:

		"Iterates over another iterator"

	library: "John Resig Shell library"
	author: "Berend de Boer <berend@pobox.com>"
	copyright: "Copyright (c) 2015, Berend de Boer"
	license: "MIT License (see LICENSE)"


class

	JRS_WRAPPER_ITERATOR


inherit

	JRS_TRANSFORMING_ITERATOR [READABLE_STRING_GENERAL, READABLE_STRING_GENERAL]


feature -- Access

	last_item: READABLE_STRING_GENERAL
		do
			Result := wrapped_iterator.last_item
		end

end
