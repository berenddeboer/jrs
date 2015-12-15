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

	each (f: FUNCTION [ANY, TUPLE[JRS_ITERATOR [G]], BOOLEAN])
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
				f.call ([Current])
				stop := f.last_result
				forth
			end
		end


feature -- Status

	after: BOOLEAN
		deferred
		end


feature -- Access

	last_item: detachable G
			-- Current item if applicable
		require
			not_after: not after
		deferred
		end


feature -- Movement

	start
		require
			not_after: not after
		deferred
		end

	forth
		require
			not_after: not after
		deferred
		end

end
