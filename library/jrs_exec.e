note

	description:

		"Run subprocesses"

	library: "John Resig Shell library"
	author: "Berend de Boer <berend@pobox.com>"
	copyright: "Copyright (c) 2011, Berend de Boer"
	license: "MIT License (see LICENSE)"


class

	JRS_EXEC


inherit

	JRS_BASE


feature -- Run things

	exec (a_shell_command: STRING): JRS_LINES_OUTPUT_ITERATOR
			-- Run command, return stdout as lines.
		local
			p: POSIX_EXEC_PROCESS
			input_iterator: JRS_LINES_INPUT_ITERATOR
		do
			create p.make_from_command_line (a_shell_command)
			p.set_capture_output (True)
			p.execute
			create input_iterator.make_from_stream (p.stdout)
			create Result.make (input_iterator)
		ensure
			not_void: Result /= Void
		end

	run (a_shell_command: STRING)
		require
			shell_command_not_empty: a_shell_command /= Void and then not a_shell_command.is_empty
		do
			try_run (a_shell_command)
			if last_exit_code /= 0 then
				print ("Error running:%N  " + a_shell_command + "%N  Exit code: " + last_exit_code.out + "%N")
				exit (last_exit_code)
			end
		end

	try_run (a_shell_command: STRING)
		require
			shell_command_not_empty: a_shell_command /= Void and then not a_shell_command.is_empty
		local
			shell: STDC_SHELL_COMMAND
		do
			create shell.make (a_shell_command)
			shell.execute
			last_exit_code := shell.exit_code
		end

	last_exit_code: INTEGER
			-- Exit code set by `try_run'

end
