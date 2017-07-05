note

	description:

		"Iterate over lines, either returning them all, or returning them as tuples, or including/excluding lines. "

	library: "John Resig Shell library"
	author: "Berend de Boer <berend@pobox.com>"
	copyright: "Copyright (c) 2012, Berend de Boer"
	license: "MIT License (see LICENSE)"


class

	JRS_LINES_OUTPUT_ITERATOR

obsolete "Use JRS_LINES_ITERATOR/JRS_LINES_STREAM_ITERATOR instead."

inherit

	JRS_STRING_ROUTINES

	JRS_RECORD_STATE


create

	make


feature {NONE} -- Make

	make (an_input_iterator: like input_iterator)
		require
			an_input_iterator_not_void: an_input_iterator /= Void
		do
			input_iterator := an_input_iterator
		end


feature -- Access

	input_iterator: JRS_LINES_INPUT_ITERATOR
			-- Input to be transformed/iterated against.

	first_line: like input_iterator.item_for_iteration
			-- First line
		do
			input_iterator.start
			line_number := 1
			Result := last_line
		ensure
			not_void: Result /= Void
		end

	to_integer_64: INTEGER_64
			-- Integer in `first_line'
		require
			is_integer: first_line.out.is_integer_64
		do
			Result := first_line.out.to_integer_64
		end


feature -- Access while iterating in `each'

	last_line: like input_iterator.item_for_iteration
			-- Last line read inside `lines'
		do
			Result := input_iterator.item_for_iteration
		ensure
			not_void: Result /= Void
		end

	line_number: INTEGER
			-- Current line number inside `lines'


feature -- Commands

	each (f: like iterator_anchor)
			-- Call `f' for every line until all ines have been processed
			-- or `f' has returned True.
		local
			stop: BOOLEAN
		do
			from
				input_iterator.start
				line_number := 1
			until
				stop or else input_iterator.after
			loop
				f.call ([Current])
				stop := f.last_result
				if not stop then
					input_iterator.forth
					line_number := line_number + 1
				end
			end
		end

	include (an_rx: READABLE_STRING_GENERAL): JRS_LINES_OUTPUT_ITERATOR
			-- All lines matching regular expression `an_rx'
		require
			valid_regular_expression: is_valid_regex (an_rx)
		do
			create lines.make
			create rx.make
			rx.compile (an_rx.out)
			input_iterator.each (agent (a_line: READABLE_STRING_GENERAL): BOOLEAN
				do
					debug ("jrs")
						print ("include matching: " + a_line + "%N")
					end
					rx.match (a_line.out)
					if rx.has_matched then
						lines.put_last (a_line.twin)
					end
				end)
			create Result.make (create {JRS_LINES_INPUT_ITERATOR}.make_from_linear (lines))
		end

	exclude (an_rx: READABLE_STRING_GENERAL): JRS_LINES_OUTPUT_ITERATOR
			-- All lines not matching regular expression `an_rx'
		require
			valid_regular_expression: is_valid_regex (an_rx)
		do
			create lines.make
			create rx.make
			rx.compile (an_rx.out)
			input_iterator.each (agent (a_line: READABLE_STRING_GENERAL): BOOLEAN
				do
					rx.match (a_line.out)
					if not rx.has_matched then
						lines.put_last (a_line.twin)
					end
				end)
			create Result.make (create {JRS_LINES_INPUT_ITERATOR}.make_from_linear (lines))
		end


feature -- Anchors

	iterator_anchor: FUNCTION [TUPLE[JRS_LINES_OUTPUT_ITERATOR], BOOLEAN]


feature {NONE} -- Implementation

	lines: DS_LINKED_LIST [READABLE_STRING_GENERAL]

	rx: RX_PCRE_REGULAR_EXPRESSION


end
