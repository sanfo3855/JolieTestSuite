/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*                                                                                    *
* Copyright (C) 2016 Claudio Guidi <guidiclaudio@gmail.com>                          *
*                                                                                    *
* Permission is hereby granted, free of charge, to any person obtaining a copy of    *
* this software and associated documentation files (the "Software"), to deal in the  *
* Software without restriction, including without limitation the rights to use,      *
* copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the    *
* Software, and to permit persons to whom the Software is furnished to do so, subject*
* to the following conditions:                                                       *
*                                                                                    *
* The above copyright notice and this permission notice shall be included in all     *
* copies or substantial portions of the Software.                                    *
*                                                                                    *
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,*
* INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A      *
* PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT *
* HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION  *
* OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE     *
* SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                             *
*                                                                                    *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

include "./public/interfaces/RequestParserInterface.iol"
include "./public/interfaces/TestSuiteClientGenerationInterface.iol"

include "console.iol"
include "metajolie.iol"
include "metaparser.iol"
include "string_utils.iol"
include "file.iol"

outputPort RequestParser {
Interfaces: RequestParserInterface
}

inputPort TestSuiteClientGenerator {
Location: "local"
Interfaces: TestSuiteClientGenerationInterface
}

embedded {
Jolie:
	"request_parser.ol" in RequestParser
}


define __generate_request {
	   // __starting_type
	  if ( generate_data ) {
		with( get_request ) {
		      .types -> __cur_interface.types;
		      .request_type_name = __starting_type
		};
		getRequest@RequestParser( get_request )( rows );
		undef( content );
		content = "";
		for( r = 0, r < #rows.rows, r++ ) {
		      content = content + rows.rows[ r ];
		      if ( r < ( #rows.rows - 1 ) ) {
			    content = content + ";\n"
		      }
		};
		with( file ) {
		      .filename = dir_name + "/data/" + __starting_type + ".txt";
		      .content -> content
		};
		writeFile@File( file )()
	  }
}

define __create_clients {
      for( ifx = 0, ifx < #__input.interfaces, ifx++ ) {
	    __cur_interface -> __input.interfaces[ ifx ];
	    println@Console("Extracting operations from interface " + __cur_interface.name.name)();
	    for( op = 0, op < #__cur_interface.operations, op++ ) {
		  __cur_operation -> __cur_interface.operations[ op ];
		  __starting_type = __cur_operation.input.name;
		  println@Console("Extracting operation " + __cur_operation.operation_name )();
		  __generate_request;
		  content = "include \"" + http_test_suite_location + __input.name.name + "/testport_surface.iol\"\n";
		  content = content + "init{ install( ExecutionFault => nullProcess ) }\n";
		  content = content + "main{\nrun( request )( response ) {\n";
		  content = content + "scope( test ) { install( default => valueToPrettyString@StringUtils( test )( s ); fault.faultname=test.default; fault.message = \"Error during execution of " + __cur_operation.operation_name +",\" + s; throw( ExecutionFault, fault ) );\n";
		  content = content + __cur_operation.operation_name + "@" + __input.name.name +"( request )( response )\n";
		  content = content + "}}\n}\n";
		  with( file ) {
			.filename = dir_name + "/" + __cur_operation.operation_name + ".ol";
			.content -> content
		  };
		  writeFile@File( file )()
	    }
      }
}

define __create_surface {
      // generate surface
      getSurface@Parser( __input )( surface );
      with( surface_file ) {
	    .filename = dir_name + "/testport_surface.iol";
	    .content -> surface
      };
      writeFile@File( surface_file )()

}

define __create_local_abstract {
      content = "";
      with( file ) {
	    .filename = request.target_folder + "/localAbstractGoal.iol";
	    .content -> content
      };
      writeFile@File( file )()
}

define __generate {

      dir_name = request.target_folder + __input.name.name;
      mkdir@File( dir_name )();
      mkdir@File( dir_name + "/data" )();
      __create_surface;
      __create_clients;
      __create_local_abstract
}

main {
      generate( request )( response ) {
	    scope( readfile ) {
		  http_test_suite_location = request.http_test_suite_location;
		  generate_data = request.generate_data;
		  with( metaInput ) {
			.filename = request.main_file;
			.name.name = "_";
			.name.domain = "_"
		  };
		  getInputPortMetaData@MetaJolie( metaInput )( __inputs );

		  valueToPrettyString@StringUtils( __inputs )( s );
		  println@Console( s )();

		  for( i = 0, i < #__inputs.input, i++ ) {
			  println@Console( "Generating clients for input port " + __inputs.input[ i ].name.name )();

			  __input -> __inputs.input[ i ];
			  __generate
		  }
	    }
      }
}
