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

	last_item: detachable STDC_TEXT_FILE


feature -- Movement

	start
			-- Open first file that can be read.
		do
			precursor
			open_next_readable_file
		ensure then
			file_is_open: not after implies attached last_item as li and then li.is_open_read
		end

	forth
			-- Open next file that can be read.
		do
			precursor
			open_next_readable_file
		ensure then
			file_is_open: not after implies attached last_item as li and then li.is_open_read
		end


feature -- Converting iterators

	as_lines: JRS_FILE_AS_LINES_ITERATOR
		do
			create Result.make (Current)
		end


feature {NONE} -- Implementation

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
					if attached last_item as li then
						found := li.is_open_read
					end
					if not found then
						wrapped_iterator.forth
					end
				end
			else
				close_last_item
			end
		ensure
			file_is_open: not after implies attached last_item as li and then li.is_open_read
		end

	attempt_open_file
		require
			not_after: not wrapped_iterator.after
		local
			ili: like last_item
			n: READABLE_STRING_8
		do
			close_last_item
			if attached wrapped_iterator.last_item as li then
				n := li.out
				create ili.make (n)
				last_item := ili
				ili.set_continue_on_error
				ili.open_read (n)
			end
		ensure
			last_item_not_void: attached last_item
		end

	close_last_item
		do
			if attached last_item as file and then file.is_open then
				file.close
			end
		end


invariant

	all_files_closed_after_reading: after implies not attached last_item as li or else not li.is_open

end
