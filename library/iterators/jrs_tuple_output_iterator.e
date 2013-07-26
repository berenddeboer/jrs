note

	description:

		"Iterator over DS_LINEARs that contain TUPLEs"

	library: "John Resig Shell library"
	author: "Berend de Boer <berend@pobox.com>"
	copyright: "Copyright (c) 2012, Berend de Boer"
	license: "MIT License (see LICENSE)"


class

	JRS_TUPLE_OUTPUT_ITERATOR


inherit

	JRS_ITERATOR [TUPLE]


create
	make


feature {NONE} -- Initialisation

	make (a_tuples: like tuples)
		require
			tuples_not_void: a_tuples /= Void
		do
			tuples := a_tuples
		end


feature -- Access

	tuples: DS_LINEAR [TUPLE]


feature -- Status

	after: BOOLEAN
		do
			Result := tuples.after
		end


feature -- Access

	last_item: TUPLE
		do
			Result := tuples.item_for_iteration
		end


feature -- Movement

	start
		do
			tuples.start
		end

	forth
		do
			tuples.forth
		end


invariant

	tuples_not_void: tuples /= Void

end
