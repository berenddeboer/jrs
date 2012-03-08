note

	description:

		"Run subprocesses"

	library: "John Resig Shell library"
	author: "Berend de Boer <berend@pobox.com>"
	copyright: "Copyright (c) 2011, Berend de Boer"
	license: "MIT License (see LICENSE)"
	date: "$Date$"
	revision: "$Revision$"


class

	JRS_EXEC


inherit

	JRS_BASE


feature

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
