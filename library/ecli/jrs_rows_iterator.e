note

	description:

		"Iterate over rows of database query"

	library: "John Resig Shell library"
	author: "Berend de Boer <berend@pobox.com>"
	copyright: "Copyright (c) 2010, Berend de Boer"
	license: "MIT License (see LICENSE)"


class

	JRS_ROWS_ITERATOR [G -> TUPLE]


create

	make


feature {NONE} -- Initialisation

	make (a_stmt: JRS_ECLI_STATEMENT; a_row_format: G)
		require
			not_void: a_stmt /= Void
			a_row_format_not_void: a_row_format /= Void
		do
			stmt := a_stmt
			row_format := a_row_format
			create config.make (Current)
		end


feature -- Access

	config: JRS_ROWS_ITERATOR_DATA

	row_format: G

	stmt: JRS_ECLI_STATEMENT


feature -- Command

	rows, each (f: FUNCTION [TUPLE, BOOLEAN])
		local
			stop: BOOLEAN
		do
			if stmt.is_executed and then stmt.has_result_set then
				stmt.tuple_bind (row_format)
				from
					stmt.start
				until
					stop or else stmt.after
				loop
					f.call ([row_format, config])
					stop := f.last_result
					stmt.forth
				end
			end
			stmt.close
		end


end
