note

	description:

		"Iterate over lines of a given file"

	library: "John Resig Shell library"
	author: "Berend de Boer <berend@pobox.com>"
	copyright: "Copyright (c) 2010, Berend de Boer"
	license: "MIT License (see LICENSE)"


class

	JRS_STREAM_LINES_ITERATOR


inherit

	JRS_STREAM_ITERATOR


create

	make,
	make_from_array


feature -- Access

	line_number: INTEGER
			-- Number of lines read so far


feature -- Command

	lines (f: FUNCTION [ANY, TUPLE[], BOOLEAN])
		do
			each (agent do_lines (f))
		end

	non_comment_lines (f: FUNCTION [ANY, TUPLE[], BOOLEAN])
		do
			each (agent do_lines (f))
		end


feature {NONE} -- Per item command

	do_lines (f: FUNCTION [ANY, TUPLE[], BOOLEAN]): BOOLEAN
		require
			f_not_void: f /= Void
		do
			if not item_for_iteration.is_open then
				item_for_iteration.open_read (item_for_iteration.name)
			end
			from
				item_for_iteration.read_line
				line_number := 0
			until
				Result or else
				item_for_iteration.end_of_input
			loop
				line_number := line_number + 1
				f.call ([Current, item_for_iteration.last_string])
				Result := f.last_result
				item_for_iteration.read_line
			end
			item_for_iteration.close
		end


end
