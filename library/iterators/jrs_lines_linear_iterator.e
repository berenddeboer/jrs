note

	description:

		"Iterate over lines"

	library: "John Resig Shell library"
	author: "Berend de Boer <berend@pobox.com>"
	copyright: "Copyright (c) 2012, Berend de Boer"
	license: "MIT License (see LICENSE)"


class

	JRS_LINES_LINEAR_ITERATOR


inherit

	JRS_LINES_ITERATOR


create

	make


feature {NONE} -- Initialisation

	make (a_linear: attached like linear)
		require
			linear_not_void: a_linear /= Void
		do
			linear := a_linear
		end


feature -- Access

	linear: DS_LINEAR [READABLE_STRING_GENERAL]


feature -- Status

	after: BOOLEAN
		do
			Result := linear.after
		end


feature -- Access

	last_item: READABLE_STRING_GENERAL
		do
			Result := linear.item_for_iteration
		end


feature -- Movement

	start
		do
			linear.start
		end

	forth
		do
			linear.forth
		end


invariant

	linear_not_void: linear /= Void

end
