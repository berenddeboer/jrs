note

	description:

		"Iterates over lines applying a regular expression match"

	library: "John Resig Shell library"
	author: "Berend de Boer <berend@pobox.com>"
	copyright: "Copyright (c) 2015, Berend de Boer"
	license: "MIT License (see LICENSE)"


class

	JRS_MATCH_ITERATOR


inherit

	JRS_LINES_ITERATOR

	JRS_WRAPPER_ITERATOR
		rename
			make as make_wrapper
		redefine
			start,
			forth
		end

	JRS_STRING_ROUTINES


create

	make


feature {NONE} -- Initialisation

	make (an_iterator: like wrapped_iterator; an_rx: READABLE_STRING_GENERAL; a_should_match: BOOLEAN)
		require
			valid_regular_expression: is_valid_regex (an_rx)
		do
			make_wrapper (an_iterator)
			create rx.make
			rx.compile (an_rx.out)
			should_match := a_should_match
		end


feature -- Access

	rx: RX_PCRE_REGULAR_EXPRESSION
			-- When iterating using `include' or `exclude' the currently
			-- matched expression

	should_match: BOOLEAN
			-- Proceed when the regular expression matches or the opposite?


feature -- Movement

	start
		do
			precursor
			move_till_match
		end

	forth
		do
			precursor
			move_till_match
		end


feature {NONE} -- Implementation

	move_till_match
			-- Read lines until one matches.
		local
			found: BOOLEAN
		do
			from
			until
				after or else found
			loop
				if attached last_item as li then
					rx.match (li.out)
					found := rx.has_matched = should_match
					if not found then
						wrapped_iterator.forth
					end
				end
			end
		end

end
