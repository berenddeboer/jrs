note

	description:

		"Provides lines function, transforming an input into an output of lines."

	library: "John Resig Shell library"
	author: "Berend de Boer <berend@pobox.com>"
	copyright: "Copyright (c) 2012, Berend de Boer"
	license: "MIT License (see LICENSE)"


class

	JRS_LINES


inherit

	JRS_RECORD_STATE


feature -- Commands

	lines (an_input: JRS_LINES_INPUT_ITERATOR): JRS_LINES_OUTPUT_ITERATOR
		do
			create Result.make (an_input)
		end


end
