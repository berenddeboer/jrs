note

	description:

		"ODBC interface"

	library: "John Resig Shell library"
	author: "Berend de Boer <berend@pobox.com>"
	copyright: "Copyright (c) 2010, Berend de Boer"
	license: "MIT License (see LICENSE)"


class

	JRS_ODBC


inherit

	JRS_BASE


feature -- Command

	execute_sql (a_data_source: STRING; an_sql: STRING; a_parameters: TUPLE)
		require
			data_source_not_empty: a_data_source /= Void and then not a_data_source.is_empty
			not_empty: an_sql /= Void and then not an_sql.is_empty
		local
			stmt: JRS_ECLI_STATEMENT
			sql: STRING
		do
			sql := format_sql (expand_env_vars (an_sql), a_parameters)
			create stmt.make (session (a_data_source))
			stmt.set_sql (sql)
			stmt.execute
			stmt.close
		end


feature -- Status

	query (a_data_source: STRING; an_sql: STRING; a_parameters: TUPLE; a_row_format: TUPLE []): JRS_ROWS_ITERATOR [like a_row_format]
			-- Rows returned by executing `an_sql'
		require
			data_source_not_empty: a_data_source /= Void and then not a_data_source.is_empty
			not_empty: an_sql /= Void and then not an_sql.is_empty
			row_format_not_void: a_row_format /= Void
		local
			stmt: JRS_ECLI_STATEMENT
			sql: STRING
		do
			sql := format_sql (expand_env_vars (an_sql), a_parameters)
			create stmt.make (session (a_data_source))
			stmt.set_sql (sql)
			stmt.execute
			create Result.make
			if stmt.is_executed and then stmt.has_result_set then
				stmt.tuple_bind (a_row_format)
				from
					stmt.start
				until
					stmt.after
				loop
					Result.put_last (a_row_format.twin)
					stmt.forth
				end
			end
			stmt.close
		end

	session (a_data_source: STRING): ECLI_SESSION
			-- New or existing session
		require
			data_source_not_empty: a_data_source /= Void and then not a_data_source.is_empty
		local
			login: ECLI_SIMPLE_LOGIN
			my_session: ECLI_SESSION
		do
			if data_sources = Void then
				create data_sources.make (2)
			end
			if not data_sources.has (a_data_source) then
				create login.make (a_data_source, "", "")
				create my_session.make_default
				my_session.set_login_strategy (login)
				my_session.connect
				if my_session.is_connected then
					my_session.raise_exception_on_error
				else
					stderr.put_line ("Cannot open data source '" + a_data_source + "'.")
					stderr.put_line ("Error message: " + my_session.diagnostic_message)
					exit_with_failure
				end
				data_sources.put_last (my_session, a_data_source)
				setup_connection (a_data_source)
			end
			Result := data_sources.item (a_data_source)
		ensure
			not_void: Result /= Void
			cached: data_sources.has (a_data_source)
		end


	setup_connection (a_data_source: STRING)
			-- Prepare connection for use
		require
			data_source_not_empty: a_data_source /= Void and then not a_data_source.is_empty
		do
			-- Require all data to be passed in UTF8
			--execute_sql (a_data_source, "set names 'utf8'", Void)
			-- This didn't work!!
			-- The ODBC connection must specify 'charset=utf8'
		end

feature {NONE} -- Implementation

	data_sources: DS_HASH_TABLE [ECLI_SESSION, STRING]


end
