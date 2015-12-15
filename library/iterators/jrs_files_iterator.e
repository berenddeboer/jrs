note

	description:

		"Turn string into text files."

	library: "John Resig Shell library"
	author: "Berend de Boer <berend@pobox.com>"
	copyright: "Copyright (c) 2013 - 2015, Berend de Boer"
	license: "MIT License (see LICENSE)"


class

	JRS_FILES_ITERATOR


inherit

	JRS_TRANSFORMING_ITERATOR [READABLE_STRING_GENERAL, STDC_TEXT_FILE]
		redefine
			start,
			forth
		end


create

	make


feature -- Access

	last_item: STDC_TEXT_FILE
		do
			Result := internal_last_item
		end


feature -- Movement

	start
			-- Open first file that can be read.
		do
			precursor
			open_next_readable_file
		end

	forth
			-- Open next file that can be read.
		do
			precursor
			open_next_readable_file
		end


feature -- Converting iterators

	as_lines: JRS_FILE_AS_LINES_ITERATOR
		do
			create Result.make (Current)
		end


feature {NONE} -- Implementation

	internal_last_item: detachable like last_item

	open_next_readable_file
			-- Find next file that can be read, skip files that cannot be
			-- opened for reading.
		local
			found: BOOLEAN
		do
			if not after then
				from
				until
					after or else found
				loop
					attempt_open_file
					found := internal_last_item.is_open_read
					if not found then
						wrapped_iterator.forth
					end
				end
			else
				close_internal_last_item
			end
		end

	attempt_open_file
		require
			not_after: not wrapped_iterator.after
		do
			close_internal_last_item
			create internal_last_item.make (wrapped_iterator.last_item.out)
			internal_last_item.set_continue_on_error
			internal_last_item.open_read (wrapped_iterator.last_item.out)
		ensure
			internal_last_item_not_void: internal_last_item /= Void
		end

	close_internal_last_item
		do
			if attached internal_last_item as file and then file.is_open then
				file.close
			end
		end


invariant

	all_files_closed_after_reading: after implies internal_last_item = Void or else not internal_last_item.is_open

end
