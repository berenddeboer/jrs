note

	description:

		"Iterates over another iterator, transforming the input type to the output type"

	library: "John Resig Shell library"
	author: "Berend de Boer <berend@pobox.com>"
	copyright: "Copyright (c) 2015, Berend de Boer"
	license: "MIT License (see LICENSE)"


deferred class

	JRS_TRANSFORMING_ITERATOR [FROM_TYPE, TO_TYPE]


inherit

	JRS_ITERATOR [TO_TYPE]


feature {NONE} -- Initialisation

	make (an_iterator: like wrapped_iterator)
		require
			an_iterator_not_void: an_iterator /= Void
		do
			wrapped_iterator := an_iterator
		end


feature -- Status

	after: BOOLEAN
		do
			Result := wrapped_iterator.after
		end


feature -- Access

	wrapped_iterator: JRS_ITERATOR [FROM_TYPE]
			-- The wrapped iterator


feature -- Movement

	start
		do
			wrapped_iterator.start
		end

	forth
		do
			wrapped_iterator.forth
		end


invariant

	wrapped_iterator_not_void: wrapped_iterator /= Void

end
