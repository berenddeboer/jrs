note

	description:

		"Basic file system commands"

	library: "John Resig Shell library"
	author: "Berend de Boer <berend@pobox.com>"
	copyright: "Copyright (c) 2011-2012, Berend de Boer"
	license: "MIT License (see LICENSE)"


class

	JRS_FILE_SYSTEM


inherit {NONE}

	JRS_STRING_ROUTINES


feature -- Status

	is_directory (a_directory: STRING): BOOLEAN
		require
			is_valid_directory_name: is_valid_directory_name (a_directory)
		do
			Result := fs.is_directory (a_directory)
		end

	is_regular_file (a_file_name: STRING): BOOLEAN
		do
			Result := fs.is_regular_file (a_file_name)
		end

	is_valid_directory_name (a_directory: STRING): BOOLEAN
		do
			Result := a_directory /= Void and then not a_directory.is_empty
		ensure
			definition: Result = (a_directory /= Void and then not a_directory.is_empty)
		end


feature -- Iteration

	ls (a_set: JRS_STRING_SET): JRS_STRING_ITERATOR
			-- Non-recursive directory listing. Only files matcing `re'
			-- will be returned.
			-- So things like "dir/.*/.*\.log" won't work (yet)
		require
			set_not_void: a_set /= Void
		local
			found_files: JRS_STRING_SET
			rx: RX_PCRE_REGULAR_EXPRESSION
			dir: EPX_DIRECTORY
			path: EPX_PATH
			dir_path: STRING
			dir_prefix: STRING
		do
			create found_files.make (a_set.count)
			create rx.make
			from
				a_set.start
			until
				a_set.after
			loop
				create path.make_from_raw_string (a_set.item_for_iteration)
				path.parse (Void)

				debug ("jrs")
					print ("MATCHING " + path.basename + "%N")
				end
				rx_rx.match (path.basename)
				if rx_rx.has_matched then
					-- If path is a regular expression, we need to iterate
					-- the directory
					debug ("jrs")
						print ("PATH IS A REGULAR EXPRESSION%N")
					end
					rx.compile (path.basename)
					if rx.is_compiled then
						if path.directory.is_empty then
							dir_path := once "."
							dir_prefix := once ""
						else
							dir_path := path.directory
							dir_prefix := path.directory + once "/"
						end
						-- TODO: handle case where browse fails?
						dir := fs.browse_directory (dir_path)
						dir.set_continue_on_error
						from
							dir.start
						until
							not dir.errno.is_ok or else
							dir.after
						loop
							-- Never present . and .. entries
							if
								dir.item.count > 2 or else
								(dir.item.count = 1 and dir.item.item (1) /= '.') or else
								(dir.item.count = 2 and not equal (dir.item, once "..")) then
								rx.match (dir.item)
								if rx.has_matched then
									found_files.force (dir_prefix + dir.item)
								end
								rx.wipe_out
							end
							dir.forth
						end
					else
						-- Not a valid regular expression, treat as filename
						found_files.force (unescape (a_set.item_for_iteration))
					end
				else
					-- No need to check directory for this file, but we
					-- should remove escape characters.
					found_files.force (unescape (a_set.item_for_iteration))
				end
				rx_rx.wipe_out
				a_set.forth
			end
			create Result.make (found_files)
		end


feature -- Commands

	cd (a_directory: STRING)
		require
			is_valid_directory_name: is_valid_directory_name (a_directory)
			directory_exists: is_directory (a_directory)
		do
			fs.change_directory (a_directory)
		end


feature {NONE} -- Implementation

	fs: SUS_FILE_SYSTEM
		once
			create Result
		ensure
			not_void: Result /= Void
		end

	rx_rx: RX_PCRE_REGULAR_EXPRESSION
			-- Match to test if a string contains regular expression characters
		once
			create Result.make
			Result.compile ("(^|[^\\])[\.\?\*\(\[]")
		ensure
			compiled: Result.is_compiled
		end

	unescape (s: STRING): STRING
			-- Remove '\' escape character from `s's
		do
			Result := s.twin
			Result.replace_substring_all (once "\", once "")
		end

end
