note

	description:

		"Given stream input, iterate over its lines."

	library: "John Resig Shell library"
	author: "Berend de Boer <berend@pobox.com>"
	copyright: "Copyright (c) 2012, Berend de Boer"
	license: "MIT License (see LICENSE)"


class

	JRS_LINES_STREAM_ITERATOR


inherit

	JRS_LINES_ITERATOR


create

	make


feature {NONE} -- Initialisation

	make (a_stream: attached like stream)
		require
			stream_not_void: a_stream /= Void
			open_read: a_stream.is_open_read
		do
			stream := a_stream
		end


feature -- Access

	stream: KI_TEXT_INPUT_STREAM


feature -- Status

	after: BOOLEAN
		do
			Result := stream.end_of_input
		end


feature -- Access

	last_item: READABLE_STRING_GENERAL
		do
			Result := stream.last_string
		end


feature -- Movement

	start
		do
			stream.read_line
		end

	forth
		do
			stream.read_line
		end


invariant

	stream_not_void: stream /= Void

end
