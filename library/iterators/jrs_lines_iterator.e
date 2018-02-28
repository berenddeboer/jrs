note

	description:

		"Base class for an interator over lines (strings)."

	library: "John Resig Shell library"
	author: "Berend de Boer <berend@pobox.com>"
	copyright: "Copyright (c) 2012, Berend de Boer"
	license: "MIT License (see LICENSE)"


deferred class

	JRS_LINES_ITERATOR


inherit

	JRS_ITERATOR [READABLE_STRING_GENERAL]

	JRS_STRING_ROUTINES
		export
			{NONE} all
			{ANY} is_valid_regex
		end


feature -- Iterators

	include (an_rx: READABLE_STRING_GENERAL): JRS_LINES_ITERATOR
			-- All lines matching regular expression `an_rx'
		require
			valid_regular_expression: is_valid_regex (an_rx)
		do
			create {JRS_MATCH_ITERATOR} Result.make (Current, an_rx, True)
		ensure
			not_void: Result /= Void
		end

	exclude (an_rx: READABLE_STRING_GENERAL): JRS_LINES_ITERATOR
			-- All lines not matching regular expression `an_rx'
		require
			valid_regular_expression: is_valid_regex (an_rx)
		do
			create {JRS_MATCH_ITERATOR} Result.make (Current, an_rx, False)
		ensure
			not_void: Result /= Void
		end


feature -- Converting iterators

	as_files: JRS_FILES_ITERATOR
		do
			create Result.make (Current)
		ensure
			not_void: Result /= Void
		end

	as_tuples (a_tuple_type: TUPLE; a_field_separator: CHARACTER): JRS_TUPLE_ITERATOR [like a_tuple_type]
			-- Tuple iterator matching tuple `a_tuple_type' for every
			-- line, using `field_separator' to split the line into
			-- component
		require
			a_tuple_type_not_void: a_tuple_type /= Void
			field_separator_set: a_field_separator /= '%U'
		do
			create {JRS_TUPLE_ITERATOR [like a_tuple_type]} Result.make (Current, a_tuple_type, a_field_separator)
		ensure
			not_void: Result /= Void
		end

	first_line: READABLE_STRING_GENERAL
			-- First line if exists, else the empty string
		do
			start
			if not after and then attached last_item as s then
				Result := s
			else
				Result := ""
			end
		end

end
