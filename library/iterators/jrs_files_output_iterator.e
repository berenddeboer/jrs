note

	description:

		"Turn string into text files."

	library: "John Resig Shell library"
	author: "Berend de Boer <berend@pobox.com>"
	copyright: "Copyright (c) 2013, Berend de Boer"
	license: "MIT License (see LICENSE)"


class

	JRS_FILES_OUTPUT_ITERATOR


create

	make


feature {NONE} -- Make

	make (a_set: like set)
		require
			a_set_not_void: a_set /= Void
		do
			set := a_set
		end


feature -- Access

	item_for_iteration: like file_anchor
		do
			Result := set.item_for_iteration
		end

	set: JRS_FILE_SET
			-- All files.


feature -- Commands

	each (f: like each_iterator): like Current
			-- Iterate over all files in this set.
		require
			callback_not_void: f /= Void
		local
			stop: BOOLEAN
			files: JRS_FILE_SET
		do
			create files.make
			from
				set.start
			until
				stop or else set.after
			loop
				f.call ([set.item_for_iteration])
				stop := f.last_result
				if not stop then
					files.put_last (set.item_for_iteration)
					set.forth
				end
			end
			create Result.make (files)
		end

	lines (f: like {JRS_LINES_OUTPUT_ITERATOR}.iterator_anchor)
			-- Attempt to open every file in `set', and if it can be
			-- read, iterate over its line. Ignore files that cannot be read.
			-- Not returning a set as this could drastically increase
			-- memory consumption.
		require
			callback_not_void: f /= Void
		local
			stop: BOOLEAN
			text: STDC_TEXT_FILE
			input: JRS_LINES_INPUT_ITERATOR
			iterator: JRS_LINES_OUTPUT_ITERATOR
		do
			from
				set.start
			until
				stop or else set.after
			loop
				text := set.item_for_iteration
				if not text.is_open then
					text.open_read (text.name)
				end
				if text.is_open_read then
					create input.make_from_stream (text)
					create iterator.make (input)
					iterator.each (f)
					text.close
				end
				set.forth
			end
		end

feature -- Signatures

	each_iterator: FUNCTION [ANY, TUPLE[STDC_TEXT_FILE], BOOLEAN]

	file_anchor: STDC_TEXT_FILE


end
