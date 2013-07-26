note

	description:

		"Base class for iteration over classes of type G"

	library: "John Resig Shell library"
	author: "Berend de Boer <berend@pobox.com>"
	copyright: "Copyright (c) 2010, Berend de Boer"
	license: "MIT License (see LICENSE)"


deferred class

	JRS_ITERATOR [G]


feature -- Basic

	each (f: FUNCTION [ANY, TUPLE[G], BOOLEAN])
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
				f.call ([last_item])
				stop := f.last_result
				forth
			end
		end


feature -- Status

	after: BOOLEAN
		deferred
		end


feature -- Access

	last_item: G
		deferred
		end


feature -- Movement

	start
		require
			not_after: not after
		deferred
		ensure
			last_item_not_void: not after implies last_item /= Void
		end

	forth
		require
			not_after: not after
		deferred
		end

end
