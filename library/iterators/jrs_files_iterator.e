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
					if attached internal_last_item as ili then
						found := ili.is_open_read
					end
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
		local
			ili: like internal_last_item
		do
			close_internal_last_item
			if attached wrapped_iterator.last_item as li then
				create ili.make (li.out)
				internal_last_item := ili
				ili.set_continue_on_error
				ili.open_read (li.out)
			end
		ensure
			internal_last_item_not_void: attached internal_last_item
		end

	close_internal_last_item
		do
			if attached internal_last_item as file and then file.is_open then
				file.close
			end
		end


invariant

	all_files_closed_after_reading: after implies not attached internal_last_item as li or else not li.is_open

end
