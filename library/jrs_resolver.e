note

	description:

		"Short description of the class"

	library: "John Resig Shell library"
	author: "Berend de Boer <berend@pobox.com>"
	copyright: "Copyright (c) 2011, Berend de Boer"
	license: "MIT License (see LICENSE)"


class

	JRS_RESOLVER


inherit

	XM_SHARED_CATALOG_MANAGER
		export
			{NONE} all
		end


feature -- Resolver

	url_to_stream (a_url: STRING): detachable KI_CHARACTER_INPUT_STREAM
		do
			resolver.resolve_uri (a_url)
			Result := resolver.last_stream
		end


feature {NONE} -- Implementation

	resolver: XM_SIMPLE_URI_EXTERNAL_RESOLVER
			-- Resolver for "file:", "http:" and "https:" scheme
		local
			a_file: XM_FILE_URI_RESOLVER
			a_http: EPX_HTTP_URI_RESOLVER
			a_https: EPX_HTTP_URI_RESOLVER
		once
			Result ?= shared_catalog_manager.bootstrap_resolver.uri_scheme_resolver

			create a_file.make
			Result.register_scheme (a_file)
			create a_http.make (Result.uris)
			Result.register_scheme (a_http)
			create a_https.make (Result.uris)
			Result.register_scheme (a_https)
		ensure
			result_not_void: Result /= Void
		end

end
