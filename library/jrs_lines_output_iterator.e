note

	description:

		"Functions that work against a single line"

	library: "John Resig Shell library"
	author: "Berend de Boer <berend@pobox.com>"
	copyright: "Copyright (c) 2012, Berend de Boer"
	license: "MIT License (see LICENSE)"


class

	JRS_LINES_OUTPUT_ITERATOR


inherit {NONE}

	JRS_STRING_ROUTINES

	JRS_RECORD_STATE


create

	make


feature {NONE} -- Make

	make (an_input_iterator: like input_iterator)
		do
			input_iterator := an_input_iterator
		end


feature -- Access

	input_iterator: JRS_LINES_INPUT_ITERATOR
			-- Hmm, wouldn't be a better name JRS_STRING_INPUT_OPERATOR?
			-- Because we're talking about generic strings, not lines.
			-- It's LINES_INPUT_ITERATOR as it is used for a lines
			-- iterator, i.e. input for the lines iterator.


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
			-- Call `f' for every line.
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

	as_files: JRS_FILES_OUTPUT_ITERATOR
			-- String as set of text files
		do
			create Result.make (input_iterator)
		end

	include (an_rx: READABLE_STRING_GENERAL): JRS_LINES_OUTPUT_ITERATOR
			-- Lines matching regular expression `an_rx'
		require
			valid_regular_expression: is_valid_regex (an_rx)
		do
			create lines.make
			create rx.make
			rx.compile (an_rx.out)
			input_iterator.each (agent (a_line: READABLE_STRING_GENERAL): BOOLEAN
				do
					if not a_line.is_empty then
						rx.match (a_line.out)
						if rx.has_matched then
							lines.put_last (a_line.twin)
						end
					end
				end)
			create Result.make (create {JRS_LINES_INPUT_ITERATOR}.make_from_linear (lines))
		end

	exclude (an_rx: READABLE_STRING_GENERAL): JRS_LINES_OUTPUT_ITERATOR
			-- Lines not matching regular expression `an_rx'
		require
			valid_regular_expression: is_valid_regex (an_rx)
		do
			create lines.make
			create rx.make
			rx.compile (an_rx.out)
			input_iterator.each (agent (a_line: READABLE_STRING_GENERAL): BOOLEAN
				do
					if not a_line.is_empty then
						rx.match (a_line.out)
						if not rx.has_matched then
							lines.put_last (a_line.twin)
						end
					end
				end)
			create Result.make (create {JRS_LINES_INPUT_ITERATOR}.make_from_linear (lines))
		end

	tuple (a_tuple_type: TUPLE): JRS_TUPLE_OUTPUT_ITERATOR
			-- Tuple iterator matching tuple `a_tuple_type' for every line
		require
			a_tuple_type_not_void: a_tuple_type /= Void
			field_separator_set: field_separator /= '%U'
		do
			create tuples.make
			tuple_type := a_tuple_type
			input_iterator.each (agent (a_line: READABLE_STRING_GENERAL): BOOLEAN
				local
					list: like split
					i: INTEGER
					t: like tuple_type
					s: STRING
				do
					list := split (a_line, field_separator)
					t := tuple_type.twin
					from
						i := tuple_type.lower
						list.start
					until
						i > t.upper or else
						list.after
					loop
						if t.is_boolean_item (i) then
							s := list.item_for_iteration.out
							if s.is_boolean then
								t.put_boolean (s.to_boolean, i)
							elseif s.is_integer then
								t.put_boolean (s.to_integer /= 0, i)
							else
								t.put_boolean (False, i)
							end
						elseif t.is_integer_item (i) then
							s := list.item_for_iteration.out
							if s.is_integer then
								t.put_integer (s.to_integer, i)
							else
								t.put_integer (0, i)
							end
						elseif t.is_integer_64_item (i) then
							s := list.item_for_iteration.out
							if s.is_integer_64 then
								t.put_integer_64 (s.to_integer_64, i)
							else
								t.put_integer_64 (0, i)
							end
						elseif t.is_reference_item (i) and then t.valid_type_for_index (list.item_for_iteration, i) then
							t.put (list.item_for_iteration, i)
						end
						i := i + 1
						list.forth
					end
					tuples.put_last (t)
				end)
			create Result.make (tuples)
		end


feature -- Anchors

	iterator_anchor: FUNCTION [ANY, TUPLE[JRS_LINES_OUTPUT_ITERATOR], BOOLEAN]


feature {NONE} -- Implementation

	lines: DS_LINKED_LIST [READABLE_STRING_GENERAL]

	tuples: DS_LINKED_LIST [TUPLE]

	tuple_type: TUPLE

	rx: RX_PCRE_REGULAR_EXPRESSION


end
