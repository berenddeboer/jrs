note

	description:

		"Basic telnet interface to send and receive lines"

	library: "John Resig Shell library"
	author: "Berend de Boer <berend@pobox.com>"
	copyright: "Copyright (c) 2015, Berend de Boer"
	license: "MIT License (see LICENSE)"


class

	JRS_TELNET


feature -- Commands

	telnet (a_host_name: STRING; a_port: INTEGER; a_command: detachable STRING): JRS_LINES_ITERATOR
			-- Emit a single `command' to a telnet service.
			-- Note that `command' may need to end with an '%R' for some services.
		require
			host_not_empty: a_host_name /= Void and then not a_host_name.is_empty
			valid_port: a_port >= 0 and a_port <= 65535
		local
			socket: EPX_TCP_CLIENT_SOCKET
		do
			create socket.open_by_name_and_port (a_host_name, a_port)
			if attached a_command as command and then not command.is_empty then
				debug ("jrs")
					print ("TELNET COMMAND: " + command + "%N")
				end
				socket.put_line (command)
				socket.shutdown_write
			end
			 create {JRS_LINES_STREAM_ITERATOR} Result.make (socket)
		end

end
