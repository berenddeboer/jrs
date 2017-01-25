note

	description:

		"Given some input, allow iterating over lines"

	library: "John Resig Shell library"
	author: "Berend de Boer <berend@pobox.com>"
	copyright: "Copyright (c) 2012, Berend de Boer"
	license: "MIT License (see LICENSE)"


class

	JRS_LINES_INPUT_ITERATOR

-- obsolete "Use JRS_LINES_ITERATOR instead."


-- inherit

-- 	JRS_STRING_ITERATOR


create

	make_from_stream,
	make_from_socket,
	make_from_linear


convert

	make_from_stream ({attached EPX_TEXT_INPUT_STREAM}),
	make_from_socket ({attached SUS_UNIX_CLIENT_SOCKET}),
	make_from_linear ({attached DS_LINEAR [READABLE_STRING_GENERAL]})


feature {NONE} -- Initialisation

	make_from_stream (a_stream: attached KI_TEXT_INPUT_STREAM)
		require
			open_read: a_stream.is_open_read
		do
			create {JRS_LINES_STREAM_ITERATOR} internal_iterator.make (a_stream)
		end

	make_from_socket (a_stream: attached KI_TEXT_INPUT_STREAM)
		require
			open_read: a_stream.is_open_read
		do
			make_from_stream (a_stream)
		end

	make_from_linear (a_linear: attached DS_LINEAR [READABLE_STRING_GENERAL])
		require
			linear_not_void: a_linear /= Void
		do
			create {JRS_LINES_LINEAR_ITERATOR} internal_iterator.make (a_linear)
		end


feature -- Status

	after: BOOLEAN
		do
			Result := internal_iterator.after
		end


feature -- Access

	item_for_iteration: READABLE_STRING_GENERAL
		do
			Result := internal_iterator.last_item
		end


feature -- Movement

	each (f: like iterator_anchor)
			-- Call `f' for every line.
		local
			stop: BOOLEAN
		do
			from
				start
			until
				stop or else after
			loop
				f.call ([item_for_iteration])
				stop := f.last_result
				if not stop then
					forth
				end
			end
		end

	start
		do
			internal_iterator.start
		end

	forth
		do
			internal_iterator.forth
		end


feature -- Anchors

	iterator_anchor: FUNCTION [TUPLE[READABLE_STRING_GENERAL], BOOLEAN]


feature {NONE} -- Implementation

	internal_iterator: JRS_LINES_ITERATOR


invariant

	internal_iterator_not_void: internal_iterator /= Void

end
