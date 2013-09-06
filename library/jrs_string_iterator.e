note

	description:

		"Iterates over a set of strings. Can turn them into various things like files as well."

	library: "John Resig Shell library"
	author: "Berend de Boer <berend@pobox.com>"
	copyright: "Copyright (c) 2012, Berend de Boer"
	license: "MIT License (see LICENSE)"


class

	JRS_STRING_ITERATOR


obsolete "2012-07-25: Please port to JRS_LINES_OUTPUT_ITERATOR."

create

	make


feature {NONE} -- Initialiation

	make (a_set: JRS_STRING_SET)
		require
			a_set_not_void: a_set /= Void
		do
			set := a_set
		end


feature -- Access

	set: JRS_STRING_SET
			-- Entire set.


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

	files: JRS_FILES_OUTPUT_ITERATOR
			-- String as set of text files
		do
			create Result.make (set)
		end

	lines (f: like {JRS_LINES_OUTPUT_ITERATOR}.iterator_anchor)
			-- Attempt to open every file in `set', and if it can be
			-- read, iterate over its line. Ignore files that cannot be read.
			-- Not returning a set as this could drastically increase
			-- memory consumption.
		obsolete	"2013-07-25: use `files'.`lines' to first switch to a set of text files and returning its lines."
		require
			callback_not_void: f /= Void
		do
			files.lines (f)
		end


feature -- Signatures

	each_iterator: FUNCTION [ANY, TUPLE[READABLE_STRING_GENERAL], BOOLEAN]


invariant

	set_not_void: set /= Void

end
