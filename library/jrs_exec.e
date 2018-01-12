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

	exec (a_command: STRING): JRS_LINES_ITERATOR
			-- Run a single command, return stdout as lines.
			-- Do not use shell operators like '|', see `shell' for that.
		require
			command_not_empty: a_command /= Void and then not a_command.is_empty
		local
			p: EPX_EXEC_PROCESS
		do
			create p.make_from_command_line (a_command)
			p.set_capture_output (True)
			p.execute
			if attached p.fd_stdout as fd then
				create {JRS_LINES_STREAM_ITERATOR} Result.make (fd)
			end
			p.wait_for (False)
			-- TODO: we need to call `wait_for' in our iterator as well, and close properly
			check attached Result end
		ensure
			not_void: Result /= Void
		end

	shell (a_shell_command: STRING): JRS_LINES_ITERATOR
			-- Run a shell command -line using /bin/sh, returning stdout as lines.
		require
			shell_command_not_empty: a_shell_command /= Void and then not a_shell_command.is_empty
		local
			p: POSIX_EXEC_PROCESS
		do
			create p.make_capture_io (once "/bin/sh", <<once "-s">>)
			p.execute
			if attached p.fd_stdin as my_fd_stdin then
				my_fd_stdin.put_line (a_shell_command)
				my_fd_stdin.close
			end

			if attached p.stdout as fd then
				create {JRS_LINES_STREAM_ITERATOR} Result.make (fd)
			end
			check attached Result end
		ensure
			not_void: Result /= Void
		end

	run (a_shell_command: STRING)
			-- Run a command. Exception when exit code indicates a failure.
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
			-- Run a command. Store the exit code in `last_exit_code'.
		require
			shell_command_not_empty: a_shell_command /= Void and then not a_shell_command.is_empty
		local
			my_shell: STDC_SHELL_COMMAND
		do
			create my_shell.make (a_shell_command)
			my_shell.execute
			last_exit_code := my_shell.exit_code
		end

	last_exit_code: INTEGER
			-- Exit code set by `try_run'

end
