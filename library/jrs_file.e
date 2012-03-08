note

	description:

		"Takes a single file name as argument"

	library: "John Resig Shell library"
	author: "Berend de Boer <berend@pobox.com>"
	copyright: "Copyright (c) 2010, Berend de Boer"
	license: "MIT License (see LICENSE)"


class

	JRS_FILE


inherit

	JRS_BASE


feature -- Command

	file (a_file_name: STRING): JRS_STREAM_LINES_ITERATOR
		require
			readable: is_regular_file (a_file_name)
		local
			my_file: STDC_TEXT_FILE
		do
			create my_file.make (a_file_name)
			create Result.make_from_array (<<my_file>>)
		end


end
