note

	description:

		"Short description of the class"

	library: "John Resig Shell library"
	author: "Berend de Boer <berend@pobox.com>"
	copyright: "Copyright (c) 2012, Berend de Boer"
	license: "MIT License (see LICENSE)"


class

	JRS_STRING_ITERATOR


create

	make


feature {NONE} -- Initialiation

	make (a_set: JRS_STRING_SET)
		do
			set := a_set
		end


feature -- Access

	set: JRS_STRING_SET


feature -- Iterations

	each (f: like each_iterator)
		require
			callback_not_void: f /= Void
		local
			stop: BOOLEAN
		do
			from
				set.start
			until
				stop or else set.after
			loop
				f.call ([set.item_for_iteration])
				stop := f.last_result
				set.forth
			end
		end

	lines (f: like lines_iterator)
			-- Attempt to open every file in `set', and if it can be
			-- read, iterate over its line. Ignore files that cannot be read.
		require
			callback_not_void: f /= Void
		local
			stop: BOOLEAN
			text: STDC_TEXT_FILE
		do
			from
				set.start
			until
				stop or else set.after
			loop
				create text.make (set.item_for_iteration)
				text.set_continue_on_error
				text.open_read (set.item_for_iteration)
				if text.is_open_read then
					create text.open_read (set.item_for_iteration)
					from
						text.read_line
					until
						stop or else text.end_of_input
					loop
						f.call ([set.item_for_iteration, text.last_string])
						stop := f.last_result
						text.read_line
					end
					text.close
				end
				set.forth
			end
		end


feature -- Signatures

	each_iterator: FUNCTION [ANY, TUPLE[STRING], BOOLEAN]

	lines_iterator: FUNCTION [ANY, TUPLE[STRING, STRING], BOOLEAN]


feature {NONE} -- Implementation

	fs: SUS_FILE_SYSTEM
		once
			create Result
		ensure
			not_void: Result /= Void
		end


end
