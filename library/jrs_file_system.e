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
			-- Uses real uid, not effective, so take care when running setuid.
		require
			is_valid_directory_name: is_valid_directory_name (a_directory)
		do
			Result := fs.is_directory (a_directory)
		end

	is_regular_file (a_file_name: READABLE_STRING_GENERAL): BOOLEAN
			-- Uses real uid, not effective, so take care when running setuid.
		do
			Result := a_file_name /= Void and then fs.is_regular_file (a_file_name.out)
		end

	is_valid_directory_name (a_directory: STRING): BOOLEAN
			-- Uses real uid, not effective, so take care when running setuid.
		do
			Result := a_directory /= Void and then not a_directory.is_empty
		ensure
			definition: Result = (a_directory /= Void and then not a_directory.is_empty)
		end

	files_exist (a_set: JRS_STRING_SET): BOOLEAN
			-- Do any of these files exist?
		require
			set_not_void: a_set /= Void
		do
			Result := not ls (a_set).linear.is_empty
		end

feature -- Iteration

	if_file (a_name: READABLE_STRING_GENERAL): JRS_LINES_ITERATOR
			-- Include `a_name' in set if it is an existing file.
		require
			name_not_empty: a_name /= Void and then not a_name.is_empty
		local
			set: DS_LINKED_LIST [READABLE_STRING_GENERAL]
		do
			create set.make
			if is_regular_file (a_name) then
				set.put_last (a_name)
			end
			create {JRS_LINES_LINEAR_ITERATOR} Result.make (set)
		ensure
			not_void: Result /= Void
		end

	ls (a_set: JRS_STRING_SET): JRS_LINES_LINEAR_ITERATOR
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
				create path.make_from_raw_string (a_set.item_for_iteration.out)
				path.parse (Void)

					check attached path.basename end
				if attached path.basename as basename then
					debug ("jrs")
						print ("MATCHING " + basename + "%N")
					end
					rx_rx.match (basename)
					if rx_rx.has_matched then
						-- If path is a regular expression, we need to iterate
						-- the directory
						debug ("jrs")
							print ("PATH IS A REGULAR EXPRESSION%N")
						end
						rx.compile (basename)
						if rx.is_compiled then
							if attached path.directory as d and then not d.is_empty then
								dir_path := d
								dir_prefix := d + once "/"
							else
								dir_path := once "."
								dir_prefix := once ""
							end
							debug ("jrs")
								print ("PATH EXPRESSION COMPILES, BROWSING '" + dir_path + "'%N")
							end
							-- TODO: handle case where browse fails?
							-- Now we simply ignore them.
							dir := fs.browse_directory (dir_path)
							dir.set_continue_on_error
							dir.errno.clear_all
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
									debug ("jrs")
										print ("  FOUND " + dir.item + "%N")
									end
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
				end
				rx_rx.wipe_out
				a_set.forth
			end
			debug ("jrs")
				print ("FOUND " + found_files.count.out + " FILES%N")
			end
			create {JRS_LINES_LINEAR_ITERATOR} Result.make (found_files)
		end


feature -- Commands

	cd (a_directory: STRING)
		require
			directory_exists: is_directory (a_directory)
		do
			fs.change_directory (a_directory)
		end


feature {NONE} -- Implementation

	fs: SUS_FILE_SYSTEM
			-- Current system file system
		once
			create Result
		ensure
			not_void: Result /= Void
		end

	rx_rx: RX_PCRE_REGULAR_EXPRESSION
			-- Match to test if a string contains regular expression characters
		once
			create Result.make
			Result.compile ("(^|[^\\])[\.\?\*+\(\[^$]")
		ensure
			compiled: Result.is_compiled
		end

	unescape (s: READABLE_STRING_GENERAL): READABLE_STRING_GENERAL
			-- Remove '\' escape character from `s's
		require
			s_not_void: s /= Void
		local
			t: STRING
		do
			t := s.out
			t.replace_substring_all (once "\", once "")
			Result := t
		ensure
			not_void: Result /= Void
		end

end
