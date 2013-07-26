note

	description:

		"List of files (not strictly a set) and conversion from commonly used arguments to it"

	library: "John Resig Shell library"
	author: "Berend de Boer <berend@pobox.com>"
	copyright: "Copyright (c) 2013, Berend de Boer"
	license: "MIT License (see LICENSE)"


class

	JRS_FILE_SET


inherit

	DS_LINKED_LIST [STDC_TEXT_FILE]


create

	make,
	make_equal,
	make_from_linear,
	make_from_array,
	make_default,
	make_from_string_set,
	make_from_iterator


convert

	make_from_string_set ({JRS_STRING_SET}),
	make_from_iterator ({JRS_LINES_INPUT_ITERATOR})


feature {NONE} -- Initialisation

	make_from_string_set (s: JRS_STRING_SET)
		local
			text: like item
		do
			make
			from
				s.start
			until
				s.after
			loop
				create text.make (s.item_for_iteration.out)
				put_last (text)
				s.forth
			end
		ensure
			all_items_added: count = s.count
		end

	make_from_iterator (s: JRS_LINES_INPUT_ITERATOR)
		local
			text: like item
		do
			make
			from
				s.start
			until
				s.after
			loop
				create text.make (s.item_for_iteration.out)
				put_last (text)
				s.forth
			end
		ensure
			all_items_added: True
		end


end
