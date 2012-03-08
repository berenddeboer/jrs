indexing

	description:

		"Base class for iteration over classes of type G"

	library: "John Resig Shell library"
	author: "Berend de Boer <berend@pobox.com>"
	copyright: "Copyright (c) 2010, Berend de Boer"
	license: "MIT License (see LICENSE)"


class

	JRS_ITERATOR [G]


inherit

	DS_LINKED_LIST [G]


feature -- Basic

	each (f: FUNCTION [ANY, TUPLE[], BOOLEAN])
		require
			f_not_void: f /= Void
		local
			stop: BOOLEAN
		do
			from
				start
			until
				stop or else
				after
			loop
				f.call ([])
				stop := f.last_result
				forth
			end
		end

end
