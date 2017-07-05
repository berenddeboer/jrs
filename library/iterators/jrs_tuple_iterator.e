note

	description:

		"Iterator that transforms lines into TUPLEs"

	library: "John Resig Shell library"
	author: "Berend de Boer <berend@pobox.com>"
	copyright: "Copyright (c) 2012, Berend de Boer"
	license: "MIT License (see LICENSE)"


class

	JRS_TUPLE_ITERATOR [G -> TUPLE]


inherit

	JRS_TRANSFORMING_ITERATOR [READABLE_STRING_GENERAL, G]
		rename
			make as make_transforming_iterator
		end

	JRS_STRING_ROUTINES


create

	make


feature {NONE} -- Initialisation

	make (an_iterator: like wrapped_iterator; a_tuple_type: G; a_field_separator: like field_separator)
		require
			a_tuple_type_not_void: a_tuple_type /= Void
			field_separator_set: a_field_separator /= '%U'
		do
			make_transforming_iterator (an_iterator)
			tuple_type := a_tuple_type
			field_separator := a_field_separator
		end


feature -- Access

	last_item: G
		do
			Result := new_tuple (wrapped_iterator.last_item)
		end

	tuple_type: G
			-- We cannot create generic tuples, they must be based on a
			-- specific tuple, so instead of creating one, we clone an
			-- actual one.

	field_separator: CHARACTER


feature {NONE} -- Implementation

	new_tuple (a_line: READABLE_STRING_GENERAL): G
			-- Used by `tuple'.
		local
			list: like split
			i: INTEGER
			t: like tuple_type
			s: STRING
		do
			list := split (a_line, field_separator)
			t := tuple_type.twin
			from
				i := t.lower
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
			Result := t
		end


end
