note

	description:

		"Iterate over rows of database query"

	library: "John Resig Shell library"
	author: "Berend de Boer <berend@pobox.com>"
	copyright: "Copyright (c) 2010, Berend de Boer"
	license: "MIT License (see LICENSE)"


class

	JRS_ROWS_ITERATOR [G -> TUPLE]


inherit

	JRS_TUPLE_ITERATOR [G]


create

	make,
	make_from_array


feature -- Access

	config: JRS_ROWS_ITERATOR_DATA

feature -- Command

	rows (f: FUNCTION [ANY, TUPLE[], BOOLEAN])
		do
			create config.make (Current)
			each (agent do_row (f))
		end


feature {NONE} -- Per item command

	do_row (f: FUNCTION [ANY, TUPLE[], BOOLEAN]): BOOLEAN
		require
			f_not_void: f /= Void
		local
			t: like item_for_iteration
		do
			t := item_for_iteration
			f.call ([t, config])
		end


end
