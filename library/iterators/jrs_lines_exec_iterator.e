note

	description:

		"Iterate over stdout of a child process."

	library: "John Resig Shell library"
	author: "Berend de Boer <berend@pobox.com>"
	copyright: "Copyright (c) 2018, Berend de Boer"
	license: "MIT License (see LICENSE)"


class

	JRS_LINES_EXEC_ITERATOR


inherit

	JRS_LINES_ITERATOR


create

	make


feature {NONE} -- Initialisation

	make (a_process: like process)
		require
			output_going_to_be_captured: a_process.capture_output
		do
			process := a_process
			last_item := ""
		end


feature -- Status

	after: BOOLEAN


feature -- Access

	last_item: READABLE_STRING_GENERAL


feature -- Movement

	start
		do
			after := False
			process.execute
			-- TODO: probably need to check this executed OK
			forth
		end

	forth
		do
			if attached process.fd_stdout as fd then
				fd.read_line
				last_item := fd.last_string
				if fd.end_of_input then
					process.wait_for (True)
					after := True
				end
			end
		end


feature {NONE} -- Implementation

	process: EPX_EXEC_PROCESS


end
