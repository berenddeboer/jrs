note

	description:

		"Base class offering JRS functionality."

	library: "John Resig Shell library"
	author: "Berend de Boer <berend@pobox.com>"
	copyright: "Copyright (c) 2010, Berend de Boer"
	license: "MIT License (see LICENSE)"


class

	JRS


inherit

	SUS_SYSTEM
		rename
			echo as terminal_echo
		end

	JRS_EXEC
		rename
			echo as terminal_echo
		end


inherit {NONE}

	JRS_STRING_ROUTINES

	JRS_DATE_TIME_ROUTINES

	JRS_RESOLVER


feature -- Utilities

	echo (s: STRING): JRS_LINES_ITERATOR
		do
			create {JRS_STRING_ITERATOR} Result.make_from_string (s)
		end


end
